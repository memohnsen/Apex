//
//  ScoreCalculation.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/23/25.
//

import Foundation

@Observable
class ApexScore {
    // 1000 points overall
    // 250 max per category
    
    var fortyDash: String = ""
    var maxToss: String = ""
    var theBroad: String = ""
    var verticalJump: String = ""
    var thePull: String = ""
    var thePush: String = ""
    var theMile: String = ""
    
    var speedScore: Int {
        //Speed - 250pts
        //40yd dash The Forty - 4.21 sec (max) to 6.0 sec (min)
        guard let time = Double(fortyDash), time >= 4.3, time <= 5.4 else {
            return 0
        }
        
        // Linear scale: 4.21 = 250 pts, 6.0 = 0 pts
        let maxTime = 5.4
        let minTime = 4.4
        let maxPoints = 250.0
        
        let score = maxPoints * (maxTime - time) / (maxTime - minTime)
        return Int(score.rounded())
    }
    
    var powerScore: Int {
        //Power - 250 pts total
        //Max toss - 450in (min) to 900in (max)
        //The broad - 72in (min) to 138in (max)
        //Vertical jump - 15in (min) to 45in (max)
        
        guard let toss = Int(maxToss), let broad = Int(theBroad), let vertical = Int(verticalJump) else {
            return 0
        }
        
        // Calculate percentage for each event, then scale to 250 total
        let tossPercent = calculatePercentage(value: Double(toss), min: 450, max: 900)
        let broadPercent = calculatePercentage(value: Double(broad), min: 72, max: 138)
        let verticalPercent = calculatePercentage(value: Double(vertical), min: 15, max: 45)
        
        // Average the three percentages and scale to 250 points
        let averagePercent = (tossPercent + broadPercent + verticalPercent) / 3.0
        let score = 250.0 * averagePercent
        
        return Int(score.rounded())
    }
    
    var tossScore: Int {
        let tossInches = parseFeetInches(maxToss)
        guard tossInches > 0 else { return 0 }
        
        let tossPercent = calculatePercentage(value: Double(tossInches), min: 450, max: 900)
        let score = 83.33 * tossPercent // Max toss is 1/3 of power score (250/3 ≈ 83.33)
        
        return Int(score.rounded())
    }
    
    var broadScore: Int {
        let broadInches = parseFeetInches(theBroad)
        guard broadInches > 0 else { return 0 }
        
        let broadPercent = calculatePercentage(value: Double(broadInches), min: 72, max: 138)
        let score = 83.33 * broadPercent // The broad is 1/3 of power score (250/3 ≈ 83.33)
        
        return Int(score.rounded())
    }
    
    var verticalScore: Int {
        let verticalInches = parseInches(verticalJump)
        guard verticalInches > 0 else { return 0 }
        
        let verticalPercent = calculatePercentage(value: Double(verticalInches), min: 15, max: 45)
        let score = 83.33 * verticalPercent // Vertical is 1/3 of power score (250/3 ≈ 83.33)
        
        return Int(score.rounded())
    }
    
    var strengthScore: Int {
        //Strength - 250 pts = 125 pts each
        //The pull - 4 (min) to 40 (max) reps
        //The push - 4 (min) to 40 (max) reps
        
        guard let pull = Int(thePull), let push = Int(thePush) else {
            return 0
        }
        
        let pullScore = calculateLinearScore(value: Double(pull), min: 4, max: 40, maxPoints: 125)
        let pushScore = calculateLinearScore(value: Double(push), min: 4, max: 40, maxPoints: 125)
        
        return Int((pullScore + pushScore).rounded())
    }
    
    var pullScore: Int {
        guard let pull = Int(thePull) else {
            return 0
        }
        
        let pullScore = calculateLinearScore(value: Double(pull), min: 4, max: 40, maxPoints: 125)
        
        return Int(pullScore)
    }
    
    var pushScore: Int {
        guard let push = Int(thePush) else {
            return 0
        }
        
        let pushScore = calculateLinearScore(value: Double(push), min: 4, max: 40, maxPoints: 125)

        return Int(pushScore)
    }
    
    var enduranceScore: Int {
        //Endurance - 250 pts
        //1MR The Mile - 4:30 (max) to 10:06 (min)
        
        // Parse time format "M:SS" or "MM:SS"
        let components = theMile.split(separator: ":")
        guard components.count == 2,
              let minutes = Int(components[0]),
              let seconds = Int(components[1]),
              seconds < 60 else {
            return 0
        }
        
        let totalSeconds = Double(minutes * 60 + seconds)
        
        // 4:00 (240 sec) = 250 pts, 10:00 (600 sec) = 0 pts
        let maxTime = 606.0 // 10:06
        let minTime = 260.0 // 4:30
        let maxPoints = 250.0
        
        let score = maxPoints * (maxTime - totalSeconds) / (maxTime - minTime)
        return Int(max(0, score.rounded()))
    }
    
    var totalScore: Int {
        speedScore + powerScore + strengthScore + enduranceScore
    }
    
    private func calculateLinearScore(value: Double, min: Double, max: Double, maxPoints: Double) -> Double {
        guard value >= min, value <= max else {
            if value < min { return 0 }
            return maxPoints
        }
        
        return maxPoints * (value - min) / (max - min)
    }
    
    private func calculatePercentage(value: Double, min: Double, max: Double) -> Double {
        guard value >= min, value <= max else {
            if value < min { return 0.0 }
            return 1.0
        }
        
        return (value - min) / (max - min)
    }
    
    private func parseFeetInches(_ input: String) -> Int {
        let cleaned = input.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "'", with: " ")
        let parts = cleaned.split(separator: " ")
        
        guard parts.count >= 1 else { return 0 }
        
        let feet = Int(parts[0]) ?? 0
        let inches = parts.count > 1 ? Int(parts[1]) ?? 0 : 0
        
        return (feet * 12) + inches
    }
    
    private func parseInches(_ input: String) -> Int {
        let cleaned = input.replacingOccurrences(of: "\"", with: "").trimmingCharacters(in: .whitespaces)
        return Int(cleaned) ?? 0
    }
    
    var hasCompletedForm: Bool {
        if fortyDash.isEmpty || maxToss.isEmpty || theBroad.isEmpty ||
           verticalJump.isEmpty || thePull.isEmpty || thePush.isEmpty || theMile.isEmpty {
            return false
        }
        
        // fortyDash must contain a decimal
        if !fortyDash.contains(".") {
            return false
        }
        
        // maxToss, theBroad, and verticalJump must contain exactly 2 or 3 digits
        let tossDigits = maxToss.filter { $0.isNumber }
        let broadDigits = theBroad.filter { $0.isNumber }
        let verticalDigits = verticalJump.filter { $0.isNumber }
        
        if tossDigits.count < 2 || broadDigits.count < 2 || verticalDigits.count < 2 {
            return false
        }
        
        // thePull and thePush must contain numbers only, no more than 2 digits
        let pullDigits = thePull.filter { $0.isNumber }
        let pushDigits = thePush.filter { $0.isNumber }
        
        if pullDigits.count == 0 || pullDigits.count > 2 || thePull != pullDigits {
            return false
        }
        
        if pushDigits.count == 0 || pushDigits.count > 2 || thePush != pushDigits {
            return false
        }
        
        // theMile must contain a colon and have 3-4 numbers
        if !theMile.contains(":") {
            return false
        }
        
        let mileDigits = theMile.filter { $0.isNumber }
        if mileDigits.count < 3 || mileDigits.count > 4 {
            return false
        }
        
        return true
    }
}
