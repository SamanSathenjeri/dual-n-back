//
//  BrainModel.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/31/25.
//

import SwiftUI
import Combine
import Foundation

struct DailyProgress: Identifiable, Codable {
    let id: UUID
    let date: Date
    let completedRounds: Int
    let goal: Int
    
    init(id: UUID = UUID(), date: Date, completedRounds: Int, goal: Int) {
        self.id = id
        self.date = date
        self.completedRounds = completedRounds
        self.goal = goal
    }
}

struct BrainProgressView: View {
    let completed: Int
    let goal: Int

    private var fraction: Double {
        min(Double(completed) / Double(goal), 1)
    }

    var body: some View {
        VStack(spacing: 12) {
            ProgressRing(
                fraction: fraction,
                lineWidth: 8,
                size: 140,
                color: .pink
            )

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
    let calendar = Calendar.current

    let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        let days = calendar.daysInMonth(for: Date())

        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(days, id: \.self) { date in
                if let progress = history.first(where: {
                    calendar.isDate($0.date, inSameDayAs: date)
                }) {
                    SmallBrainView(progress: progress)
                } else {
                    ProgressRing(
                        fraction: 0,
                        lineWidth: 4,
                        size: 32,
                        color: .gray.opacity(0.2)
                    )
                }
            }
        }
    }
}

struct SmallBrainView: View {
    let progress: DailyProgress

    private var fraction: Double {
        min(Double(progress.completedRounds) / Double(progress.goal), 1)
    }

    var body: some View {
        ProgressRing(
            fraction: fraction,
            lineWidth: 4,
            size: 32,
            color: fraction >= 1 ? .pink : .pink.opacity(0.6)
        )
    }
}

final class HomeViewModel: ObservableObject {
    @Published var dailyGoal: Int = 5
    @Published var roundsCompletedToday: Int = 0
    @Published var history: [DailyProgress] = []
    
    // UserDefaults keys
    private let dailyGoalKey = "homeDailyGoal"
    private let roundsCompletedTodayKey = "homeRoundsCompletedToday"
    private let lastResetDateKey = "homeLastResetDate"
    private let historyKey = "homeHistory"
    
    private let calendar = Calendar.current
    
    var fillFraction: Double {
        min(Double(roundsCompletedToday) / Double(dailyGoal), 1.0)
    }
    
    init() {
        loadData()
        checkDailyReset()
    }
    
    func playRound() {
        guard roundsCompletedToday < dailyGoal else { return }
        roundsCompletedToday += 1
        saveData()
    }
    
    func finalizeToday() {
        let today = calendar.startOfDay(for: Date())
        
        // Remove any existing entry for today
        history.removeAll {
            calendar.isDate($0.date, inSameDayAs: today)
        }
        
        // Add today's progress
        history.append(
            DailyProgress(
                date: today,
                completedRounds: roundsCompletedToday,
                goal: dailyGoal
            )
        )
        
        saveData()
    }
    
    func checkDailyReset() {
        let today = calendar.startOfDay(for: Date())
        let lastResetDate = UserDefaults.standard.object(forKey: lastResetDateKey) as? Date
        
        if let lastReset = lastResetDate {
            if !calendar.isDate(lastReset, inSameDayAs: today) {
                // New day - save yesterday's progress before resetting
                let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? lastReset
                
                // Remove any existing entry for yesterday
                history.removeAll {
                    calendar.isDate($0.date, inSameDayAs: yesterday)
                }
                
                // Add yesterday's progress
                history.append(
                    DailyProgress(
                        date: yesterday,
                        completedRounds: roundsCompletedToday,
                        goal: dailyGoal
                    )
                )
                
                // Reset for new day
                roundsCompletedToday = 0
                UserDefaults.standard.set(today, forKey: lastResetDateKey)
                saveData()
            }
        } else {
            // First time - set reset date
            UserDefaults.standard.set(today, forKey: lastResetDateKey)
        }
    }
    
    private func loadData() {
        // Load daily goal
        dailyGoal = UserDefaults.standard.object(forKey: dailyGoalKey) as? Int ?? 5
        
        // Load rounds completed today
        roundsCompletedToday = UserDefaults.standard.object(forKey: roundsCompletedTodayKey) as? Int ?? 0
        
        // Load history
        if let historyData = UserDefaults.standard.data(forKey: historyKey),
           let decodedHistory = try? JSONDecoder().decode([DailyProgress].self, from: historyData) {
            history = decodedHistory
        } else {
            history = []
        }
    }
    
    private func saveData() {
        // Save daily goal
        UserDefaults.standard.set(dailyGoal, forKey: dailyGoalKey)
        
        // Save rounds completed today
        UserDefaults.standard.set(roundsCompletedToday, forKey: roundsCompletedTodayKey)
        
        // Save last reset date
        let today = calendar.startOfDay(for: Date())
        UserDefaults.standard.set(today, forKey: lastResetDateKey)
        
        // Save history
        if let encodedHistory = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(encodedHistory, forKey: historyKey)
        }
    }
}
