//
//  USSalaryData.swift
//  LifeVerse
//
//  Created to fix missing USSalaryData class
//

import Foundation

/// Class that provides realistic US salary data for the game
class USSalaryData {

    /// Calculate a realistic salary based on job title, industry, education, and career level
    static func calculateRealisticSalary(
        jobTitle: String,
        industry: String,
        education: Education,
        level: UnifiedCareerLevel
    ) -> Double {
        // Get base salary range for education level
        let (minSalary, maxSalary) = getSalaryRangeForEducation(education)

        // Adjust for career level
        let levelMultiplier = getMultiplierForLevel(level)

        // Adjust for industry
        let industryMultiplier = getMultiplierForIndustry(industry)

        // Calculate base salary with some randomness
        let baseSalary = Double.random(in: minSalary...maxSalary)

        // Apply multipliers
        let adjustedSalary = baseSalary * levelMultiplier * industryMultiplier

        // Round to nearest thousand
        return round(adjustedSalary / 1000) * 1000
    }

    /// Get salary range based on education level
    static func getSalaryRangeForEducation(_ education: Education) -> (Double, Double) {
        switch education {
        case .none:
            return (20000, 30000)
        case .elementarySchool:
            return (20000, 30000)
        case .middleSchool:
            return (25000, 35000)
        case .highSchool:
            return (30000, 45000)
        case .associatesDegree:
            return (35000, 55000)
        case .bachelorsDegree:
            return (45000, 75000)
        case .mastersDegree:
            return (60000, 100000)
        case .doctoralDegree:
            return (80000, 150000)
        }
    }

    /// Get multiplier for career level
    private static func getMultiplierForLevel(_ level: UnifiedCareerLevel) -> Double {
        switch level {
        case .entry:
            return 1.0
        case .junior:
            return 1.2
        case .associate, .mid:
            return 1.5
        case .senior:
            return 2.0
        case .lead:
            return 2.5
        case .manager:
            return 3.0
        case .director:
            return 4.0
        case .executive, .cLevel:
            return 5.0
        }
    }

    /// Get multiplier for industry
    private static func getMultiplierForIndustry(_ industry: String) -> Double {
        // Higher paying industries
        if ["Technology", "Finance", "Healthcare", "Legal", "Energy"].contains(industry) {
            return 1.3
        }

        // Medium paying industries
        else if ["Engineering", "Science and Research", "Government", "Manufacturing"].contains(industry) {
            return 1.1
        }

        // Lower paying industries
        else if ["Retail", "Hospitality", "Education"].contains(industry) {
            return 0.9
        }

        // Default for other industries
        return 1.0
    }
}
