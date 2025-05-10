//
//  TaxationSystem.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Represents a taxation system with tax rates and rules
class TaxationSystem: Codable {
    var incomeTaxBrackets: [TaxBracket]
    var capitalGainsTaxRate: Double
    var standardDeduction: Double
    var personalExemption: Double
    var stateIncomeTaxRate: Double
    var propertyTaxRate: Double
    
    struct TaxBracket: Codable, Identifiable {
        var id = UUID()
        var lowerBound: Double
        var upperBound: Double?
        var rate: Double
        
        var description: String {
            // Define an extension method locally to avoid ambiguity
            func formatNumberWithSeparator(_ value: Int) -> String {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
            }
            
            if let upper = upperBound {
                let lowerInt: Int = Int(lowerBound)
                let upperInt: Int = Int(upper)
                let ratePercent: Int = Int(rate * 100)
                
                return "$\(formatNumberWithSeparator(lowerInt)) - $\(formatNumberWithSeparator(upperInt)): \(ratePercent)%"
            } else {
                let lowerInt: Int = Int(lowerBound)
                let ratePercent: Int = Int(rate * 100)
                
                return "Over $\(formatNumberWithSeparator(lowerInt)): \(ratePercent)%"
            }
        }
    }
    
    init() {
        // Standard US-like progressive tax brackets (simplified)
        incomeTaxBrackets = [
            TaxBracket(lowerBound: 0, upperBound: 10000, rate: 0.10),
            TaxBracket(lowerBound: 10000, upperBound: 40000, rate: 0.15),
            TaxBracket(lowerBound: 40000, upperBound: 85000, rate: 0.25),
            TaxBracket(lowerBound: 85000, upperBound: 163000, rate: 0.28),
            TaxBracket(lowerBound: 163000, upperBound: 207000, rate: 0.33),
            TaxBracket(lowerBound: 207000, upperBound: nil, rate: 0.37)
        ]
        
        capitalGainsTaxRate = 0.15
        standardDeduction = 12200
        personalExemption = 0 // Reduced to 0 after 2017 tax reform
        stateIncomeTaxRate = 0.05
        propertyTaxRate = 0.01
    }
    
    // Calculate income tax on a specific amount
    func calculateIncomeTax(amount: Double) -> Double {
        var tax = 0.0
        var remainingIncome = amount
        
        // Subtract standard deduction
        remainingIncome = max(0, remainingIncome - standardDeduction)
        
        // Apply tax brackets progressively
        for bracket in incomeTaxBrackets {
            let upperLimit = bracket.upperBound ?? Double.infinity
            let incomeInBracket = min(remainingIncome, upperLimit - bracket.lowerBound)
            
            if incomeInBracket > 0 {
                tax += incomeInBracket * bracket.rate
                remainingIncome -= incomeInBracket
            }
            
            if remainingIncome <= 0 {
                break
            }
        }
        
        return tax
    }
    
    // Calculate capital gains tax
    func calculateCapitalGainsTax(amount: Double) -> Double {
        return amount * capitalGainsTaxRate
    }
    
    // Calculate property tax
    func calculatePropertyTax(propertyValue: Double) -> Double {
        return propertyValue * propertyTaxRate
    }
}
