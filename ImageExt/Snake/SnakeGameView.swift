//
//  SnakeGameView.swift
//  ImageExt
//
//  Created by yakang wang on 2026/2/4.
//

import SwiftUI

struct SnakeGameView: View {
    @State private var engine = SnakeGameEngine(gridSize: 20)
    @State private var timer: Timer?

    private let cellSize: CGFloat = 14
    private let cellSpacing: CGFloat = 2
    private let tickInterval: TimeInterval = 0.15

    var body: some View {
        VStack(spacing: 16) {
            header
            grid
            if engine.isGameOver {
                Text("Game Over")
                    .foregroundStyle(.red)
            }
            controls
        }
        .padding()
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .navigationTitle("Snake")
    }

    private var header: some View {
        HStack {
            Text("Score: \(engine.score)")
                .font(.headline)
            Spacer()
            Button("Restart") {
                restart()
            }
            .buttonStyle(.bordered)
        }
    }

    private var grid: some View {
        VStack(spacing: cellSpacing) {
            ForEach(0..<engine.gridSize, id: \.self) { y in
                HStack(spacing: cellSpacing) {
                    ForEach(0..<engine.gridSize, id: \.self) { x in
                        cellView(at: Point(x: x, y: y))
                    }
                }
            }
        }
        .padding(4)
        .background(Color.gray.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var controls: some View {
        VStack(spacing: 8) {
            Button("↑") { engine.setDirection(.up) }
                .buttonStyle(.bordered)
            HStack(spacing: 16) {
                Button("←") { engine.setDirection(.left) }
                    .buttonStyle(.bordered)
                Button("→") { engine.setDirection(.right) }
                    .buttonStyle(.bordered)
            }
            Button("↓") { engine.setDirection(.down) }
                .buttonStyle(.bordered)
        }
    }

    private func cellView(at point: Point) -> some View {
        let isSnake = engine.snake.contains(point)
        let isFood = engine.food == point
        return Rectangle()
            .fill(isFood ? Color.red : (isSnake ? Color.green : Color.clear))
            .frame(width: cellSize, height: cellSize)
            .background(Color.white)
            .border(Color.gray.opacity(0.2), width: 0.5)
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: tickInterval, repeats: true) { _ in
            engine.tick()
            if engine.isGameOver {
                stopTimer()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func restart() {
        engine = SnakeGameEngine(gridSize: engine.gridSize)
        startTimer()
    }
}

#Preview {
    NavigationStack {
        SnakeGameView()
    }
}
