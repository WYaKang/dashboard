# Snake Game Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a classic Snake game screen to the SwiftUI app, accessible from the home screen, with deterministic game logic and unit tests.

**Architecture:** Introduce a pure logic `SnakeGameEngine` (grid, snake, food, score, collisions) and a SwiftUI `SnakeGameView` that renders the grid and provides direction controls. Use a `Timer` in the view to drive ticks and keep UI minimal.

**Tech Stack:** Swift 5, SwiftUI, Swift Testing (`import Testing`), no new dependencies.

---

### Task 1: Add a failing test for basic movement

**Files:**
- Create: `ImageExtTests/SnakeGameEngineTests.swift`
- (Later) Create: `ImageExt/Snake/SnakeGameEngine.swift`

**Step 1: Write the failing test**

```swift
import Testing
@testable import ImageExt

struct SnakeGameEngineTests {
    @Test func movesForwardByOneCell() {
        var engine = SnakeGameEngine(gridSize: 5)
        let originalHead = engine.snake.first!
        engine.direction = .right

        engine.tick()

        #expect(engine.snake.first == Point(x: originalHead.x + 1, y: originalHead.y))
        #expect(engine.snake.count == 3)
    }
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: FAIL (test fails because `tick()` not implemented correctly).

**Step 3: Write minimal implementation**

```swift
struct Point: Hashable { let x: Int; let y: Int }

enum Direction { case up, down, left, right }

struct SnakeGameEngine {
    let gridSize: Int
    var snake: [Point]
    var direction: Direction

    init(gridSize: Int) {
        self.gridSize = gridSize
        self.snake = [Point(x: 2, y: 2), Point(x: 1, y: 2), Point(x: 0, y: 2)]
        self.direction = .right
    }

    mutating func tick() {
        let head = snake[0]
        let next = Point(x: head.x + 1, y: head.y)
        snake.insert(next, at: 0)
        snake.removeLast()
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: PASS for `movesForwardByOneCell`.

**Step 5: Commit**

```bash
git add ImageExt/Snake/SnakeGameEngine.swift ImageExtTests/SnakeGameEngineTests.swift
git commit -m "feat: add basic snake movement logic"
```

---

### Task 2: Add failing tests for food and growth

**Files:**
- Modify: `ImageExtTests/SnakeGameEngineTests.swift`
- Modify: `ImageExt/Snake/SnakeGameEngine.swift`

**Step 1: Write the failing tests**

```swift
@Test func growsWhenEatingFood() {
    var engine = SnakeGameEngine(gridSize: 5)
    let head = engine.snake[0]
    engine.food = Point(x: head.x + 1, y: head.y)
    engine.direction = .right

    engine.tick()

    #expect(engine.snake.count == 4)
    #expect(engine.score == 1)
}

@Test func foodNeverSpawnsOnSnake() {
    var engine = SnakeGameEngine(gridSize: 4)
    engine.snake = [Point(x: 0, y: 0), Point(x: 1, y: 0), Point(x: 2, y: 0)]

    let food = engine.spawnFood()

    #expect(!engine.snake.contains(food))
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: FAIL (food, score, and spawn logic missing).

**Step 3: Write minimal implementation**

```swift
struct SnakeGameEngine {
    // ...existing...
    var food: Point
    var score: Int

    init(gridSize: Int) {
        // ...existing...
        self.food = Point(x: 3, y: 2)
        self.score = 0
    }

    mutating func tick() {
        let head = snake[0]
        let next = nextPoint(from: head)

        if next == food {
            snake.insert(next, at: 0)
            score += 1
            food = spawnFood()
        } else {
            snake.insert(next, at: 0)
            snake.removeLast()
        }
    }

    func spawnFood() -> Point {
        let all = (0..<gridSize).flatMap { y in (0..<gridSize).map { x in Point(x: x, y: y) } }
        let empty = all.filter { !snake.contains($0) }
        return empty.randomElement() ?? Point(x: 0, y: 0)
    }

    private func nextPoint(from head: Point) -> Point {
        switch direction {
        case .up: return Point(x: head.x, y: head.y - 1)
        case .down: return Point(x: head.x, y: head.y + 1)
        case .left: return Point(x: head.x - 1, y: head.y)
        case .right: return Point(x: head.x + 1, y: head.y)
        }
    }
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: PASS for food and growth tests.

**Step 5: Commit**

```bash
git add ImageExt/Snake/SnakeGameEngine.swift ImageExtTests/SnakeGameEngineTests.swift
git commit -m "feat: add snake growth and food spawning"
```

---

### Task 3: Add failing tests for collisions and game over

**Files:**
- Modify: `ImageExtTests/SnakeGameEngineTests.swift`
- Modify: `ImageExt/Snake/SnakeGameEngine.swift`

**Step 1: Write the failing tests**

```swift
@Test func gameOverOnWallCollision() {
    var engine = SnakeGameEngine(gridSize: 3)
    engine.snake = [Point(x: 2, y: 1), Point(x: 1, y: 1), Point(x: 0, y: 1)]
    engine.direction = .right

    engine.tick()

    #expect(engine.isGameOver == true)
}

@Test func gameOverOnSelfCollision() {
    var engine = SnakeGameEngine(gridSize: 5)
    engine.snake = [
        Point(x: 2, y: 2),
        Point(x: 2, y: 3),
        Point(x: 1, y: 3),
        Point(x: 1, y: 2)
    ]
    engine.direction = .down

    engine.tick()

    #expect(engine.isGameOver == true)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: FAIL (collision detection missing).

**Step 3: Write minimal implementation**

```swift
var isGameOver: Bool

init(gridSize: Int) {
    // ...existing...
    self.isGameOver = false
}

mutating func tick() {
    if isGameOver { return }
    let head = snake[0]
    let next = nextPoint(from: head)

    if isWallCollision(next) || snake.contains(next) {
        isGameOver = true
        return
    }

    if next == food {
        snake.insert(next, at: 0)
        score += 1
        food = spawnFood()
    } else {
        snake.insert(next, at: 0)
        snake.removeLast()
    }
}

private func isWallCollision(_ point: Point) -> Bool {
    point.x < 0 || point.y < 0 || point.x >= gridSize || point.y >= gridSize
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: PASS for collision tests.

**Step 5: Commit**

```bash
git add ImageExt/Snake/SnakeGameEngine.swift ImageExtTests/SnakeGameEngineTests.swift
git commit -m "feat: add snake collision handling"
```

---

### Task 4: Add direction constraints (no reverse)

**Files:**
- Modify: `ImageExtTests/SnakeGameEngineTests.swift`
- Modify: `ImageExt/Snake/SnakeGameEngine.swift`

**Step 1: Write the failing test**

```swift
@Test func ignoresReverseDirection() {
    var engine = SnakeGameEngine(gridSize: 5)
    engine.direction = .right
    engine.setDirection(.left)

    #expect(engine.direction == .right)
}
```

**Step 2: Run test to verify it fails**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: FAIL (setDirection not implemented).

**Step 3: Write minimal implementation**

```swift
mutating func setDirection(_ newDirection: Direction) {
    if (direction == .left && newDirection == .right) ||
       (direction == .right && newDirection == .left) ||
       (direction == .up && newDirection == .down) ||
       (direction == .down && newDirection == .up) {
        return
    }
    direction = newDirection
}
```

**Step 4: Run test to verify it passes**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: PASS.

**Step 5: Commit**

```bash
git add ImageExt/Snake/SnakeGameEngine.swift ImageExtTests/SnakeGameEngineTests.swift
git commit -m "feat: add snake direction constraints"
```

---

### Task 5: Build SnakeGameView UI with grid and controls

**Files:**
- Create: `ImageExt/Snake/SnakeGameView.swift`
- Modify: `ImageExt/ContentView.swift`

**Step 1: Write the failing test**

No UI tests requested; skip.

**Step 2: Run test to verify it fails**

Skip.

**Step 3: Write minimal implementation**

```swift
import SwiftUI

struct SnakeGameView: View {
    @State private var engine = SnakeGameEngine(gridSize: 20)
    @State private var timer: Timer? = nil

    private let cellSize: CGFloat = 14

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Score: \(engine.score)")
                Spacer()
                Button("Restart") { restart() }
            }

            VStack(spacing: 2) {
                ForEach(0..<engine.gridSize, id: \.self) { y in
                    HStack(spacing: 2) {
                        ForEach(0..<engine.gridSize, id: \.self) { x in
                            cellView(at: Point(x: x, y: y))
                        }
                    }
                }
            }

            if engine.isGameOver {
                Text("Game Over")
                    .foregroundStyle(.red)
            }

            controlPad
        }
        .padding()
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
    }

    private func cellView(at point: Point) -> some View {
        let isSnake = engine.snake.contains(point)
        let isFood = engine.food == point
        return Rectangle()
            .fill(isFood ? Color.red : (isSnake ? Color.green : Color.gray.opacity(0.2)))
            .frame(width: cellSize, height: cellSize)
    }

    private var controlPad: some View {
        VStack(spacing: 8) {
            Button("↑") { engine.setDirection(.up) }
            HStack(spacing: 16) {
                Button("←") { engine.setDirection(.left) }
                Button("→") { engine.setDirection(.right) }
            }
            Button("↓") { engine.setDirection(.down) }
        }
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            engine.tick()
            if engine.isGameOver { stopTimer() }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func restart() {
        engine = SnakeGameEngine(gridSize: 20)
        startTimer()
    }
}
```

`ContentView.swift` minimal navigation button:

```swift
struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("ImageExt")
                    .font(.title)
                NavigationLink("Play Snake") {
                    SnakeGameView()
                }
            }
            .padding()
        }
    }
}
```

**Step 4: Run tests**

Run: `xcodebuild -scheme ImageExt -destination 'platform=macOS,arch=arm64' test`
Expected: PASS.

**Step 5: Commit**

```bash
git add ImageExt/Snake/SnakeGameView.swift ImageExt/ContentView.swift
git commit -m "feat: add snake game screen and entry button"
```

---

### Task 6: Manual verification checklist

**Files:**
- Modify: none

**Step 1: Run app**

Run in Xcode: select `ImageExt` scheme and press Run.

**Step 2: Verify**
- App launches and shows “Play Snake” button
- Snake moves on timer and responds to on-screen arrows
- Eating food increases score and length
- Wall/self collision triggers Game Over
- Restart resets score and snake

**Step 3: Commit (optional)**

No code changes.
