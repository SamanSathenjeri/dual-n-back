//
//  GridView.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/31/25.
//

import SwiftUI

struct GridView: View {
    
    @ObservedObject var game: DualNBackGame
    
    var body: some View {
        // 3x3 Grid
        VStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { row in
                HStack(spacing: 5) {
                    ForEach(0..<3, id: \.self) { col in
                        Rectangle()
                            .fill(game.currentPosition.row == row && game.currentPosition.col == col ? Color.blue : Color.gray.opacity(0.3))
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
    }
}
