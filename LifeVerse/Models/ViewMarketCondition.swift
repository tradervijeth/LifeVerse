//
//  ViewMarketCondition.swift
//  LifeVerse
//
//  Created to fix missing ViewMarketCondition enum
//

import Foundation
import SwiftUI

// UI-specific market condition enum
enum ViewMarketCondition: String, CaseIterable {
    case recession = "Recession"
    case depression = "Depression"
    case recovery = "Recovery"
    case expansion = "Expansion"
    case normal = "Normal"
    case boom = "Boom"
    
    /// Get human-readable description of market condition for UI
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
    
    /// Get appropriate color for this market condition
    /// - Returns: SwiftUI color for the market condition
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
    
    /// Get interest rate effect for this market condition
    /// - Returns: Interest rate modifier as decimal (e.g., 0.02 for +2%)
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
}
