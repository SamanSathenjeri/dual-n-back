//
//  ContentView.swift
//  DualNBack
//
//  Main game view
//

import SwiftUI

struct ContentView: View {
    @StateObject private var game = DualNBackGame()
    @StateObject private var audioManager = AudioManager()
    @State private var showingSettings = false
    @State private var positionMatch = false
    @State private var audioMatch = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header with score and round info
                VStack(spacing: 10) {
                    HStack {
                        Text("Round: \(game.currentRound)")
                            .font(.headline)
                        Spacer()
                        Text("Score: \(game.score)")
                            .font(.headline)
                    }
                    .padding(.horizontal)
                    
                    Text("N = \(game.n)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // 3x3 Grid
                VStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { row in
                        HStack(spacing: 10) {
                            ForEach(0..<3, id: \.self) { col in
                                Rectangle()
                                    .fill(game.currentPosition.row == row && game.currentPosition.col == col ? Color.blue : Color.gray.opacity(0.3))
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                            }
                        }
                    }
                }
                .padding()
                
                // Current letter display
                Text(game.currentLetter)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.blue)
                    .padding()
                    .frame(width: 100, height: 100)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                
                // Feedback message
                if game.showFeedback {
                    VStack(spacing: 5) {
                        Text(game.feedbackMessage)
                            .font(.headline)
                            .foregroundColor(.primary)
                        if game.correctPosition && game.correctAudio {
                            Text("Perfect!")
                                .font(.subheadline)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(10)
                }
                
                // Answer buttons
                if game.isPlaying && game.currentRound > game.n && !game.answerSubmitted {
                    VStack(spacing: 15) {
                        Text("Does this match \(game.n) rounds ago?")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 20) {
                            Button(action: {
                                positionMatch.toggle()
                            }) {
                                Text("Position")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(positionMatch ? Color.green : Color.blue)
                                    .cornerRadius(10)
                            }
                            
                            Button(action: {
                                audioMatch.toggle()
                            }) {
                                Text("Audio")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(audioMatch ? Color.green : Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                        
                        Button(action: {
                            game.checkAnswer(positionMatch: positionMatch, audioMatch: audioMatch)
                        }) {
                            Text("Submit Answer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Control buttons
                VStack(spacing: 15) {
                    if !game.isPlaying {
                        Button(action: {
                            game.startGame()
                            // Play the first letter
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                audioManager.speakLetter(game.currentLetter)
                            }
                        }) {
                            Text("Start Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green)
                                .cornerRadius(10)
                        }
                    } else {
                        Button(action: {
                            game.stopGame()
                            audioManager.stopSpeaking()
                        }) {
                            Text("Stop Game")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Dual N-Back")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(game: game)
            }
            .onChange(of: game.currentLetter) { _, newLetter in
                if game.isPlaying {
                    audioManager.speakLetter(newLetter)
                }
            }
            .onChange(of: game.currentRound) { _, _ in
                // Reset button states when new round starts
                positionMatch = false
                audioMatch = false
            }
        }
    }
}

struct SettingsView: View {
    @ObservedObject var game: DualNBackGame
    @Environment(\.presentationMode) var presentationMode
    @State private var nValue: Int = 2
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Game Settings")) {
                    Stepper(value: $nValue, in: 1...5) {
                        Text("N Value: \(nValue)")
                    }
                    
                    Text("The N value determines how many rounds back you need to remember. Higher N = harder difficulty.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        game.n = nValue
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                nValue = game.n
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

