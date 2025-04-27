//
//  LoanCollateral.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Represents an asset that can be used as collateral for a loan
struct LoanCollateral: Codable, Identifiable {
    var id = UUID()
    var type: CollateralType
    var description: String
    var value: Double
    var purchaseYear: Int
    var loanId: UUID? = nil  // The loan this collateral is tied to (if any)
    var repossessed: Bool = false
    
    /// Calculate the current market value based on depreciation
    func currentValue(currentYear: Int) -> Double {
        let age = currentYear - purchaseYear
        let depreciationRate = type.depreciationRate()
        
        if depreciationRate < 0 {
            // Asset appreciates (like real estate)
            return value * pow(1 - depreciationRate, Double(age))
        } else {
            // Asset depreciates (like vehicles, electronics)
            return value * pow(1 - depreciationRate, Double(age))
        }
    }
    
    /// Maximum loan amount based on the collateral's current value
    func maxLoanAmount(currentYear: Int) -> Double {
        let currentVal = currentValue(currentYear: currentYear)
        return currentVal * type.loanToValueRatio()
    }
    
    /// Check if the collateral is available (not already tied to a loan)
    var isAvailable: Bool {
        return loanId == nil && !repossessed
    }
    
    init(type: CollateralType, description: String, value: Double, purchaseYear: Int) {
        self.id = UUID()
        self.type = type
        self.description = description
        self.value = value
        self.purchaseYear = purchaseYear
        self.loanId = nil
        self.repossessed = false
    }
}
