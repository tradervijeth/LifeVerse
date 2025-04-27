//
//  FormattingExtensions.swift
//  LifeVerse
//
//  Created on 27/04/2025.
//
//  Utility extensions for formatting
//

import Foundation

// NOTE: This file contains formatting extensions for the LifeVerse app
// Int.formattedWithSeparator() is already defined in PropertyInvestmentView.swift
// and should be moved here in a future refactoring to centralize all formatting methods

// Extension for Double to support currency formatting
extension Double {
    func asCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$\(Int(self))"
    }
    
    func asPercentage(decimals: Int = 1) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = decimals
        return formatter.string(from: NSNumber(value: self)) ?? "\(Int(self * 100))%"
    }
}
