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
                nValue = game.n
                duration = Double(game.gameDuration)
                roundTime = game.roundDuration
            }
            .onChange(of: nValue) { _, newValue in
                game.n = newValue
            }
            .onChange(of: duration) { _, newValue in
                game.gameDuration = Int(newValue)
            }
            .onChange(of: roundTime) { _, newValue in
                game.roundDuration = newValue
            }
        }
    }
}

