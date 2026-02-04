//
//  ContentView.swift
//  ImageExt
//
//  Created by yakang wang on 2026/1/4.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("ImageExt")
                    .font(.title)
                NavigationLink("Play Snake") {
                    SnakeGameView()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
