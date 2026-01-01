//
//  Buttons.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/31/25.
//


import SwiftUI

struct ButtonView: View {
    
    @ObservedObject var game: DualNBackGame
    @State private var positionSelected = false
    @State private var audioSelected = false
    
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
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top, 600)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(game.positionButtonColor)
                }
                
                // Right side - Audio button
                Button(action: {
                    audioSelected.toggle()
                    checkAudioAndSubmit()
                }) {
                    HStack {
                        Text("AUDIO")
                            .font(.system(size: 20, weight: .bold))
                            .padding(.top, 600)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(game.audioButtonColor)
                }
            }
        }
        else if game.isPlaying && game.currentRound <= game.n {
            HStack(spacing: 0) {
                HStack {
                    Text("POSITION")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 600)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(game.positionButtonColor)
                
                HStack {
                    Text("AUDIO")
                        .font(.system(size: 20, weight: .bold))
                        .padding(.top, 600)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(game.audioButtonColor)
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
}
