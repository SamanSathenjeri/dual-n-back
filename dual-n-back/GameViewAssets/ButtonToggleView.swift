//
//  ButtonToggleView.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/31/25.
//

import SwiftUI

struct ButtonToggleView: View {
    
    @ObservedObject var game: DualNBackGame
    
    var body: some View {
        // Start button
        if !game.isPlaying {
            VStack() {
                Button(action: {
                    game.startGame()
                }) {
                    Text("Start Game")
                        .font(.headline)
                        .foregroundColor(.green)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 20)
                        .cornerRadius(10)
                }
                .padding(.top, 365)

                Text("N = \(game.n)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        else if game.isPlaying {
            Button(action: {
                game.resetGame()
            }) {
                Text("Stop")
                    .font(.headline)
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .cornerRadius(10)
            }
            .padding(.top, 365)
        }
    }
}
