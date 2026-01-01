//
//  GameView.swift
//  DualNBack
//
//  Main game play view
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game: DualNBackGame
    @State private var positionSelected = false
    @State private var audioSelected = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ButtonView(game: game)
                GridView(game: game)
                ButtonToggleView(game: game)
            }
        }
        .navigationTitle("Dual N-Back")
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: game.currentRound) { _, _ in
            positionSelected = false
            audioSelected = false
        }
    }
}

