//
//  PropertyType.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Types of properties that can be owned or invested in
enum PropertyType: String, Codable, CaseIterable {
    case singleFamilyHome = "Single Family Home"
    case multifamily = "Multi-Family"
    case condo = "Condominium"
    case commercial = "Commercial"
    case land = "Land"
    
    /// Get the typical maintenance cost percentage for this property type
    func maintenanceCostPercentage() -> Double {
        switch self {
        case .singleFamilyHome: return 0.01  // 1% of property value per year
        case .multifamily: return 0.015      // 1.5% of property value per year
        case .condo: return 0.005            // 0.5% of property value per year (lower due to HOA)
        case .commercial: return 0.02        // 2% of property value per year
        case .land: return 0.003             // 0.3% of property value per year
        }
    }
    
    /// Get the typical appreciation rate for this property type
    func appreciationRate() -> Double {
        switch self {
        case .singleFamilyHome: return 0.03  // 3% per year
        case .multifamily: return 0.035      // 3.5% per year
        case .condo: return 0.025            // 2.5% per year
        case .commercial: return 0.04        // 4% per year
        case .land: return 0.02              // 2% per year
        }
    }
}

// PropertyLocation moved to its own file to avoid redeclaration
