//
//  AudioManager.swift
//  DualNBack
//
//  Handles audio playback for letters
//

import AVFoundation
import Foundation
import Combine

class AudioManager: ObservableObject {
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    func speakLetter(_ letter: String) {
        let utterance = AVSpeechUtterance(string: letter)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.stopSpeaking(at: .immediate)
        speechSynthesizer.speak(utterance)
    }
    
    func stopSpeaking() {
        speechSynthesizer.stopSpeaking(at: .immediate)
    }
}

