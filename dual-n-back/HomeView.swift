//
//  HomeView.swift
//  DualNBack
//
//  Home tab view showing progress and history
//

import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                VStack(spacing: 4) {
                    BrainProgressView(
                        completed: vm.roundsCompletedToday,
                        goal: vm.dailyGoal
                    )
                }

//                Button(action: vm.playRound) {
//                    Text("▶ Play Next Round")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.black)
//                        .foregroundColor(.white)
//                        .cornerRadius(14)
//                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Your Progress")
                        .font(.headline)

                    HistoryGridView(history: vm.history)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

