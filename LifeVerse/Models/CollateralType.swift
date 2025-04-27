//
//  CollateralType.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Types of assets that can be used as collateral
enum CollateralType: String, Codable, CaseIterable {
    case realEstate = "Real Estate"
    case vehicle = "Vehicle"
    case investment = "Investment"
    case savings = "Savings"
    case jewelry = "Jewelry"
    case electronics = "Electronics"
    case other = "Other Asset"
    
    // Get typical loan-to-value ratio for this collateral type
    func loanToValueRatio() -> Double {
        switch self {
        case .realEstate: return 0.8  // 80% of value
        case .vehicle: return 0.7     // 70% of value
        case .investment: return 0.5  // 50% of value
        case .savings: return 0.9     // 90% of value
        case .jewelry: return 0.4     // 40% of value
        case .electronics: return 0.3 // 30% of value
        case .other: return 0.25      // 25% of value
        }
    }
    
    // Get annual depreciation rate for this collateral type
    func depreciationRate() -> Double {
        switch self {
        case .realEstate: return -0.03 // Actually appreciates by 3% on average
        case .vehicle: return 0.15     // 15% annual depreciation
        case .investment: return 0.0   // Variable returns
        case .savings: return 0.0      // Cash doesn't depreciate
        case .jewelry: return 0.05     // 5% annual depreciation
        case .electronics: return 0.25 // 25% annual depreciation
        case .other: return 0.10       // 10% annual depreciation
        }
    }
}
