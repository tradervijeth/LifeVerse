//
//  PropertyInvestment.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Represents a real estate property investment
struct PropertyInvestment: Codable, Identifiable {
    var id = UUID()
    var name: String
    var address: String
    var propertyType: PropertyType
    var purchaseYear: Int
    var purchasePrice: Double
    var currentValue: Double
    var mortgageAccountId: UUID?
    var mortgageId: UUID? { return mortgageAccountId } // For compatibility
    var mortgageTerm: Int = 30 // Default 30-year mortgage
    var mortgageYearsRemaining: Int = 30
    var equityPercentage: Double = 0.0 // Equity as percentage of property value
    var isRental: Bool = false
    var monthlyRent: Double = 0
    var occupancyRate: Double = 1.0 // 0.0-1.0
    var propertyTaxRate: Double = 0.01 // 1% property tax by default
    var maintenanceCostsPerYear: Double
    
    enum PropertyType: String, Codable, CaseIterable {
        case singleFamilyHome = "Single Family Home"
        case condo = "Condominium"
        case apartment = "Apartment"
        case duplex = "Duplex"
        case townhouse = "Townhouse"
        case vacationHome = "Vacation Home"
        case commercialProperty = "Commercial Property"
        case land = "Undeveloped Land"
    }
    
    var hasActiveMortgage: Bool {
        return mortgageAccountId != nil
    }
    
    var equity: Double {
        // If there's no mortgage, the equity is the full value
        return currentValue
    }
    
    init(name: String, address: String, propertyType: PropertyType, purchaseYear: Int, 
         purchasePrice: Double, mortgageAccountId: UUID? = nil) {
        self.id = UUID()
        self.name = name
        self.address = address
        self.propertyType = propertyType
        self.purchaseYear = purchaseYear
        self.purchasePrice = purchasePrice
        self.currentValue = purchasePrice
        self.mortgageAccountId = mortgageAccountId
        
        // Calculate maintenance costs based on property type
        switch propertyType {
        case .singleFamilyHome, .vacationHome:
            self.maintenanceCostsPerYear = purchasePrice * 0.01 // 1% of purchase price
        case .condo, .apartment, .townhouse:
            self.maintenanceCostsPerYear = purchasePrice * 0.005 // 0.5% (HOA covers some)
        case .duplex:
            self.maintenanceCostsPerYear = purchasePrice * 0.015 // 1.5% (more units = more maintenance)
        case .commercialProperty:
            self.maintenanceCostsPerYear = purchasePrice * 0.02 // 2% (commercial has higher costs)
        case .land:
            self.maintenanceCostsPerYear = purchasePrice * 0.002 // 0.2% (minimal maintenance)
        }
    }
    
    mutating func updateValue(currentYear: Int, marketCondition: MarketCondition) -> Double {
        let previousValue = currentValue
        
        // Calculate years owned (unused but keeping for future reference)
        _ = currentYear - purchaseYear
        
        // Different property types appreciate differently
        var baseAppreciationRate: Double
        switch propertyType {
        case .singleFamilyHome, .townhouse:
            baseAppreciationRate = 0.03 // 3% annual growth
        case .condo, .apartment:
            baseAppreciationRate = 0.025 // 2.5% annual growth
        case .duplex:
            baseAppreciationRate = 0.035 // 3.5% annual growth
        case .vacationHome:
            baseAppreciationRate = 0.04 // 4% annual growth (desirable areas)
        case .commercialProperty:
            baseAppreciationRate = 0.045 // 4.5% annual growth
        case .land:
            baseAppreciationRate = 0.02 // 2% annual growth
        }
        
        // Adjust for market conditions
        var marketAdjustment: Double
        switch marketCondition {
        case .boom:
            marketAdjustment = 0.05 // +5% in boom
        case .expansion:
            marketAdjustment = 0.02 // +2% in expansion
        case .normal:
            marketAdjustment = 0.0 // no adjustment
        case .recovery:
            marketAdjustment = 0.01 // +1% in recovery
        case .recession:
            marketAdjustment = -0.03 // -3% in recession
        case .depression:
            marketAdjustment = -0.07 // -7% in depression
        }
        
        // Random factor (-1% to +1%)
        let randomFactor = Double.random(in: -0.01...0.01)
        
        // Calculate this year's appreciation rate
        let appreciationRate = baseAppreciationRate + marketAdjustment + randomFactor
        
        // Update the value
        currentValue = currentValue * (1.0 + appreciationRate)
        
        return currentValue - previousValue
    }
    
    func calculateAnnualRentalIncome() -> Double {
        // Monthly rent * 12 months * occupancy rate
        return monthlyRent * 12 * occupancyRate
    }
    
    func calculateAnnualExpenses() -> Double {
        // Maintenance + property taxes (simplified)
        let propertyTaxes = currentValue * propertyTaxRate
        return maintenanceCostsPerYear + propertyTaxes
    }
    
    func calculateNetAnnualIncome() -> Double {
        // Only applicable for rental properties
        if isRental {
            return calculateAnnualRentalIncome() - calculateAnnualExpenses()
        }
        return -calculateAnnualExpenses() // Just expenses for non-rental
    }
    
    func calculateROI() -> Double {
        // Return on Investment calculation
        let netIncome = calculateNetAnnualIncome()
        let roi = netIncome / purchasePrice
        return roi
    }
    
    func estimateSellingPrice(marketCondition: MarketCondition) -> Double {
        // Estimate what the property would sell for
        let marketAdjustment: Double
        switch marketCondition {
        case .boom: marketAdjustment = 0.05
        case .expansion: marketAdjustment = 0.02
        case .normal: marketAdjustment = 0.0
        case .recovery: marketAdjustment = 0.01
        case .recession: marketAdjustment = -0.03
        case .depression: marketAdjustment = -0.05
        }
        
        return currentValue * (1.0 + marketAdjustment)
    }
    
    // Calculate the annual mortgage payment
    func calculateAnnualMortgagePayment(interestRate: Double = 0.04) -> Double {
        guard let _ = mortgageAccountId, mortgageYearsRemaining > 0 else {
            return 0.0 // No mortgage or paid off
        }
        
        // Calculate the remaining loan amount
        let loanAmount = purchasePrice * (1.0 - equityPercentage)
        
        // Convert annual interest rate to monthly
        let monthlyRate = interestRate / 12.0
        
        // Calculate total number of payments
        let totalPayments = mortgageYearsRemaining * 12
        
        // Monthly payment using mortgage formula
        let monthlyPayment = loanAmount * 
            (monthlyRate * pow(1 + monthlyRate, Double(totalPayments))) / 
            (pow(1 + monthlyRate, Double(totalPayments)) - 1)
        
        // Annual payment is monthly payment times 12
        return monthlyPayment * 12
    }
}

// MarketCondition enum is now defined in MarketCondition.swift