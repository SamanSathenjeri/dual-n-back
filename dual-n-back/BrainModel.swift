//
//  BrainModel.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/31/25.
//

import SwiftUI
import Combine

struct DailyProgress: Identifiable {
    let id = UUID()
    let date: Date
    let completedRounds: Int
    let goal: Int
}

struct BrainProgressView: View {
    let completed: Int
    let goal: Int

    var body: some View {
        VStack(spacing: 12) {

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: CGFloat(min(Double(completed) / Double(goal), 1)))
                    .stroke(Color.pink, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 0.3), value: completed)
            }
            .frame(width: 140, height: 140)

            HStack(spacing: 6) {
                ForEach(0..<goal, id: \.self) { index in
                    Circle()
                        .fill(index < completed ? Color.pink : Color.gray.opacity(0.3))
                        .frame(width: 10, height: 10)
                }
            }

            Text("\(completed) of \(goal) rounds completed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct HistoryGridView: View {
    let history: [DailyProgress]

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(history) { day in
                SmallBrainView(progress: day)
            }
        }
    }
}

struct SmallBrainView: View {
    let progress: DailyProgress

    var body: some View {
        Circle()
            .fill(color)
            .frame(height: 32)
    }

    private var color: Color {
        let fraction = Double(progress.completedRounds) / Double(progress.goal)
        if fraction == 0 {
            return Color.gray.opacity(0.2)
        } else if fraction < 1 {
            return Color.pink.opacity(0.6)
        } else {
            return Color.pink
        }
    }
}

final class HomeViewModel: ObservableObject {
    @Published var dailyGoal: Int = 5
    @Published var roundsCompletedToday: Int = 3

    @Published var history: [DailyProgress] = []

    var fillFraction: Double {
        min(Double(roundsCompletedToday) / Double(dailyGoal), 1.0)
    }

    func playRound() {
        guard roundsCompletedToday < dailyGoal else { return }
        roundsCompletedToday += 1
    }
}
