//
//  Banking_MarketCondition.swift
//  LifeVerse
//
//  Created to fix duplicate enums issue
//

import Foundation
import SwiftUI

// Define the enum directly without referencing MarketCondition
enum Banking_MarketCondition: String, Codable {
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
    private static var _cachedCondition: Banking_MarketCondition = .normal

    static func currentYear() -> Int {
        return _currentYear
    }

    static func setCurrent(_ condition: Banking_MarketCondition, year: Int) {
        _cachedCondition = condition
        _currentYear = year
    }

    static func random() -> Banking_MarketCondition {
        let conditions: [Banking_MarketCondition] = [.depression, .recession, .recovery, .normal, .expansion, .boom]
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
