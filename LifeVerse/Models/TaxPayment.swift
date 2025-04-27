//
//  TaxPayment.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Represents a tax payment made by the character
struct TaxPayment: Codable, Identifiable {
    var id = UUID()
    var year: Int
    var amount: Double
    var type: TaxType
    var date: Date
    var deductions: [TaxDeduction]
    
    /// Type of tax payment
    enum TaxType: String, Codable {
        case incomeTax = "Income Tax"
        case propertyTax = "Property Tax"
        case capitalGains = "Capital Gains Tax"
        case salesTax = "Sales Tax"
        case other = "Other Tax"
    }
    
    /// Represents a tax deduction applied to the payment
    struct TaxDeduction: Codable, Identifiable {
        var id = UUID()
        var description: String
        var amount: Double
        var category: DeductionCategory
        
        enum DeductionCategory: String, Codable {
            case medical = "Medical"
            case education = "Education"
            case business = "Business"
            case charitable = "Charitable Donations"
            case retirement = "Retirement Contributions"
            case homeOwnership = "Home Ownership"
            case other = "Other"
        }
    }
    
    init(year: Int, amount: Double, type: TaxType, date: Date = Date(), deductions: [TaxDeduction] = []) {
        self.id = UUID()
        self.year = year
        self.amount = amount
        self.type = type
        self.date = date
        self.deductions = deductions
    }
}