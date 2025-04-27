//
//  MarketCondition.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Market conditions that affect investment returns and interest rates
enum MarketCondition: String, Codable, CaseIterable {
    case depression = "Depression"
    case recession = "Recession"
    case recovery = "Recovery"
    case normal = "Normal"
    case expansion = "Expansion"
    case boom = "Boom"
    
    // Get the effect on interest rates
    func interestRateEffect() -> Double {
        switch self {
        case .recession: return -0.02 // -2%
        case .depression: return -0.03 // -3%
        case .recovery: return 0.01 // +1%
        case .expansion: return 0.02 // +2%
        case .normal: return 0.0 // No effect
        case .boom: return 0.03 // +3%
        }
    }
    
    // Static properties and methods for current market condition tracking
    private static var _currentYear: Int = Calendar.current.component(.year, from: Date())
    private static var _cachedCondition: MarketCondition = .normal
    
    static func currentYear() -> Int {
        return _currentYear
    }
    
    static func setCurrent(_ condition: MarketCondition, year: Int) {
        _cachedCondition = condition
        _currentYear = year
    }
    
    static func setCurrentYear(_ year: Int) {
        _currentYear = year
    }
    
    static func random() -> MarketCondition {
        let conditions: [MarketCondition] = [.depression, .recession, .recovery, .normal, .expansion, .boom]
        let weights = [0.05, 0.15, 0.2, 0.3, 0.2, 0.1] // Probability distribution
        
        let totalWeight = weights.reduce(0, +)
        var randomValue = Double.random(in: 0..<totalWeight)
        
        for i in 0..<conditions.count {
            if randomValue < weights[i] {
                return conditions[i]
            }
            randomValue -= weights[i]
        }
        
        return .normal // Default fallback
    }
}
