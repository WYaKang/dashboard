//
//  SnakeGameEngineTests.swift
//  ImageExtTests
//
//  Created by yakang wang on 2026/2/4.
//

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

    @Test func ignoresReverseDirection() {
        var engine = SnakeGameEngine(gridSize: 5)
        engine.direction = .right
        engine.setDirection(.left)

        #expect(engine.direction == .right)
    }

    @Test func foodStartsWithinBounds() {
        let engine = SnakeGameEngine(gridSize: 3)

        #expect(engine.food.x >= 0 && engine.food.x < engine.gridSize)
        #expect(engine.food.y >= 0 && engine.food.y < engine.gridSize)
    }
}
