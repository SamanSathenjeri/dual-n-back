//
//  HapticManager.swift
//  DualNBack
//
//  Manages haptic feedback for game interactions
//

import UIKit

class HapticManager {
    static let shared = HapticManager()
    
    private init() {}
    
    /// Trigger haptic feedback for a correct answer
    func playCorrect() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    /// Trigger haptic feedback for a wrong answer
    func playWrong() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    /// Trigger haptic feedback for a missed answer
    func playMissed() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}
