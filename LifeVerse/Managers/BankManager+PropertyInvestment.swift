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
            _ = BankAccountType.mortgage.defaultInterestRate()
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
            let propertyValue = property.currentValue
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
    func calculateMortgagePayment(principal: Double, monthlyInterestRate: Double, numberOfPayments: Int) -> Double {
        // Handle edge cases
        if monthlyInterestRate <= 0 || numberOfPayments <= 0 {
            return principal / Double(numberOfPayments)
        }

        // Standard mortgage payment formula: P * (r(1+r)^n) / ((1+r)^n - 1)
        let rate = monthlyInterestRate
        let rateFactorNumerator = rate * pow(1 + rate, Double(numberOfPayments))
        let rateFactorDenominator = pow(1 + rate, Double(numberOfPayments)) - 1

        return principal * (rateFactorNumerator / rateFactorDenominator)
    }

    // MARK: - Property Refinancing

    // Calculate the current loan-to-value ratio for a property
    func calculatePropertyLTV(propertyId: UUID) -> Double? {
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }),
              let mortgageId = propertyInvestments[propertyIndex].mortgageId,
              let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) else {
            return nil
        }

        let propertyValue = propertyInvestments[propertyIndex].currentValue
        let mortgageBalance = abs(accounts[mortgageIndex].balance)

        return mortgageBalance / propertyValue
    }

    // Check if a property is in negative equity (LTV > 1.0)
    func isPropertyInNegativeEquity(propertyId: UUID) -> Bool {
        guard let ltv = calculatePropertyLTV(propertyId: propertyId) else {
            return false
        }

        return ltv > 1.0
    }

    // Check if a property is eligible for refinancing
    func canRefinanceProperty(propertyId: UUID) -> (eligible: Bool, reason: String) {
        // Find the property
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }) else {
            return (false, "Property not found")
        }

        // Check if property has a mortgage
        guard let mortgageId = propertyInvestments[propertyIndex].mortgageId,
              let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) else {
            return (false, "Property does not have a mortgage")
        }

        // Check credit score (minimum 620 for refinancing)
        if creditScore < 620 {
            return (false, "Credit score too low (minimum 620 required)")
        }

        // Check LTV ratio (maximum 95% for refinancing)
        let propertyValue = propertyInvestments[propertyIndex].currentValue
        let mortgageBalance = abs(accounts[mortgageIndex].balance)
        let ltv = mortgageBalance / propertyValue

        if ltv > 0.95 {
            return (false, "Loan-to-value ratio too high (maximum 95% allowed)")
        }

        // Check if mortgage is too new (minimum 6 months)
        let mortgage = accounts[mortgageIndex]
        if mortgage.creationYear == mortgage.lastTransactionYear &&
           mortgage.transactions.count < 6 {
            return (false, "Mortgage too new (minimum 6 months required)")
        }

        return (true, "Eligible for refinancing")
    }

    // Refinance a property with a new mortgage
    func refinanceProperty(propertyId: UUID, newTerm: Int, cashOut: Double = 0, currentYear: Int) -> (success: Bool, newMortgage: BankAccount?, message: String) {
        // Check eligibility
        let eligibility = canRefinanceProperty(propertyId: propertyId)
        if !eligibility.eligible {
            return (false, nil, eligibility.reason)
        }

        // Find the property and its mortgage
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }),
              let mortgageId = propertyInvestments[propertyIndex].mortgageId,
              let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) else {
            return (false, nil, "Property or mortgage not found")
        }

        let property = propertyInvestments[propertyIndex]
        let oldMortgage = accounts[mortgageIndex]
        let oldMortgageBalance = abs(oldMortgage.balance)

        // Calculate new loan amount (including cash out if requested)
        let propertyValue = property.currentValue
        let newLoanAmount = oldMortgageBalance + cashOut

        // Check if new loan amount exceeds maximum LTV (80% for cash-out, 95% for rate/term)
        let maxLTV = cashOut > 0 ? 0.8 : 0.95
        let maxLoanAmount = propertyValue * maxLTV

        if newLoanAmount > maxLoanAmount {
            return (false, nil, "New loan amount exceeds maximum allowed (\(Int(maxLTV * 100))% of property value)")
        }

        // Find the collateral asset
        guard collateralAssets.firstIndex(where: { $0.id == property.collateralId }) != nil else {
            return (false, nil, "Collateral asset not found")
        }

        // Create the new mortgage account
        _ = BankAccountType.mortgage.defaultInterestRate()
        let investmentPropertyPremium = property.isRental ? 0.005 : 0.0 // 0.5% higher for rental properties

        // Apply market condition effect to interest rate
        _ = marketCondition.interestRateEffect()

        // Create the new mortgage
        guard let newMortgage = openAccount(
            type: .mortgage,
            initialDeposit: newLoanAmount,
            currentYear: currentYear,
            term: newTerm,
            collateralId: property.collateralId
        ) else {
            return (false, nil, "Failed to create new mortgage")
        }

        // Adjust interest rate for the new mortgage
        if let newMortgageIndex = accounts.firstIndex(where: { $0.id == newMortgage.id }) {
            accounts[newMortgageIndex].interestRate += investmentPropertyPremium
        }

        // Pay off the old mortgage
        _ = accounts[mortgageIndex].makePayment(amount: oldMortgageBalance)

        // Close the old mortgage account
        _ = closeAccount(accountId: oldMortgage.id)

        // Update the property's mortgage ID
        propertyInvestments[propertyIndex].mortgageId = newMortgage.id

        // Add transaction records
        let refinanceTransaction = BankTransaction(
            type: .transfer,
            amount: oldMortgageBalance,
            description: "Refinanced mortgage for property",
            date: Date(),
            year: currentYear
        )
        transactionHistory.append(refinanceTransaction)

        // Add cash-out transaction if applicable
        if cashOut > 0 {
            let cashOutTransaction = BankTransaction(
                type: .withdrawal,
                amount: cashOut,
                description: "Cash-out from property refinance",
                date: Date(),
                year: currentYear
            )
            transactionHistory.append(cashOutTransaction)
        }

        return (true, newMortgage, "Successfully refinanced property")
    }

    // Calculate maximum cash-out amount for a property
    func calculateMaxCashOut(propertyId: UUID) -> Double {
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }),
              let mortgageId = propertyInvestments[propertyIndex].mortgageId,
              let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) else {
            return 0
        }

        let propertyValue = propertyInvestments[propertyIndex].currentValue
        let currentMortgageBalance = abs(accounts[mortgageIndex].balance)

        // Maximum LTV for cash-out refinance is 80%
        let maxLoanAmount = propertyValue * 0.8

        // Maximum cash-out is the difference between max loan amount and current balance
        let maxCashOut = maxLoanAmount - currentMortgageBalance

        return max(0, maxCashOut)
    }

    // Handle underwater mortgage (negative equity)
    func handleUnderwaterMortgage(propertyId: UUID, currentYear: Int) -> [String] {
        guard let propertyIndex = propertyInvestments.firstIndex(where: { $0.id == propertyId }),
              let mortgageId = propertyInvestments[propertyIndex].mortgageId,
              let mortgageIndex = accounts.firstIndex(where: { $0.id == mortgageId }) else {
            return ["Property or mortgage not found"]
        }

        let property = propertyInvestments[propertyIndex]
        let mortgage = accounts[mortgageIndex]
        let propertyValue = property.currentValue
        let mortgageBalance = abs(mortgage.balance)

        // Calculate how underwater the property is
        let underwaterAmount = mortgageBalance - propertyValue
        let ltv = mortgageBalance / propertyValue

        var consequences = [String]()

        // Credit score impact based on severity of negative equity
        if ltv > 1.5 { // Severely underwater (150%+ LTV)
            adjustCreditScore(change: -50)
            consequences.append("Severe negative equity has significantly damaged your credit score (-50 points)")
        } else if ltv > 1.25 { // Moderately underwater (125-150% LTV)
            adjustCreditScore(change: -30)
            consequences.append("Moderate negative equity has damaged your credit score (-30 points)")
        } else if ltv > 1.0 { // Slightly underwater (100-125% LTV)
            adjustCreditScore(change: -15)
            consequences.append("Slight negative equity has affected your credit score (-15 points)")
        }

        // Increased interest rate due to risk
        if ltv > 1.0 {
            let riskPremium = min(0.02 * (ltv - 1.0) * 10, 0.05) // Up to 5% additional interest
            accounts[mortgageIndex].interestRate += riskPremium
            consequences.append("Mortgage interest rate increased by \(String(format: "%.2f", riskPremium * 100))% due to negative equity risk")
        }

        // Add transaction record for the negative equity situation
        let negativeEquityTransaction = BankTransaction(
            type: .fee,
            amount: underwaterAmount,
            description: "Negative equity recorded on property",
            date: Date(),
            year: currentYear
        )
        transactionHistory.append(negativeEquityTransaction)

        return consequences
    }
}