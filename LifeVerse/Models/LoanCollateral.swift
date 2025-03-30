//
//  LoanCollateral.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

struct LoanCollateral: Codable, Identifiable {
    var id = UUID()
    var type: CollateralType
    var description: String
    var value: Double
    var depreciationRate: Double // Annual rate of value decrease
    var purchaseYear: Int
    var loanId: UUID? // ID of the loan this collateral is tied to
    
    // Initialize a new collateral asset
    init(type: CollateralType, description: String, value: Double, purchaseYear: Int) {
        self.type = type
        self.description = description
        self.value = value
        self.purchaseYear = purchaseYear
        self.depreciationRate = type.defaultDepreciationRate()
    }
    
    // Calculate current value after depreciation
    func currentValue(currentYear: Int) -> Double {
        let yearsOwned = currentYear - purchaseYear
        var depreciated = value
        
        // Apply depreciation for each year
        for _ in 0..<yearsOwned {
            depreciated *= (1.0 - depreciationRate)
        }
        
        // Ensure value doesn't go below minimum
        return max(depreciated, value * type.minimumValuePercent())
    }
    
    // Calculate loan-to-value ratio
    func loanToValueRatio(loanBalance: Double, currentYear: Int) -> Double {
        let currentAssetValue = currentValue(currentYear: currentYear)
        return abs(loanBalance) / currentAssetValue
    }
    
    // Check if collateral is underwater (loan exceeds value)
    func isUnderwater(loanBalance: Double, currentYear: Int) -> Bool {
        return loanToValueRatio(loanBalance: loanBalance, currentYear: currentYear) > 1.0
    }
    
    // Get description with current value
    func formattedDescription(currentYear: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let valueString = formatter.string(from: NSNumber(value: currentValue(currentYear: currentYear))) ?? "$\(currentValue(currentYear: currentYear))"
        return "\(description) (\(valueString))"
    }
}

// Types of assets that can be used as collateral
enum CollateralType: String, Codable, CaseIterable {
    case realEstate = "Real Estate"
    case vehicle = "Vehicle"
    case investment = "Investment"
    case savings = "Savings"
    case jewelry = "Jewelry"
    case electronics = "Electronics"
    case other = "Other Asset"
    
    // Get default depreciation rate for this type
    func defaultDepreciationRate() -> Double {
        switch self {
        case .realEstate: return -0.03 // Actually appreciates 3% per year on average
        case .vehicle: return 0.15 // 15% depreciation per year
        case .investment: return 0.0 // Handled separately through market performance
        case .savings: return 0.0 // No depreciation
        case .jewelry: return 0.05 // 5% depreciation per year
        case .electronics: return 0.25 // 25% depreciation per year
        case .other: return 0.10 // 10% depreciation per year
        }
    }
    
    // Get minimum value as percentage of original value
    func minimumValuePercent() -> Double {
        switch self {
        case .realEstate: return 0.5 // Won't go below 50% of original value
        case .vehicle: return 0.1 // Won't go below 10% of original value
        case .investment: return 0.0 // Can potentially lose all value
        case .savings: return 1.0 // Doesn't lose value
        case .jewelry: return 0.3 // Won't go below 30% of original value
        case .electronics: return 0.05 // Won't go below 5% of original value
        case .other: return 0.1 // Won't go below 10% of original value
        }
    }
    
    // Get maximum loan-to-value ratio for this collateral type
    func maxLoanToValueRatio() -> Double {
        switch self {
        case .realEstate: return 0.8 // Can borrow up to 80% of value
        case .vehicle: return 0.9 // Can borrow up to 90% of value
        case .investment: return 0.5 // Can borrow up to 50% of value
        case .savings: return 0.95 // Can borrow up to 95% of value
        case .jewelry: return 0.5 // Can borrow up to 50% of value
        case .electronics: return 0.5 // Can borrow up to 50% of value
        case .other: return 0.5 // Can borrow up to 50% of value
        }
    }
    
    // Get description of collateral type
    func description() -> String {
        switch self {
        case .realEstate:
            return "Property such as houses, apartments, or land."
        case .vehicle:
            return "Cars, motorcycles, boats, or other vehicles."
        case .investment:
            return "Stocks, bonds, or other investment assets."
        case .savings:
            return "Money in savings accounts or certificates of deposit."
        case .jewelry:
            return "Valuable jewelry, watches, or precious metals."
        case .electronics:
            return "Computers, smartphones, or other electronic devices."
        case .other:
            return "Other valuable assets that can secure a loan."
        }
    }
}