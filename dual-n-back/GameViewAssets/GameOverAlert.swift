//
//  GameOverAlert.swift
//  dual-n-back
//
//  Game over alert with performance-based messages
//

import SwiftUI

struct GameOverModifier: ViewModifier {
    @ObservedObject var game: DualNBackGame

    func body(content: Content) -> some View {
        content
            .alert(game.gameEndPerformance.title, isPresented: $game.gameEnded) {
                Button("Play Again") { game.resetGame() }
                Button("OK", role: .cancel) { }
            } message: {
                Text("Audio: \(game.correctAudioAnswers) / \(game.totalAudioAnswers)")
            }
    }
    
    private var alertMessage: String {
        var message = game.gameEndPerformance.message
        message += "\n\nYour Scores:"
        message += "\nAudio: \(game.correctAudioAnswers) / \(game.totalAudioAnswers)"
        message += "\nPosition: \(game.correctPositionAnswers) / \(game.totalPositionAnswers)"
        return message
    }
}
