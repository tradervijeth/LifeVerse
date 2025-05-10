//
//  MarketConditionHelpers.swift
//  LifeVerse
//
//  Created on 27/04/2025.
//
//  Central utility file for market condition conversions and representations
//

import Foundation
import SwiftUI

// MARK: - Banking_MarketCondition Extensions
extension Banking_MarketCondition {
    /// Convert Banking_MarketCondition to ViewMarketCondition for UI purposes
    /// - Returns: Equivalent ViewMarketCondition enum case
    func toViewMarketCondition() -> ViewMarketCondition {
        switch self {
        case .recession: return .recession
        case .depression: return .depression
        case .recovery: return .recovery
        case .expansion: return .expansion
        case .normal: return .normal
        case .boom: return .boom
        }
    }

    /// Get color representation for this market condition
    /// - Returns: SwiftUI color appropriate for the market condition
    func color() -> Color {
        switch self {
        case .depression: return .red
        case .recession: return .orange
        case .recovery: return .yellow
        case .normal: return .green
        case .expansion: return .blue
        case .boom: return .purple
        }
    }

    /// Get human-readable description of market condition
    /// - Returns: Description string explaining the market condition
    func description() -> String {
        switch self {
        case .recession: return "Declining values, higher inventory"
        case .depression: return "Significant value drops, difficult financing"
        case .recovery: return "Stabilizing values, improving sales"
        case .expansion: return "Rising values, strong demand"
        case .boom: return "Rapid appreciation, competitive market"
        case .normal: return "Balanced market conditions"
        }
    }

    /// Get numerical appreciation rate modifier based on market condition
    /// - Returns: Percentage modifier as a decimal (e.g., 0.03 for 3%)
    func appreciationRateModifier() -> Double {
        switch self {
        case .depression: return -0.07 // -7%
        case .recession: return -0.03 // -3%
        case .recovery: return 0.01 // +1%
        case .normal: return 0.00 // neutral
        case .expansion: return 0.02 // +2%
        case .boom: return 0.05 // +5%
        }
    }
}

// MARK: - MarketCondition Extensions
extension MarketCondition {
    /// Convert standard MarketCondition to Banking_MarketCondition
    /// - Returns: Equivalent Banking_MarketCondition enum case
    func toBankingMarketCondition() -> Banking_MarketCondition {
        switch self {
        case .depression: return .depression
        case .recession: return .recession
        case .recovery: return .recovery
        case .normal: return .normal
        case .expansion: return .expansion
        case .boom: return .boom
        }
    }
}

// Note: ViewMarketCondition extensions are now defined in Models/ViewMarketCondition.swift

// MARK: - ViewMarketCondition to Banking_MarketCondition conversion
extension ViewMarketCondition {
    /// Convert ViewMarketCondition to Banking_MarketCondition
    func toBankingMarketCondition() -> Banking_MarketCondition {
        switch self {
        case .recession:
            return .recession
        case .depression:
            return .depression
        case .recovery:
            return .recovery
        case .expansion:
            return .expansion
        case .normal:
            return .normal
        case .boom:
            return .boom
        }
    }
}
