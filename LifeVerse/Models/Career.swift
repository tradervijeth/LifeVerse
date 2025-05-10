//
//  Career.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//

import Foundation

struct Career: Codable, Identifiable {
    var id = UUID()
    var title: String
    var company: String
    var salary: Double
    var performanceRating: Int = 50 // 0-100
    var yearsAtJob: Int = 0
    var level: UnifiedCareerLevel = .entry
    var specialization: UnifiedCareerSpecialization?
    var promotionYearsRequired: Int = 3

    // Calculate salary growth per year based on performance and level
    func calculateSalaryGrowth() -> Double {
        let baseGrowth = 0.02 // 2% base salary growth

        // Adjust for performance (0-100 scale)
        let performanceFactor = Double(performanceRating) / 50.0 // 1.0 is average

        // Adjust for career level using the level's salary multiplier
        let levelFactor = level.salaryMultiplier() / 2.0

        return salary * baseGrowth * performanceFactor * levelFactor
    }

    // Check if ready for promotion
    func isReadyForPromotion() -> Bool {
        return yearsAtJob >= promotionYearsRequired && performanceRating >= 70
    }

    // Get next career level
    func getNextLevel() -> UnifiedCareerLevel? {
        return level.nextLevel()
    }
}

