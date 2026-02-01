//
//  Buttons.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/31/25.
//

import SwiftUI

struct ButtonView: View {
    
    @ObservedObject var game: DualNBackGame
    @State var positionSelected = false
    @State var audioSelected = false
    
    var body: some View {
        // Answer buttons - full left and right sides
        if game.isPlaying && game.currentRound > game.n {
            HStack(spacing: 0) {
                
                // Left side - Position button
                Button(action: { 
                    positionSelected.toggle()
                    checkPositionAndSubmit()
                }) {
                    HStack {
                        Text("POSITION")
                            .font(.system(size: 15, weight: .bold))
                            .padding(.top, 500)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(positionColor())
                    .animation(.easeOut(duration: 0.4), value: game.positionResult)
                }
                
                // Right side - Audio button
                Button(action: { 
                    audioSelected.toggle() 
                    checkAudioAndSubmit()
                }) {
                    HStack {
                        Text("AUDIO")
                            .font(.system(size: 15, weight: .bold))
                            .padding(.top, 500)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(audioColor())
                    .animation(.easeOut(duration: 0.2), value: game.audioResult)
                }
            }
            .onChange(of: game.currentRound) { oldRound, newRound in
                // This code runs automatically whenever the round changes
                // Reset button selection state for the new round
                // Missed answer detection is now handled in nextRound()
                if game.isPlaying {
                    positionSelected = false
                    audioSelected = false
                }
            }
        }
        else if game.isPlaying && game.currentRound <= game.n {
            HStack(spacing: 0) {
                HStack {
                    Text("POSITION")
                        .font(.system(size: 15, weight: .bold))
                        .padding(.top, 500)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(positionColor())
                
                HStack {
                    Text("AUDIO")
                        .font(.system(size: 15, weight: .bold))
                        .padding(.top, 500)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(audioColor())
            }
        }
    }
    
    private func checkPositionAndSubmit(){
        if !game.positionSubmitted {
            game.checkPositionMatch(positionMatch: positionSelected)
            positionSelected = false
        }
    }

    private func checkAudioAndSubmit(){
        if !game.audioSubmitted {
            game.checkAudioMatch(audioMatch: audioSelected)
            audioSelected = false
        }
    }

    private func positionColor() -> Color {
        switch game.positionResult {
        case .none:
            return Color(.systemBackground)
        case .correct:
            return .green
        case .wrong:
            return .red
        case .missed:
            return .orange
        }
    }

    private func audioColor() -> Color {
        switch game.audioResult {
        case .none:
            return Color(.systemBackground)
        case .correct:
            return .green
        case .wrong:
            return .red
        case .missed:
            return .orange
        }
    }
}
