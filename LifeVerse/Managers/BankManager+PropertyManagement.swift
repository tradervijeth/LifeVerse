//
//  BankManager+PropertyManagement.swift
//  LifeVerse
//
//  Created on 27/04/2025.
//
//  Consolidated property management extension for BankManager
//

import Foundation

// Comprehensive extension for all property-related functionality
extension BankManager {
    // MARK: - Property Access
    
    // Get all property investments
    func getPropertyInvestments() -> [PropertyInvestment] {
        return propertyInvestments
    }
    
    // Get rental properties only
    func getRentalProperties() -> [PropertyInvestment] {
        return propertyInvestments.filter { $0.isRental }
    }
    
    // Get a specific property by ID
    func getPropertyInvestment(id: UUID) -> PropertyInvestment? {
        return propertyInvestments.first { $0.id == id }
    }
    
    // MARK: - Property Analysis
    
    // Calculate total property value
    func calculateTotalPropertyValue() -> Double {
        return propertyInvestments.reduce(0) { $0 + $1.currentValue }
    }
    
    // Calculate total property equity
    func calculateTotalPropertyEquity(currentYear: Int) -> Double {
        return propertyInvestments.reduce(0.0) { total, property in
            var propertyEquity = property.currentValue
            
            // Subtract mortgage if exists
            if let mortgageId = property.mortgageAccountId,
               let mortgage = getAccount(id: mortgageId) {
                propertyEquity += mortgage.balance // Balance is negative for loans
            }
            
            return total + propertyEquity
        }
    }
    
    // Calculate total annual rental income
    func calculateTotalAnnualRentalIncome() -> Double {
        return getRentalProperties().reduce(0) { $0 + $1.calculateAnnualRentalIncome() }
    }
    
    // Calculate total annual rental expenses
    func calculateTotalAnnualRentalExpenses() -> Double {
        return getRentalProperties().reduce(0) { $0 + $1.calculateAnnualExpenses() }
    }
    
    // Calculate total net annual rental income
    func calculateTotalAnnualNetRentalIncome() -> Double {
        return getRentalProperties().reduce(0) { $0 + $1.calculateNetAnnualIncome() }
    }
    
    // MARK: - Property Market
    
    // Get estimated selling price for a property
    func getEstimatedSellingPrice(propertyId: UUID) -> (min: Double, average: Double, max: Double)? {
        guard let property = getPropertyInvestment(id: propertyId) else {
            return nil
        }
        
        // Calculate range based on market conditions
        let baseValue = property.currentValue
        let minValue = baseValue * 0.9  // 10% below current value
        let avgValue = baseValue
        let maxValue = baseValue * 1.1  // 10% above current value
        
        return (minValue, avgValue, maxValue)
    }
    
    // MARK: - Property Creation and Acquisition
    
    // Create a new property investment with optional mortgage
    func createPropertyInvestment(propertyValue: Double, downPayment: Double, isRental: Bool, monthlyRent: Double = 0, term: Int = 30, currentYear: Int) -> (property: PropertyInvestment?, mortgage: BankAccount?) {
        // Minimum down payment is 20% for investment properties and 5% for personal residence
        let minimumDownPayment = propertyValue * (isRental ? 0.2 : 0.05)

        if downPayment < minimumDownPayment {
            return (nil, nil)
        }

        // Check if the character has enough money for the down payment
        if characterMoney < downPayment {
            return (nil, nil)
        }

        // Create the property investment type
        let propertyType: PropertyInvestment.PropertyType = .singleFamilyHome

        // Create the property investment
        var property = PropertyInvestment(
            name: isRental ? "Rental Property" : "Residential Property",
            address: "123 Main St",
            propertyType: propertyType,
            purchaseYear: currentYear,
            purchasePrice: propertyValue
        )
        
        // Set rental properties
        if isRental {
            property.isRental = true
            property.monthlyRent = monthlyRent
            property.occupancyRate = 0.9 // 90% occupancy by default
        }

        // Create mortgage if not paying cash
        var mortgage: BankAccount? = nil
        if downPayment < propertyValue {
            // Loan amount is property value minus down payment
            let loanAmount = propertyValue - downPayment

            // Create the mortgage account
            mortgage = openAccount(
                type: .mortgage,
                initialDeposit: loanAmount,
                currentYear: currentYear,
                term: term
            )

            if let mortgage = mortgage {
                // Link mortgage to property
                property.mortgageAccountId = mortgage.id
            } else {
                // Failed to create mortgage
                return (nil, nil)
            }
        }

        // Deduct down payment
        characterMoney -= downPayment

        // Add property to investments
        propertyInvestments.append(property)
        
        return (property, mortgage)
    }
    
    // MARK: - Property Sales and Conversions
    
    // Convert property to rental
    func convertPropertyToRental(propertyId: UUID, monthlyRent: Double, occupancyRate: Double) -> Bool {
        // Find the property
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }) else {
            return false
        }
        
        // Update property to mark as rental
        propertyInvestments[propertyIndex].isRental = true
        propertyInvestments[propertyIndex].monthlyRent = monthlyRent
        propertyInvestments[propertyIndex].occupancyRate = occupancyRate
        
        return true
    }
    
    // Sell a property
    func sellProperty(propertyId: UUID, sellingPrice: Double, currentYear: Int) -> (success: Bool, proceeds: Double, message: String) {
        // Find the property
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }) else {
            return (false, 0, "Property not found")
        }
        
        let property = propertyInvestments[propertyIndex]
        var proceeds = sellingPrice
        var message = ""
        
        // Handle mortgage payoff if there is one
        if let mortgageId = property.mortgageAccountId, 
           let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) {
            let mortgage = accounts[mortgageIndex]
            let mortgageBalance = abs(mortgage.balance) // Mortgage balance is stored as negative
            
            // Check if selling price covers the mortgage
            if sellingPrice < mortgageBalance {
                return (false, 0, "Selling price doesn't cover mortgage")
            }
            
            // Pay off the mortgage
            proceeds -= mortgageBalance
            
            // Close the mortgage account
            _ = closeAccount(accountId: mortgageId)
            
            message += "Mortgage paid off: $\(Int(mortgageBalance)). "
        }
        
        // Add proceeds to character's money
        characterMoney += proceeds
        
        // Remove the property from investments
        propertyInvestments.remove(at: propertyIndex)
        
        message += "Net proceeds: $\(Int(proceeds))"
        return (true, proceeds, message)
    }
    
    // MARK: - Refinancing
    
    // Calculate maximum cash-out amount based on property equity and LTV limits
    func calculateMaxCashOut(propertyId: UUID) -> Double {
        guard let property = getPropertyInvestment(id: propertyId) else {
            return 0
        }
        
        // Get current mortgage balance
        var currentMortgageBalance: Double = 0
        if let mortgageAccountId = property.mortgageAccountId,
           let mortgage = getAccount(id: mortgageAccountId) {
            currentMortgageBalance = abs(mortgage.balance)
        }
        
        // Calculate max LTV based on property type
        let maxLTV = property.isRental ? 0.75 : 0.80 // 75% for rentals, 80% for primary residence
        
        // Calculate maximum new loan amount based on LTV
        let maxLoanAmount = property.currentValue * maxLTV
        
        // Maximum cash-out is the difference between max loan and current mortgage
        // If the result is negative, no cash-out is possible
        return max(0, maxLoanAmount - currentMortgageBalance)
    }
    
    // Calculate property's loan-to-value ratio
    func calculatePropertyLTV(propertyId: UUID) -> Double? {
        guard let property = getPropertyInvestment(id: propertyId) else {
            return nil
        }
        
        // Get current mortgage balance
        if let mortgageAccountId = property.mortgageAccountId,
           let mortgage = getAccount(id: mortgageAccountId) {
            let balance = abs(mortgage.balance)
            return balance / property.currentValue
        }
        
        // If no mortgage, LTV is 0
        return 0.0
    }
    
    // Check if property is in negative equity (underwater)
    func isPropertyInNegativeEquity(propertyId: UUID) -> Bool {
        guard let property = getPropertyInvestment(id: propertyId),
              let mortgageAccountId = property.mortgageAccountId,
              let mortgage = getAccount(id: mortgageAccountId) else {
            return false
        }
        
        let balance = abs(mortgage.balance)
        return balance > property.currentValue
    }
    
    // Check if property is eligible for refinancing
    func canRefinanceProperty(propertyId: UUID) -> (eligible: Bool, reason: String) {
        guard let property = getPropertyInvestment(id: propertyId) else {
            return (false, "Property not found")
        }
        
        // Check if property has an active mortgage
        guard let mortgageAccountId = property.mortgageAccountId,
              let mortgage = getAccount(id: mortgageAccountId) else {
            return (false, "No active mortgage found for this property")
        }
        
        // Check if property is in negative equity
        if isPropertyInNegativeEquity(propertyId: propertyId) {
            return (false, "Property is in negative equity (underwater)")
        }
        
        // Check credit score
        if creditScore < 620 {
            return (false, "Credit score too low for refinancing (minimum 620 required)")
        }
        
        // Check debt-to-income ratio
        let dti = calculateDebtToIncomeRatio()
        if dti > 0.43 {
            return (false, "Debt-to-income ratio too high (maximum 43% allowed)")
        }
        
        // Check property value
        if property.currentValue < 50000 {
            return (false, "Property value too low for refinancing")
        }
        
        // Check existing loan age (typically need 6-12 months seasoning)
        let currentYear = Calendar.current.component(.year, from: Date())
        if currentYear - mortgage.creationYear < 1 {
            return (false, "Mortgage too new - must be at least 1 year old")
        }
        
        // All checks passed
        return (true, "Eligible for refinancing")
    }
    
    // Handle underwater mortgage (negative equity)
    func handleUnderwaterMortgage(propertyId: UUID, currentYear: Int) -> [String] {
        guard let property = getPropertyInvestment(id: propertyId),
              let mortgageAccountId = property.mortgageAccountId,
              let mortgage = getAccount(id: mortgageAccountId) else {
            return ["Property or mortgage not found"]
        }
        
        let mortgageBalance = abs(mortgage.balance)
        let negativeEquity = mortgageBalance - property.currentValue
        
        // Provide consequences and options
        var consequences = [
            "Your property is underwater by $\(Int(negativeEquity).formattedWithSeparator()).",
            "Options to consider:",
            "1. Continue making payments and wait for property values to recover",
            "2. Try to negotiate a loan modification with the bank",
            "3. Consider a short sale (bank agrees to accept less than owed)",
            "4. Consider strategic default (not recommended due to credit impact)"
        ]
        
        // Add specific consequences based on credit score impact
        consequences.append("Defaulting on your mortgage would reduce your credit score by 150-300 points and stay on your record for 7 years.")
        
        // Add tax consequences
        consequences.append("If the bank forgives any portion of your mortgage debt, it may be considered taxable income by the IRS.")
        
        return consequences
    }
    
    // Refinance property
    func refinanceProperty(propertyId: UUID, newTerm: Int, cashOut: Double, currentYear: Int) -> (success: Bool, message: String) {
        guard let property = getPropertyInvestment(id: propertyId) else {
            return (false, "Property not found")
        }
        
        // Check eligibility first
        let eligibility = canRefinanceProperty(propertyId: propertyId)
        if !eligibility.eligible {
            return (false, eligibility.reason)
        }
        
        // Get existing mortgage
        guard let mortgageAccountId = property.mortgageAccountId,
              let oldMortgage = getAccount(id: mortgageAccountId) else {
            return (false, "No active mortgage found for this property")
        }
        
        // Validate cash-out amount
        let maxCashOut = calculateMaxCashOut(propertyId: propertyId)
        if cashOut > maxCashOut {
            return (false, "Cash-out amount exceeds maximum allowed")
        }
        
        // Calculate new loan amount
        let oldBalance = abs(oldMortgage.balance)
        let newLoanAmount = oldBalance + cashOut
        
        // Calculate new interest rate based on current market conditions
        let baseRate = BankAccountType.mortgage.defaultInterestRate()
        let marketEffect = getCurrentMarketCondition().interestRateEffect()
        let propertyPremium = property.isRental ? 0.005 : 0.0 // +0.5% for rental properties
        let _ = baseRate + marketEffect + propertyPremium // Store as variable for reference
        
        // Close the old mortgage
        let closeResult = closeAccount(accountId: mortgageAccountId)
        if !closeResult.success {
            return (false, "Failed to close existing mortgage")
        }
        
        // Create new mortgage
        let newMortgage = openAccount(
            type: .mortgage,
            initialDeposit: -newLoanAmount, // Negative for debt
            currentYear: currentYear,
            term: newTerm
        )
        
        guard let newMortgage = newMortgage else {
            return (false, "Failed to create new mortgage")
        }
        
        // Update property with new mortgage ID
        if let index = propertyInvestments.firstIndex(where: { $0.id == propertyId }) {
            propertyInvestments[index].mortgageAccountId = newMortgage.id
        }
        
        // Add cash-out to character's cash if applicable
        if cashOut > 0 {
            characterMoney += cashOut
            
            // Record transaction
            let transaction = BankTransaction(
                type: .cashOut,
                amount: cashOut,
                description: "Cash-out refinance of property",
                date: Date(),
                year: currentYear
            )
            transactionHistory.append(transaction)
        }
        
        // Adjust credit score slightly (refinancing has a small temporary impact)
        adjustCreditScore(change: -5)
        
        return (true, "Successfully refinanced property" + (cashOut > 0 ? " with $\(Int(cashOut).formattedWithSeparator()) cash-out" : ""))
    }
}
