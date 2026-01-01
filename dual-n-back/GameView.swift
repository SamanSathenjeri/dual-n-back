//
//  GameView.swift
//  DualNBack
//
//  Main game play view
//

import SwiftUI

struct GameView: View {
    @ObservedObject var game: DualNBackGame
    
    var body: some View {
        NavigationStack {
            ZStack {
                ButtonView(game: game)
                GridView(game: game)
                ButtonToggleView(game: game)
            }
        }
        .modifier(GameOverModifier(game: game))
        .navigationTitle("Dual N-Back")
        .navigationBarTitleDisplayMode(.inline)
    }
}
