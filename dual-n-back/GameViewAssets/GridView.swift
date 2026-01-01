//
//  GridView.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/31/25.
//

import SwiftUI

struct GridView: View {
    @ObservedObject var game: DualNBackGame
    @State private var pulseOpacity: Double = 0

    var body: some View {
        VStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { col in
                        ZStack {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))

                            Rectangle()
                                .fill(Color.blue)
                                .opacity(
                                    game.currentPosition.row == row &&
                                    game.currentPosition.col == col
                                    ? pulseOpacity
                                    : 0
                                )
                        }
                        .frame(width: 90, height: 90)
                        .cornerRadius(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 2)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                        )
                    }
                }
            }
        }
        .padding()
        .onChange(of: game.currentRound) { _, _ in
            triggerPulse()
        }
    }

    private func triggerPulse() {
        pulseOpacity = 0

        withAnimation(.easeIn(duration: 0.15)) {
            pulseOpacity = 1
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + (game.roundDuration - 0.45)) {
            withAnimation(.easeOut(duration: 0.3)) {
                pulseOpacity = 0
            }
        }
    }
}
