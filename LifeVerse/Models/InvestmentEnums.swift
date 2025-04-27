//
//  InvestmentEnums.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Risk levels for investments
enum RiskLevel: String, Codable, CaseIterable {
    case veryLow = "Very Low"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High"
    case veryHigh = "Very High"
    
    // Expected return range for this risk level
    func expectedReturnRange() -> (low: Double, high: Double) {
        switch self {
        case .veryLow: return (0.01, 0.03)  // 1-3%
        case .low: return (0.02, 0.05)      // 2-5%
        case .moderate: return (0.04, 0.08) // 4-8%
        case .high: return (0.07, 0.15)     // 7-15%
        case .veryHigh: return (0.1, 0.25)  // 10-25%
        }
    }
    
    // Volatility factor for this risk level
    func volatilityFactor() -> Double {
        switch self {
        case .veryLow: return 0.02   // 2%
        case .low: return 0.05       // 5%
        case .moderate: return 0.1   // 10%
        case .high: return 0.2       // 20%
        case .veryHigh: return 0.35  // 35%
        }
    }
}

/// Investment types
enum InvestmentType: String, Codable, CaseIterable {
    case stocks = "Stocks"
    case bonds = "Bonds"
    case mutualFunds = "Mutual Funds"
    case realEstate = "Real Estate"
    case etf = "ETF"
    case crypto = "Cryptocurrency"
    case commodities = "Commodities"
    case forex = "Forex"
    
    // Default risk level for this investment type
    func defaultRiskLevel() -> RiskLevel {
        switch self {
        case .bonds: return .low
        case .mutualFunds, .etf: return .moderate
        case .stocks, .realEstate: return .moderate
        case .commodities, .forex: return .high
        case .crypto: return .veryHigh
        }
    }
    
    // Minimum recommended investment amount
    func minimumRecommendedAmount() -> Double {
        switch self {
        case .stocks: return 1000
        case .bonds: return 2000
        case .mutualFunds: return 1000
        case .realEstate: return 20000
        case .etf: return 500
        case .crypto: return 500
        case .commodities: return 2000
        case .forex: return 1000
        }
    }
}

/// Property condition ratings
enum PropertyCondition: Int, Codable, CaseIterable {
    case terrible = 30
    case poor = 50
    case average = 70
    case good = 85
    case excellent = 100
    
    // Maintenance cost modifier based on condition
    func maintenanceCostModifier() -> Double {
        switch self {
        case .terrible: return 3.0  // 3x normal maintenance costs
        case .poor: return 2.0      // 2x normal maintenance costs
        case .average: return 1.0   // Normal maintenance costs
        case .good: return 0.7      // 70% of normal maintenance costs
        case .excellent: return 0.5 // 50% of normal maintenance costs
        }
    }
    
    // Value modifier based on condition
    func valueModifier() -> Double {
        switch self {
        case .terrible: return 0.6  // 60% of base value
        case .poor: return 0.8      // 80% of base value
        case .average: return 1.0   // Base value
        case .good: return 1.2      // 120% of base value
        case .excellent: return 1.4 // 140% of base value
        }
    }
}
