//
//  BankManager+PropertyInvestment.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

// Extension to BankManager to handle property investments
extension BankManager {
    // MARK: - Property Investment Management
    
    // Property investments collection
    @Published var propertyInvestments: [PropertyInvestment] = []
    
    // Create a new property investment with optional mortgage
    func createPropertyInvestment(propertyValue: Double, downPayment: Double, isRental: Bool, monthlyRent: Double = 0, term: Int = 30, currentYear: Int) -> (property: PropertyInvestment?, mortgage: BankAccount?) {
        // Minimum down payment is 20% for investment properties (higher than primary residence)
        let minimumDownPayment = propertyValue * 0.2
        
        if downPayment < minimumDownPayment {
            return (nil, nil)
        }
        
        // Create the collateral asset
        let collateral = addCollateralAsset(
            type: .realEstate,
            description: isRental ? "Investment Property" : "Residential Property",
            value: propertyValue,
            purchaseYear: currentYear
        )
        
        // Create mortgage if not paying cash
        var mortgage: BankAccount? = nil
        if downPayment < propertyValue {
            // Loan amount is property value minus down payment
            let loanAmount = propertyValue - downPayment
            
            // Create the mortgage account with slightly higher interest for investment property
            let baseInterestRate = BankAccountType.mortgage.defaultInterestRate()
            let investmentPropertyPremium = isRental ? 0.005 : 0.0 // 0.5% higher for rental properties
            
            // Open account with custom interest rate
            mortgage = openAccount(
                type: .mortgage,
                initialDeposit: loanAmount,
                currentYear: currentYear,
                term: term,
                collateralId: collateral.id
            )
            
            // Adjust interest rate if mortgage was created
            if let mortgageIndex = mortgage.flatMap({ account in
                accounts.firstIndex(where: { $0.id == account.id })
            }) {
                accounts[mortgageIndex].interestRate += investmentPropertyPremium
            }
        }
        
        // Create the property investment
        var propertyInvestment = PropertyInvestment(
            collateralId: collateral.id,
            purchasePrice: propertyValue,
            purchaseYear: currentYear,
            mortgageId: mortgage?.id
        )
        
        // Set up as rental if applicable
        if isRental {
            propertyInvestment.setupAsRental(monthlyRent: monthlyRent)
        }
        
        // Add to property investments collection
        propertyInvestments.append(propertyInvestment)
        
        // Add purchase transaction to history
        let transaction = BankTransaction(
            type: .purchase,
            amount: propertyValue,
            description: isRental ? "Purchased investment property" : "Purchased property",
            date: Date(),
            year: currentYear
        )
        transactionHistory.append(transaction)
        
        return (propertyInvestment, mortgage)
    }
    
    // Process monthly rental income for all properties
    func processMonthlyRentalIncome(currentYear: Int) -> Double {
        var totalNetIncome: Double = 0
        
        // Process each property
        for i in 0..<propertyInvestments.count {
            // Skip if not a rental
            if !propertyInvestments[i].isRental {
                continue
            }
            
            // Process monthly rental
            let rentalTransaction = propertyInvestments[i].processMonthlyRental(currentYear: currentYear)
            totalNetIncome += rentalTransaction.netIncome
            
            // Apply rental income to mortgage if applicable
            if let mortgageId = propertyInvestments[i].mortgageId,
               let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) {
                
                // Calculate monthly mortgage payment
                let mortgage = accounts[mortgageIndex]
                let principal = abs(mortgage.balance)
                let monthlyInterestRate = mortgage.interestRate / 12
                let remainingMonths = mortgage.term * 12 - (currentYear - mortgage.creationYear) * 12
                
                if remainingMonths > 0 {
                    let monthlyPayment = calculateMortgagePayment(
                        principal: principal,
                        monthlyInterestRate: monthlyInterestRate,
                        numberOfPayments: remainingMonths
                    )
                    
                    // Apply rental income to mortgage payment
                    let paymentFromRental = min(rentalTransaction.netIncome, monthlyPayment)
                    if paymentFromRental > 0 {
                        _ = accounts[mortgageIndex].makePayment(amount: paymentFromRental)
                        
                        // Add transaction record
                        let mortgageTransaction = BankTransaction(
                            type: .payment,
                            amount: paymentFromRental,
                            description: "Mortgage payment from rental income",
                            date: Date(),
                            year: currentYear
                        )
                        transactionHistory.append(mortgageTransaction)
                    }
                }
            }
            
            // Add rental income transaction to history
            let rentalIncomeTransaction = BankTransaction(
                type: .deposit,
                amount: rentalTransaction.netIncome,
                description: "Net rental income",
                date: rentalTransaction.date,
                year: currentYear
            )
            transactionHistory.append(rentalIncomeTransaction)
        }
        
        return totalNetIncome
    }
    
    // Update property values based on market conditions
    func updatePropertyValues(currentYear: Int) {
        for i in 0..<propertyInvestments.count {
            propertyInvestments[i].updateValue(currentYear: currentYear, marketCondition: marketCondition)
            
            // Update the corresponding collateral asset value
            if let collateralIndex = collateralAssets.firstIndex(where: { $0.id == propertyInvestments[i].collateralId }) {
                collateralAssets[collateralIndex].value = propertyInvestments[i].currentValue
            }
        }
    }
    
    // Get all property investments
    func getPropertyInvestments() -> [PropertyInvestment] {
        return propertyInvestments
    }
    
    // Get property investment by ID
    func getPropertyInvestment(id: UUID) -> PropertyInvestment? {
        return propertyInvestments.first { $0.id == id }
    }
    
    // Get property investments with mortgages
    func getFinancedProperties() -> [PropertyInvestment] {
        return propertyInvestments.filter { $0.mortgageId != nil }
    }
    
    // Get rental properties
    func getRentalProperties() -> [PropertyInvestment] {
        return propertyInvestments.filter { $0.isRental }
    }
    
    // Calculate total equity in all properties
    func calculateTotalPropertyEquity(currentYear: Int) -> Double {
        var totalEquity: Double = 0
        
        for property in propertyInvestments {
            var propertyValue = property.currentValue
            var mortgageBalance: Double = 0
            
            // Get mortgage balance if applicable
            if let mortgageId = property.mortgageId,
               let mortgage = getAccount(id: mortgageId) {
                mortgageBalance = abs(mortgage.balance)
            }
            
            // Equity = Value - Mortgage Balance
            let equity = propertyValue - mortgageBalance
            totalEquity += equity
        }
        
        return totalEquity
    }
    
    // Calculate total annual rental income
    func calculateTotalAnnualRentalIncome() -> Double {
        return propertyInvestments
            .filter { $0.isRental }
            .reduce(0) { $0 + $1.calculateAnnualRentalIncome() }
    }
    
    // Calculate total annual rental expenses
    func calculateTotalAnnualRentalExpenses() -> Double {
        return propertyInvestments
            .filter { $0.isRental }
            .reduce(0) { $0 + $1.calculateAnnualExpenses() }
    }
    
    // Calculate total annual net rental income
    func calculateTotalAnnualNetRentalIncome() -> Double {
        return propertyInvestments
            .filter { $0.isRental }
            .reduce(0) { $0 + $1.calculateAnnualNetRentalIncome() }
    }
    
    // Convert a regular property to a rental property
    func convertToRental(propertyId: UUID, monthlyRent: Double, occupancyRate: Double = 0.95) -> Bool {
        guard let index = propertyInvestments.firstIndex(where: { $0.id == propertyId }) else {
            return false
        }
        
        propertyInvestments[index].setupAsRental(monthlyRent: monthlyRent, occupancyRate: occupancyRate)
        return true
    }
    
    // Helper method to calculate mortgage payment
    private func calculateMortgagePayment(principal: Double, monthlyInterestRate: Double, numberOfPayments: Int) -> Double {
        // Handle edge cases
        if monthlyInterestRate <= 0 || numberOfPayments <= 0 {
            return principal / numberOfPayments
        }
        
        // Standard mortgage payment formula: P * (r(1+r)^n) / ((1+r)^n - 1)
        let rate = monthlyInterestRate
        let rateFactorNumerator = rate * pow(1 + rate, Double(numberOfPayments))
        let rateFactorDenominator = pow(1 + rate, Double(numberOfPayments)) - 1
        
        return principal * (rateFactorNumerator / rateFactorDenominator)
    }
}