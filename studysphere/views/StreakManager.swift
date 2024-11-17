//
//  StreakManager.swift
//  studysphere
//
//  Created by admin64 on 14/11/24.
//


import Foundation

class StreakManager {
    static let shared = StreakManager()
    private let lastOpenKey = "lastOpenDate"
    private let streakCountKey = "streakCount"
    
    var currentStreak: Int {
        return UserDefaults.standard.integer(forKey: streakCountKey)
    }

    func updateStreak() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastOpen = UserDefaults.standard.object(forKey: lastOpenKey) as? Date {
            let daysDifference = Calendar.current.dateComponents([.day], from: lastOpen, to: today).day ?? 0 //check the diff
            
            switch daysDifference {
            case 0:
                return
            case 1:
                incrementStreak() // increment the streak
            default:
                startNewStreak() // defaulty it will start new 
            }
        } else {
            //it will start a new streak
            startNewStreak()
        }
       
        UserDefaults.standard.set(today, forKey: lastOpenKey)
    }
   
    private func incrementStreak() {
        let newStreak = currentStreak + 1
        UserDefaults.standard.set(newStreak, forKey: streakCountKey)
    }
    
    private func startNewStreak() {
        // Start a new streak with 1 instead of 0
        UserDefaults.standard.set(1, forKey: streakCountKey)
    }
}
