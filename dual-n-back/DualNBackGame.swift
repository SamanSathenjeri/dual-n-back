//
//  DualNBackGame.swift
//  DualNBack
//
//  Game logic for Dual N-Back
//

import Foundation
import AVFoundation
import Combine
import SwiftUI

class DualNBackGame: ObservableObject {
    @Published var currentRound: Int = 0
    @Published var isPlaying: Bool = false
    @Published var gameEnded: Bool = false
    @Published var currentPosition: (row: Int, col: Int) = (0, 0)
    @Published var currentLetter: String = ""
    @Published var positionSubmitted: Bool = false
    @Published var audioSubmitted: Bool = false
    @Published var totalAudioAnswers: Int = 0
    @Published var correctAudioAnswers: Int = 0
    @Published var totalPositionAnswers: Int = 0
    @Published var correctPositionAnswers: Int = 0
    @Published var timeRemaining: Int = 60
    @Published var positionResult: AnswerResult = .none
    @Published var audioResult: AnswerResult = .none
    @Published var gameEndPerformance: GamePerformance = .needsPractice

    private var positionHistory: [(row: Int, col: Int)] = []
    private var audioHistory: [String] = []
    private var roundTimer: Timer?
    private var gameTimer: Timer?
    private var missedResetTimer: Timer?
    private let letters = ["a", "b", "c", "f", "h", "k", "j", "l", "o"]
    var n: Int = 2 { didSet { resetGame()}}
    var roundDuration: TimeInterval = 2.0 { didSet { resetGame() }}
    var gameDuration: Int = 60 { didSet { resetGame() }}
    
    func startGame() {
        resetGame()
        isPlaying = true
        
        // Start game duration timer
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.endGame()
                }
            }
        }
        
        nextRound()
    }
    
    func endGame() {
        isPlaying = false
        roundTimer?.invalidate()
        roundTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
        missedResetTimer?.invalidate()
        missedResetTimer = nil
        
        calculatePerformance()
        gameEnded = true
    }
    
    func resetGame() {
        isPlaying = false
        gameEnded = false
        roundTimer?.invalidate()
        roundTimer = nil
        gameTimer?.invalidate()
        gameTimer = nil
        missedResetTimer?.invalidate()
        missedResetTimer = nil
        currentRound = 0
        positionHistory = []
        audioHistory = []
        currentPosition = (0, 0)
        currentLetter = letters.randomElement() ?? "a"
        totalAudioAnswers = 0
        correctAudioAnswers = 0
        totalPositionAnswers = 0
        correctPositionAnswers = 0
        timeRemaining = gameDuration
        gameEndPerformance = .needsPractice
        positionResult = .none
        audioResult = .none
    }
    
    private func calculatePerformance() {
        let totalAnswers = totalAudioAnswers + totalPositionAnswers
        guard totalAnswers > 0 else {
            gameEndPerformance = .needsPractice
            return
        }
        
        let totalCorrect = correctAudioAnswers + correctPositionAnswers
        let accuracy = Double(totalCorrect) / Double(totalAnswers)
        
        switch accuracy {
        case 0.90...1.0:
            gameEndPerformance = .excellent
        case 0.75..<0.90:
            gameEndPerformance = .great
        case 0.60..<0.75:
            gameEndPerformance = .good
        case 0.40..<0.60:
            gameEndPerformance = .fair
        default:
            gameEndPerformance = .needsPractice
        }
    }
    
    func nextRound() {
        guard isPlaying else { return }
        
        // Check for missed answers from the previous round BEFORE resetting
        var positionMissedFromPreviousRound = false
        var audioMissedFromPreviousRound = false
        
        // Only check for missed answers if we have enough rounds to compare
        if currentRound > n {
            // Check if user didn't submit position answer and there was an expected match
            if !positionSubmitted && positionHistory.count > n {
                let previousPos = positionHistory[currentRound - 1]
                let nBackPos = positionHistory[currentRound - 1 - n]
                let expectedPositionMatch = previousPos.row == nBackPos.row && previousPos.col == nBackPos.col
                if expectedPositionMatch {
                    positionMissedFromPreviousRound = true
                }
            }
            
            // Check if user didn't submit audio answer and there was an expected match
            if !audioSubmitted && audioHistory.count > n {
                let previousAudio = audioHistory[currentRound - 1]
                let nBackAudio = audioHistory[currentRound - 1 - n]
                let expectedAudioMatch = previousAudio == nBackAudio
                if expectedAudioMatch {
                    audioMissedFromPreviousRound = true
                }
            }
        }
        
        // Reset answer state for new round
        positionSubmitted = false
        audioSubmitted = false
        positionResult = .none
        audioResult = .none
        
        // Set missed status from previous round if there were misses
        if positionMissedFromPreviousRound {
            positionResult = .missed
        }
        if audioMissedFromPreviousRound {
            audioResult = .missed
        }
        
        // Reset missed answers after a brief delay so they don't persist throughout the round
        // User answers will overwrite them immediately
        missedResetTimer?.invalidate()
        if positionMissedFromPreviousRound || audioMissedFromPreviousRound {
            missedResetTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    // Only reset if still showing missed (user hasn't answered yet)
                    if self.positionResult == .missed {
                        self.positionResult = .none
                    }
                    if self.audioResult == .missed {
                        self.audioResult = .none
                    }
                }
            }
        }
        
        // Generate random position (3x3 grid, indices 0-2)
        let newRow = Int.random(in: 0..<3)
        let newCol = Int.random(in: 0..<3)
        currentPosition = (row: newRow, col: newCol)
        
        // Generate random letter
        currentLetter = letters.randomElement() ?? "a"
        if isPlaying {
            AudioManager.shared.speakLetter(currentLetter)
        }
        
        // Store in history
        positionHistory.append(currentPosition)
        audioHistory.append(currentLetter)
        
        currentRound += 1
        
        // Schedule next round
        roundTimer?.invalidate()
        roundTimer = Timer.scheduledTimer(withTimeInterval: roundDuration, repeats: false) { [weak self] _ in
            self?.nextRound()
        }
    }
    
    func checkPositionMatch(positionMatch: Bool){
        guard isPlaying && currentRound > n else { return }
        // guard positionHistory.count > n && positionSubmitted == true else { return }
        guard positionHistory.count > n else { return }
        let currentPos = positionHistory[currentRound - 1]
        let nBackPos = positionHistory[currentRound - 1 - n]
        let expectedPositionMatch = currentPos.row == nBackPos.row && currentPos.col == nBackPos.col

        // Only set submitted if user actually answered (positionMatch is true or false from user action)
        // If this is called at round end with no answer, positionMatch will be false but we want to detect missed
        let wasAlreadySubmitted = positionSubmitted
        if !wasAlreadySubmitted {
            positionSubmitted = true
        }

        // If there is a position match, then count up 
        if expectedPositionMatch == true || positionMatch == true{
            totalPositionAnswers += 1
        }

        // Track position answer - user always answers (either match or no match)
        if expectedPositionMatch == true && positionMatch == true {
            correctPositionAnswers += 1
            positionResult = .correct
        } 
        else if (expectedPositionMatch == false && positionMatch == true) {
            positionResult = .wrong
        }
        else if (expectedPositionMatch == true && positionMatch == false) {
            // Only set missed if user didn't already answer (to allow overwriting)
            if !wasAlreadySubmitted {
                print("Missed Position")
                positionResult = .missed
            }
        }
    }
    
    func checkAudioMatch(audioMatch: Bool){
        guard isPlaying && currentRound > n else { return }
        // guard audioHistory.count > n  && audioSubmitted == true else { return }
        guard audioHistory.count > n else { return }
        let currentAudio = audioHistory[currentRound - 1]
        let nBackAudio = audioHistory[currentRound - 1 - n]
        let expectedAudioMatch = currentAudio == nBackAudio

        // Only set submitted if user actually answered (audioMatch is true or false from user action)
        // If this is called at round end with no answer, audioMatch will be false but we want to detect missed
        let wasAlreadySubmitted = audioSubmitted
        if !wasAlreadySubmitted {
            audioSubmitted = true
        }

        // If there is a audio match, then count up 
        if expectedAudioMatch == true || audioMatch == true {
            totalAudioAnswers += 1
        }

        // Track audio answer - user always answers (either match or no match)
        if expectedAudioMatch == true && audioMatch == true {
            correctAudioAnswers += 1
            audioResult = .correct
        } 
        else if (expectedAudioMatch == false && audioMatch == true){
            audioResult = .wrong
        }
        else if (expectedAudioMatch == true && audioMatch == false) {
            // Only set missed if user didn't already answer (to allow overwriting)
            if !wasAlreadySubmitted {
                print("Missed Audio")
                audioResult = .missed
            }
        }
    }
    
    deinit {
        roundTimer?.invalidate()
        gameTimer?.invalidate()
        missedResetTimer?.invalidate()
    }
}

enum GamePerformance {
    case excellent
    case great
    case good
    case fair
    case needsPractice
    
    var title: String {
        switch self {
        case .excellent:
            return "🌟 Excellent Performance!"
        case .great:
            return "🎉 Great Job!"
        case .good:
            return "👍 Good Work!"
        case .fair:
            return "💪 Keep Practicing!"
        case .needsPractice:
            return "📚 Needs More Practice"
        }
    }
    
    var message: String {
        switch self {
        case .excellent:
            return "Outstanding! You're a dual n-back master! Your memory and focus are exceptional."
        case .great:
            return "Well done! You're getting really good at this. Keep up the great work!"
        case .good:
            return "Nice work! You're making good progress. A bit more practice and you'll be great!"
        case .fair:
            return "You're on the right track! Keep practicing to improve your score."
        case .needsPractice:
            return "Don't give up! Practice makes perfect. Try again and focus on remembering the patterns."
        }
    }
}

enum AnswerResult {
    case none 
    case correct
    case wrong
    case missed
}