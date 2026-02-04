//
//  SnakeGameEngine.swift
//  ImageExt
//
//  Created by yakang wang on 2026/2/4.
//

import Foundation

struct Point: Hashable {
    let x: Int
    let y: Int
}

enum Direction {
    case up
    case down
    case left
    case right
}

struct SnakeGameEngine {
    let gridSize: Int
    var snake: [Point]
    var direction: Direction
    var food: Point
    var score: Int
    var isGameOver: Bool

    init(gridSize: Int) {
        self.gridSize = gridSize
        self.snake = [
            Point(x: 2, y: 2),
            Point(x: 1, y: 2),
            Point(x: 0, y: 2)
        ]
        self.direction = .right
        self.food = Point(x: 0, y: 0)
        self.score = 0
        self.isGameOver = false
        self.food = spawnFood()
    }

    mutating func tick() {
        if isGameOver {
            return
        }

        let head = snake[0]
        let next = nextPoint(from: head)
        let willGrow = next == food
        let bodyToCheck = willGrow ? snake : Array(snake.dropLast())

        if isWallCollision(next) || bodyToCheck.contains(next) {
            isGameOver = true
            return
        }

        if willGrow {
            snake.insert(next, at: 0)
            score += 1
            food = spawnFood()
            return
        }

        snake.insert(next, at: 0)
        snake.removeLast()
    }

    mutating func setDirection(_ newDirection: Direction) {
        let isReverse =
            (direction == .left && newDirection == .right) ||
            (direction == .right && newDirection == .left) ||
            (direction == .up && newDirection == .down) ||
            (direction == .down && newDirection == .up)

        if isReverse {
            return
        }

        direction = newDirection
    }

    func spawnFood() -> Point {
        let allPoints = (0..<gridSize).flatMap { y in
            (0..<gridSize).map { x in Point(x: x, y: y) }
        }
        let emptyPoints = allPoints.filter { !snake.contains($0) }
        return emptyPoints.randomElement() ?? Point(x: 0, y: 0)
    }

    private func nextPoint(from head: Point) -> Point {
        switch direction {
        case .up:
            return Point(x: head.x, y: head.y - 1)
        case .down:
            return Point(x: head.x, y: head.y + 1)
        case .left:
            return Point(x: head.x - 1, y: head.y)
        case .right:
            return Point(x: head.x + 1, y: head.y)
        }
    }

    private func isWallCollision(_ point: Point) -> Bool {
        point.x < 0 || point.y < 0 || point.x >= gridSize || point.y >= gridSize
    }
}
