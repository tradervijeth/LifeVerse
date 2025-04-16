//
//  TaxationSystem.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

// Taxation system to handle various types of taxes in the game
struct TaxationSystem: Codable {
    // Tax rates for different income brackets (progressive taxation)
    var incomeTaxBrackets: [IncomeTaxBracket] = [
        IncomeTaxBracket(lowerBound: 0, upperBound: 10000, rate: 0.10),       // 10% for $0-$10,000
        IncomeTaxBracket(lowerBound: 10000, upperBound: 40000, rate: 0.15), // 15% for $10,001-$40,000
        IncomeTaxBracket(lowerBound: 40000, upperBound: 85000, rate: 0.25), // 25% for $40,001-$85,000
        IncomeTaxBracket(lowerBound: 85000, upperBound: 160000, rate: 0.28),// 28% for $85,001-$160,000
        IncomeTaxBracket(lowerBound: 160000, upperBound: 200000, rate: 0.33),// 33% for $160,001-$200,000
        IncomeTaxBracket(lowerBound: 200000, upperBound: Double.infinity, rate: 0.37) // 37% for $200,001+
    ]

    // Capital gains tax rates (short-term and long-term)
    var shortTermCapitalGainsRate: Double = 0.25 // 25% for assets held less than 1 year
    var longTermCapitalGainsRate: Double = 0.15  // 15% for assets held more than 1 year

    // Property tax rate (percentage of property value)
    var basePropertyTaxRate: Double = 0.01 // 1% of property value per year

    // Interest income tax rate
    var interestIncomeTaxRate: Double = 0.20 // 20% tax on interest income

    // Tax deductions and credits
    var standardDeduction: Double = 12000 // Standard deduction amount
    var mortgageInterestDeductible: Bool = true // Whether mortgage interest is tax deductible
    var propertyTaxDeductible: Bool = true // Whether property tax is deductible
    var studentLoanInterestDeductible: Bool = true // Whether student loan interest is deductible
    var maxMortgageInterestDeduction: Double = 10000 // Maximum mortgage interest deduction
    var maxPropertyTaxDeduction: Double = 10000 // Maximum property tax deduction
    var maxStudentLoanInterestDeduction: Double = 2500 // Maximum student loan interest deduction

    // Initialize with default values
    init() {}

    // Calculate income tax based on annual income
    func calculateIncomeTax(annualIncome: Double) -> Double {
        let taxableIncome = max(0, annualIncome - standardDeduction)
        var totalTax: Double = 0

        for bracket in incomeTaxBrackets {
            if taxableIncome > bracket.lowerBound {
                let amountInBracket = min(taxableIncome, bracket.upperBound) - bracket.lowerBound
                totalTax += amountInBracket * bracket.rate

                if taxableIncome <= bracket.upperBound {
                    break
                }
            }
        }

        return totalTax
    }

    // Calculate property tax for a given property value
    func calculatePropertyTax(propertyValue: Double, location: PropertyLocation = .suburban) -> Double {
        return propertyValue * basePropertyTaxRate * location.taxMultiplier()
    }

    // Calculate capital gains tax
    func calculateCapitalGainsTax(gain: Double, holdingPeriodYears: Int) -> Double {
        let rate = holdingPeriodYears >= 1 ? longTermCapitalGainsRate : shortTermCapitalGainsRate
        return gain * rate
    }

    // Calculate tax on interest income
    func calculateInterestIncomeTax(interestAmount: Double) -> Double {
        return interestAmount * interestIncomeTaxRate
    }

    // Calculate total deductions
    func calculateDeductions(mortgageInterest: Double, propertyTaxPaid: Double, studentLoanInterest: Double) -> Double {
        _ = standardDeduction

        // Calculate itemized deductions
        var itemizedDeductions = 0.0

        if mortgageInterestDeductible {
            itemizedDeductions += min(mortgageInterest, maxMortgageInterestDeduction)
        }

        if propertyTaxDeductible {
            itemizedDeductions += min(propertyTaxPaid, maxPropertyTaxDeduction)
        }

        if studentLoanInterestDeductible {
            itemizedDeductions += min(studentLoanInterest, maxStudentLoanInterestDeduction)
        }

        // Use the higher of standard deduction or itemized deductions
        return max(standardDeduction, itemizedDeductions)
    }

    // Calculate effective tax rate
    func calculateEffectiveTaxRate(annualIncome: Double, totalTaxPaid: Double) -> Double {
        return annualIncome > 0 ? totalTaxPaid / annualIncome : 0
    }
}

// Income tax bracket structure
struct IncomeTaxBracket: Codable {
    var lowerBound: Double
    var upperBound: Double
    var rate: Double

    // Format the bracket as a string
    func formattedBracket() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"

        let lowerString = formatter.string(from: NSNumber(value: lowerBound)) ?? "$\(lowerBound)"
        let upperString = upperBound == Double.infinity ? "+" :
                         (formatter.string(from: NSNumber(value: upperBound)) ?? "$\(upperBound)")
        let rateString = String(format: "%.1f%%", rate * 100)

        return "\(lowerString) - \(upperString): \(rateString)"
    }
}

// Property location types that affect property tax rates
enum PropertyLocation: String, Codable, CaseIterable {
    case urban = "Urban"
    case suburban = "Suburban"
    case rural = "Rural"
    case luxuryDistrict = "Luxury District"

    // Get tax multiplier based on location
    func taxMultiplier() -> Double {
        switch self {
        case .urban: return 1.2 // 20% higher than base rate
        case .suburban: return 1.0 // Base rate
        case .rural: return 0.8 // 20% lower than base rate
        case .luxuryDistrict: return 1.5 // 50% higher than base rate
        }
    }

    // Get description of the location
    func description() -> String {
        switch self {
        case .urban:
            return "City center with higher property taxes but better amenities."
        case .suburban:
            return "Residential areas with moderate property taxes and good schools."
        case .rural:
            return "Countryside with lower property taxes but fewer services."
        case .luxuryDistrict:
            return "High-end neighborhoods with premium property taxes and exclusive amenities."
        }
    }
}