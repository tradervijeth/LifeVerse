//
//  IntExtensions.swift
//  LifeVerse
//
//  Created on 27/04/2025.
//
//  Utility extensions for Int formatting - centralized to avoid duplicate declarations
//

import Foundation
import SwiftUI

// MARK: - Int Formatting Extensions
extension Int {
    /// Format with thousands separator
    /// - Returns: String with thousands separator (e.g., 1,234,567)
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    /// Format as currency with $ symbol
    /// - Returns: String formatted as currency (e.g., $1,234)
    func asCurrency() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "$\(self)"
    }
    
    /// Format as year(s) with proper singular/plural form
    /// - Returns: Formatted year string (e.g., "1 year" or "5 years")
    func asYears() -> String {
        if self == 1 {
            return "1 year"
        } else {
            return "\(self) years"
        }
    }
    
    /// Convert to abbreviated format (K, M, B)
    /// - Returns: Abbreviated number string (e.g., "1.2K", "3.4M")
    func abbreviated() -> String {
        let num = abs(Double(self))
        let sign = (self < 0) ? "-" : ""
        
        switch num {
        case 1_000_000_000...:
            let formatted = num / 1_000_000_000
            return "\(sign)\(String(format: "%.1f", formatted))B"
        case 1_000_000...:
            let formatted = num / 1_000_000
            return "\(sign)\(String(format: "%.1f", formatted))M"
        case 1_000...:
            let formatted = num / 1_000
            return "\(sign)\(String(format: "%.1f", formatted))K"
        case 0...:
            return "\(self)"
        default:
            return "\(self)"
        }
    }
}
