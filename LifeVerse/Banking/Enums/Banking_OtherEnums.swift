//
//  Banking_OtherEnums.swift
//  LifeVerse
//
//  Created to fix duplicate enums issue
//

import Foundation

// Define Banking_ prefixed enums that match the original models
// This avoids circular references while maintaining compatibility

// Redefine instead of using type aliases
enum Banking_CollateralType: String, Codable, CaseIterable {
    case realEstate = "Real Estate"
    case vehicle = "Vehicle"
    case investment = "Investment"
    case savings = "Savings"
    case jewelry = "Jewelry"
    case electronics = "Electronics"
    case other = "Other Asset"
}

enum Banking_RiskLevel: String, Codable, CaseIterable {
    case veryLow = "Very Low"
    case low = "Low"
    case moderate = "Moderate"
    case high = "High" 
    case veryHigh = "Very High"
}

enum Banking_InvestmentType: String, Codable, CaseIterable {
    case stocks = "Stocks"
    case bonds = "Bonds"
    case mutualFunds = "Mutual Funds"
    case realEstate = "Real Estate"
    case etf = "ETF"
    case crypto = "Cryptocurrency"
    case commodities = "Commodities"
    case forex = "Forex"
}

enum Banking_PropertyCondition: Int, Codable, CaseIterable {
    case terrible = 30
    case poor = 50
    case average = 70
    case good = 85
    case excellent = 100
}

enum Banking_PropertyType: String, Codable, CaseIterable {
    case singleFamily = "Single Family"
    case multifamily = "Multi-Family"
    case condo = "Condominium"
    case commercial = "Commercial"
    case land = "Land"
}

enum Banking_PropertyLocation: String, Codable, CaseIterable {
    case urban = "Urban"
    case suburban = "Suburban"
    case rural = "Rural"
}

enum Banking_CreditScoreCategory: String, Codable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case veryGood = "Very Good"
    case excellent = "Excellent"
    
    func interestRateModifier() -> Double {
        switch self {
        case .poor: return 0.05 // +5%
        case .fair: return 0.03 // +3%
        case .good: return 0.0 // No change
        case .veryGood: return -0.01 // -1%
        case .excellent: return -0.02 // -2%
        }
    }
}
