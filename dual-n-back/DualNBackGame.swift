//
//  DualNBackGame.swift
//  DualNBack
//
//  Game logic for Dual N-Back
//

import Foundation
import AVFoundation
import Combine

class DualNBackGame: ObservableObject {
    @Published var currentRound: Int = 0
    @Published var score: Int = 0
    @Published var isPlaying: Bool = false
    @Published var currentPosition: (row: Int, col: Int) = (0, 0)
    @Published var currentLetter: String = ""
    @Published var showFeedback: Bool = false
    @Published var feedbackMessage: String = ""
    @Published var correctPosition: Bool = false
    @Published var correctAudio: Bool = false
    @Published var answerSubmitted: Bool = false
    
    var n: Int = 2 {
        didSet {
            resetGame()
        }
    }
    
    private var positionHistory: [(row: Int, col: Int)] = []
    private var audioHistory: [String] = []
    private var timer: Timer?
    private let roundDuration: TimeInterval = 3.0
    private let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
    
    func startGame() {
        resetGame()
        isPlaying = true
        positionHistory = []
        audioHistory = []
        currentRound = 0
        score = 0
        nextRound()
    }
    
    func stopGame() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    func resetGame() {
        stopGame()
        currentRound = 0
        score = 0
        positionHistory = []
        audioHistory = []
        currentPosition = (0, 0)
        currentLetter = ""
        showFeedback = false
    }
    
    func nextRound() {
        guard isPlaying else { return }
        
        // Reset answer state for new round
        answerSubmitted = false
        showFeedback = false
        
        // Generate random position (3x3 grid, indices 0-2)
        let newRow = Int.random(in: 0..<3)
        let newCol = Int.random(in: 0..<3)
        currentPosition = (row: newRow, col: newCol)
        
        // Generate random letter
        currentLetter = letters.randomElement() ?? "A"
        
        // Store in history
        positionHistory.append(currentPosition)
        audioHistory.append(currentLetter)
        
        currentRound += 1
        
        // Schedule next round
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: roundDuration, repeats: false) { [weak self] _ in
            self?.nextRound()
        }
    }
    
    func checkAnswer(positionMatch: Bool, audioMatch: Bool) {
        guard isPlaying && currentRound > n && !answerSubmitted else { return }
        
        answerSubmitted = true
        
        let expectedPositionMatch = checkPositionMatch()
        let expectedAudioMatch = checkAudioMatch()
        
        var roundScore = 0
        var messages: [String] = []
        
        if positionMatch == expectedPositionMatch {
            roundScore += 1
            correctPosition = true
            messages.append("Position: ✓")
        } else {
            correctPosition = false
            messages.append("Position: ✗")
        }
        
        if audioMatch == expectedAudioMatch {
            roundScore += 1
            correctAudio = true
            messages.append("Audio: ✓")
        } else {
            correctAudio = false
            messages.append("Audio: ✗")
        }
        
        score += roundScore
        feedbackMessage = messages.joined(separator: " ")
        showFeedback = true
        
        // Hide feedback after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showFeedback = false
        }
    }
    
    private func checkPositionMatch() -> Bool {
        guard positionHistory.count > n else { return false }
        let currentPos = positionHistory[currentRound - 1]
        let nBackPos = positionHistory[currentRound - 1 - n]
        return currentPos.row == nBackPos.row && currentPos.col == nBackPos.col
    }
    
    private func checkAudioMatch() -> Bool {
        guard audioHistory.count > n else { return false }
        let currentAudio = audioHistory[currentRound - 1]
        let nBackAudio = audioHistory[currentRound - 1 - n]
        return currentAudio == nBackAudio
    }
    
    deinit {
        timer?.invalidate()
    }
}

