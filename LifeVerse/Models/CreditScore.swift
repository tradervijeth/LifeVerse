//
//  CreditScore.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Represents credit score categories and related functionality
enum CreditScoreRating: String, Codable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case veryGood = "Very Good"
    case excellent = "Excellent"
    
    // Get interest rate modifier based on credit score
    func interestRateModifier() -> Double {
        switch self {
        case .poor: return 0.05 // +5%
        case .fair: return 0.03 // +3%
        case .good: return 0.0 // No change
        case .veryGood: return -0.01 // -1%
        case .excellent: return -0.02 // -2%
        }
    }
    
    // Get the range for this credit score category
    func range() -> ClosedRange<Int> {
        switch self {
        case .poor: return 300...579
        case .fair: return 580...669
        case .good: return 670...739
        case .veryGood: return 740...799
        case .excellent: return 800...850
        }
    }
    
    // Get description of credit score category
    func description() -> String {
        switch self {
        case .poor:
            return "Difficult to qualify for most loans and credit cards. High interest rates."
        case .fair:
            return "May qualify for loans but with higher interest rates."
        case .good:
            return "Qualify for most loans with competitive interest rates."
        case .veryGood:
            return "Qualify for loans with favorable terms and lower interest rates."
        case .excellent:
            return "Qualify for the best terms and lowest interest rates available."
        }
    }
    
    // Get rating from score
    static func fromScore(_ score: Int) -> CreditScoreRating {
        switch score {
        case 300...579: return .poor
        case 580...669: return .fair
        case 670...739: return .good
        case 740...799: return .veryGood
        case 800...850: return .excellent
        default: return .fair // Default to fair for out-of-range scores
        }
    }
}
