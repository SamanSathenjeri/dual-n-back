//
//  SettingsView.swift
//  DualNBack
//
//  Settings view for game configuration
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var game: DualNBackGame
    @Environment(\.presentationMode) var presentationMode
    @State private var nValue: Int = 2
    @State private var duration = 60.0
    @State private var isEditing = false
    @State private var roundTime = 2.0
    @State private var dailyReminder = true
    @State private var autoLevelAdjust = true
    @State private var haptics = false
    
    // UserDefaults keys
    private let nValueKey = "nValue"
    private let gameDurationKey = "gameDuration"
    private let roundDurationKey = "roundDuration"
    private let dailyReminderKey = "dailyReminderEnabled"
    private let autoLevelAdjustKey = "autoLevelAdjustEnabled"
    private let hapticsKey = "hapticsEnabled"
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    Stepper(value: $nValue, in: 1...10) {
                        Text("N Value: \(nValue)")
                    }
                    
                    Text("The N value determines how many rounds back you need to remember. Higher N = harder difficulty.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section() {
                    Slider(
                        value: $duration,
                        in: 20...120,
                        step: 1,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                    )
                    Text("Game Duration: \(Int(duration)) seconds")
                }
                
                Section() {
                    Slider(
                        value: $roundTime,
                        in: 0.5...4,
                        step: 0.1,
                        onEditingChanged: { editing in
                            isEditing = editing
                        }
                    )
                    Text("Round Duration: \(roundTime.formatted(.number.precision(.fractionLength(1)))) seconds")
                }
                
                Section() {
                    Toggle (
                        "Daily Reminder",
                        systemImage: "bell",
                        isOn: $dailyReminder
                    )
                    Toggle (
                        "Adaptive Challenge",
                        systemImage: "brain.head.profile",
                        isOn: $autoLevelAdjust
                    )
                    Toggle (
                        "Haptic Feedback",
                        systemImage: "hand.tap",
                        isOn: $haptics
                    )
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                loadSettings()
            }
            .onChange(of: nValue) { _, newValue in
                game.n = newValue
                saveSetting(key: nValueKey, value: newValue)
            }
            .onChange(of: duration) { _, newValue in
                game.gameDuration = Int(newValue)
                saveSetting(key: gameDurationKey, value: Int(newValue))
            }
            .onChange(of: roundTime) { _, newValue in
                game.roundDuration = newValue
                saveSetting(key: roundDurationKey, value: newValue)
            }
            .onChange(of: dailyReminder) { _, newValue in
                saveSetting(key: dailyReminderKey, value: newValue)
                if newValue {
                    NotificationManager.shared.scheduleDailyNotification()
                } else {
                    NotificationManager.shared.cancelDailyNotification()
                }
            }
            .onChange(of: autoLevelAdjust) { _, newValue in
                saveSetting(key: autoLevelAdjustKey, value: newValue)
            }
            .onChange(of: haptics) { _, newValue in
                saveSetting(key: hapticsKey, value: newValue)
                game.hapticsEnabled = newValue
            }
        }
    }
    
    private func loadSettings() {
        // Load from UserDefaults with defaults
        nValue = UserDefaults.standard.object(forKey: nValueKey) as? Int ?? 2
        duration = Double(UserDefaults.standard.object(forKey: gameDurationKey) as? Int ?? 60)
        roundTime = UserDefaults.standard.object(forKey: roundDurationKey) as? Double ?? 2.0
        
        // For booleans, check if key exists first to use proper defaults
        if UserDefaults.standard.object(forKey: dailyReminderKey) != nil {
            dailyReminder = UserDefaults.standard.bool(forKey: dailyReminderKey)
        } else {
            dailyReminder = true // default
        }
        
        if UserDefaults.standard.object(forKey: autoLevelAdjustKey) != nil {
            autoLevelAdjust = UserDefaults.standard.bool(forKey: autoLevelAdjustKey)
        } else {
            autoLevelAdjust = true // default
        }
        
        if UserDefaults.standard.object(forKey: hapticsKey) != nil {
            haptics = UserDefaults.standard.bool(forKey: hapticsKey)
        } else {
            haptics = false // default
        }
        
        // Sync with game
        game.n = nValue
        game.gameDuration = Int(duration)
        game.roundDuration = roundTime
        game.hapticsEnabled = haptics
        
        // Schedule notification if daily reminder is enabled
        if dailyReminder {
            NotificationManager.shared.checkAuthorizationStatus { authorized in
                if authorized {
                    NotificationManager.shared.scheduleDailyNotification()
                }
            }
        }
    }
    
    private func saveSetting<T>(key: String, value: T) {
        UserDefaults.standard.set(value, forKey: key)
    }
}
