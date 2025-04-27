//
//  PropertyLocation.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Property location types, which affect value and appreciation
enum PropertyLocation: String, Codable, CaseIterable {
    case urban = "Urban"
    case suburban = "Suburban"
    case rural = "Rural"
    
    /// Get location modifier for property value
    func valueModifier() -> Double {
        switch self {
        case .urban: return 1.4       // 40% premium
        case .suburban: return 1.0    // Base value
        case .rural: return 0.7       // 30% discount
        }
    }
    
    /// Get location modifier for property appreciation
    func appreciationModifier() -> Double {
        switch self {
        case .urban: return 1.2       // 20% higher appreciation
        case .suburban: return 1.0    // Base appreciation
        case .rural: return 0.8       // 20% lower appreciation
        }
    }
}
