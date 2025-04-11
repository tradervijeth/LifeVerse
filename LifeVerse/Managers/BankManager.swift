//
//  BankManager.swift
//  LifeVerse
//
import Foundation
import SwiftUI
import Combine

// Make BankManager conform to BankManagerProtocol for PropertyInvestment
class BankManager: ObservableObject, BankManagerProtocol, Codable {
    // Published properties
    @Published var accounts: [Banking_Account] = []
    @Published var loans: [Banking_Loan] = []
    @Published var investments: [Banking_Investment] = []
    @Published var transactionHistory: [Banking_Transaction] = []
    @Published var collateralAssets: [Banking_CollateralAsset] = []
    @Published var propertyInvestments: [PropertyInvestment] = []
    @Published var taxPaymentHistory: [TaxPayment] = []
    @Published var employmentHistory: [EmploymentRecord] = []

    // Private properties
    private var characterMoney: Double = 0
    var characterBirthYear: Int = 0

    // MARK: - Initialization

    init() {
        // Initialize with empty collections
    }

    // MARK: - Public Methods

    // Get the character's money
    func getCharacterMoney() -> Double {
        return characterMoney
    }

    // Set the character's money
    func setCharacterMoney(_ money: Double) {
        characterMoney = money
    }

    // Process yearly financial updates
    func processYearlyUpdate(currentYear: Int) -> [LifeEvent] {
        var events: [LifeEvent] = []

        // Process accounts
        for i in 0..<accounts.count {
            if accounts[i].isActive {
                // Apply interest to accounts
                let interestEarned = applyInterestToAccount(index: i, currentYear: currentYear)

                // Create interest event if significant
                if interestEarned > 0.01 {
                    let interestEvent = LifeEvent(
                        title: "Account Interest",
                        description: "You earned interest on your \(accounts[i].accountType.rawValue).",
                        type: .financial,
                        year: currentYear,
                        outcome: "You earned $\(Int(interestEarned).formattedWithSeparator()) in interest.",
                        effects: []
                    )
                    events.append(interestEvent)
                }
            }
        }

        // Process loans
        for i in 0..<loans.count {
            if !loans[i].isClosed {
                // Apply interest to loans
                let interestAccrued = applyInterestToLoan(index: i, currentYear: currentYear)

                // Create interest event if significant
                if interestAccrued > 0.01 {
                    let interestEvent = LifeEvent(
                        title: "Loan Interest",
                        description: "Interest accrued on your \(loans[i].type.rawValue).",
                        type: .financial,
                        year: currentYear,
                        outcome: "Your loan accrued $\(Int(interestAccrued).formattedWithSeparator()) in interest.",
                        effects: []
                    )
                    events.append(interestEvent)
                }
            }
        }

        // Update investments based on market conditions
        let bankingMarketCondition = Banking_MarketCondition.currentYear() == currentYear ?
                                     Banking_MarketCondition.normal : getMarketConditionForYear(currentYear)

        for i in 0..<investments.count {
            let valueChange = updateInvestmentValue(index: i, currentYear: currentYear, marketCondition: bankingMarketCondition)

            // Create investment event if significant change
            if abs(valueChange) > 0.01 {
                let changeDirection = valueChange > 0 ? "increased" : "decreased"
                let investmentEvent = LifeEvent(
                    title: "Investment Update",
                    description: "Your \(investments[i].name) \(changeDirection) in value.",
                    type: .financial,
                    year: currentYear,
                    outcome: "Value change: $\(Int(valueChange).formattedWithSeparator()).",
                    effects: []
                )
                events.append(investmentEvent)
            }
        }

        // Update property values based on market conditions
        for i in 0..<propertyInvestments.count {
            let valueChange = propertyInvestments[i].updateValue(currentYear: currentYear, marketCondition: bankingMarketCondition)

            // Create property event if significant change
            if abs(valueChange) > 1000 {
                let changeDirection = valueChange > 0 ? "increased" : "decreased"
                let propertyEvent = LifeEvent(
                    title: "Property Value Change",
                    description: "Your property \(changeDirection) in value.",
                    type: .financial,
                    year: currentYear,
                    outcome: "Value change: $\(Int(valueChange).formattedWithSeparator()).",
                    effects: []
                )
                events.append(propertyEvent)
            }

            // Calculate and add rental income if applicable
            if propertyInvestments[i].isRental && propertyInvestments[i].monthlyRent > 0 {
                let annualRent = propertyInvestments[i].calculateAnnualRentalIncome()

                // Add rental income to character's money
                characterMoney += annualRent

                // Add MONTHLY rental income transaction for reporting purposes
                let monthlyRent = propertyInvestments[i].monthlyRent * propertyInvestments[i].occupancyRate
                let monthlyTransaction = Banking_Transaction(
                    date: Date(),
                    type: .deposit,
                    amount: monthlyRent,
                    description: "Rental income from Rental Property",
                    year: currentYear
                )
                transactionHistory.append(monthlyTransaction)

                // Create a transaction record for ANNUAL rental income (for summary purposes)
                let rentalTransaction = Banking_Transaction(
                    date: Date(),
                    type: .deposit,
                    amount: annualRent,
                    description: "Annual rental income from property",
                    year: currentYear
                )
                transactionHistory.append(rentalTransaction)

                // Create rental income event
                let rentalEvent = LifeEvent(
                    title: "Rental Income",
                    description: "You collected rent from your investment property.",
                    type: .financial,
                    year: currentYear,
                    outcome: "Annual rental income: $\(Int(annualRent).formattedWithSeparator()).",
                    effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(annualRent))]
                )
                events.append(rentalEvent)
            }
        }

        return events
    }

    // Helper method to apply interest to an account
    private func applyInterestToAccount(index: Int, currentYear: Int) -> Double {
        // Placeholder for account interest calculation
        return 0.0
    }

    // Helper method to apply interest to a loan
    private func applyInterestToLoan(index: Int, currentYear: Int) -> Double {
        // Placeholder for loan interest calculation
        return 0.0
    }

    // Helper method to update investment value
    private func updateInvestmentValue(index: Int, currentYear: Int, marketCondition: Banking_MarketCondition) -> Double {
        // Placeholder for investment value update
        return 0.0
    }

    // Get market condition for a specific year
    private func getMarketConditionForYear(_ year: Int) -> Banking_MarketCondition {
        // Simple algorithm to generate market conditions
        let baseValue = year % 7
        switch baseValue {
        case 0: return .depression
        case 1: return .recession
        case 2, 3: return .recovery
        case 4: return .normal
        case 5: return .expansion
        case 6: return .boom
        default: return .normal
        }
    }

    // Get active accounts
    func getActiveAccounts() -> [Banking_Account] {
        return accounts.filter { $0.isActive }
    }

    // Get specific account by ID
    func getAccount(id: UUID) -> Banking_Account? {
        return accounts.first { $0.id == id }
    }

    // Convert a property to a rental
    func convertPropertyToRental(propertyId: UUID, monthlyRent: Double, occupancyRate: Double) -> Bool {
        // Find the property
        guard let index = propertyInvestments.firstIndex(where: { $0.id == propertyId }) else {
            return false
        }

        // Update the property
        var property = propertyInvestments[index]
        property.isRental = true
        property.monthlyRent = monthlyRent
        property.occupancyRate = occupancyRate

        // Update the property in the collection
        propertyInvestments[index] = property

        // Create a transaction record
        let transaction = Banking_Transaction(
            date: Date(),
            type: .specialEvent,
            amount: 0,
            description: "Converted property to rental with monthly rent of $\(Int(monthlyRent))",
            year: Calendar.current.component(.year, from: Date())
        )
        transactionHistory.append(transaction)

        return true
    }

    // Open a new account
    @discardableResult
    func openAccount(type: Banking_AccountType, initialDeposit: Double, loanAmount: Double = 0, term: Int = 0) -> Banking_Account? {
        let interest = getBaseInterestRate(for: type) + Double.random(in: -0.005...0.005)
        var account = Banking_Account(
            accountType: type,
            balance: type == .mortgage ? 0 : initialDeposit,
            interestRate: interest,
            term: term,
            creationYear: Calendar.current.component(.year, from: Date())
        )

        // For mortgage accounts, set up the correct structure
        if type == .mortgage {
            // Set the balance to negative to represent debt
            account.balance = -abs(initialDeposit)

            // Create loan transaction for the mortgage
            let transaction = Banking_Transaction(
                date: Date(),
                type: .loan,
                amount: initialDeposit,
                description: "Mortgage loan disbursement",
                year: Calendar.current.component(.year, from: Date())
            )
            account.transactions.append(transaction)
        } else {
            // For non-mortgage accounts, deduct the deposit from character money
            if initialDeposit > 0 {
                if characterMoney >= initialDeposit {
                    characterMoney -= initialDeposit
                } else {
                    // Not enough money
                    return nil
                }
            }
        }

        accounts.append(account)

        return account
    }

    // Get base interest rate for account type
    private func getBaseInterestRate(for accountType: Banking_AccountType) -> Double {
        switch accountType {
        case .checking: return 0.0025 // 0.25%
        case .savings: return 0.01 // 1%
        case .cd: return 0.025 // 2.5%
        case .mortgage: return 0.045 // 4.5%
        case .loan: return 0.08 // 8%
        case .creditCard: return 0.18 // 18%
        case .investment: return 0.0 // Variable returns
        case .autoLoan: return 0.045 // 4.5%
        case .studentLoan: return 0.04 // 4%
        case .businessAccount: return 0.015 // 1.5%
        case .retirementAccount: return 0.0 // Variable returns
        }
    }

    // Deposit money to an account
    func deposit(accountId: UUID, amount: Double) -> Bool {
        guard amount > 0 else { return false }

        // Find the account
        if let index = accounts.firstIndex(where: { $0.id == accountId }) {
            if accounts[index].isActive {
                // Ensure character has enough money
                if characterMoney >= amount {
                    // Call deposit method on the account
                    let success = depositToAccount(index: index, amount: amount)
                    if success {
                        characterMoney -= amount

                        // Add transaction
                        let transaction = Banking_Transaction(
                            date: Date(),
                            type: .deposit,
                            amount: amount,
                            description: "Deposit to \(accounts[index].accountType.rawValue)",
                            year: Calendar.current.component(.year, from: Date())
                        )
                        transactionHistory.append(transaction)
                        return true
                    }
                }
            }
        }
        return false
    }

    // Helper method to deposit to an account
    private func depositToAccount(index: Int, amount: Double) -> Bool {
        // Placeholder for account deposit implementation
        return true
    }

    // Withdraw money from an account
    func withdraw(accountId: UUID, amount: Double) -> Bool {
        guard amount > 0 else { return false }

        // Find the account
        if let index = accounts.firstIndex(where: { $0.id == accountId }) {
            if accounts[index].isActive {
                // Call withdraw method on the account
                let success = withdrawFromAccount(index: index, amount: amount)
                if success {
                    characterMoney += amount

                    // Add transaction
                    let transaction = Banking_Transaction(
                        date: Date(),
                        type: .withdrawal,
                        amount: amount,
                        description: "Withdrawal from \(accounts[index].accountType.rawValue)",
                        year: Calendar.current.component(.year, from: Date())
                    )
                    transactionHistory.append(transaction)
                    return true
                }
            }
        }
        return false
    }

    // Helper method to withdraw from an account
    private func withdrawFromAccount(index: Int, amount: Double) -> Bool {
        // Placeholder for account withdrawal implementation
        return true
    }

    // Add collateral asset
    @discardableResult
    func addCollateralAsset(type: Banking_CollateralType, description: String, value: Double, purchaseYear: Int) -> Banking_CollateralAsset {
        let asset = Banking_CollateralAsset(
            type: type,
            description: description,
            value: value,
            purchaseYear: purchaseYear
        )
        collateralAssets.append(asset)
        return asset
    }

    // Get property investments
    func getPropertyInvestments() -> [PropertyInvestment] {
        return propertyInvestments
    }

    // Create a new investment
    @discardableResult
    func makeInvestment(type: Banking_InvestmentType, name: String, amount: Double, riskLevel: Banking_RiskLevel) -> Banking_Investment? {
        // Check if there's enough money
        if characterMoney < amount {
            return nil
        }

        // Create the investment object
        var investment = Banking_Investment(
            type: type,
            name: name,
            initialValue: amount,
            purchaseYear: Calendar.current.component(.year, from: Date()),
            riskLevel: riskLevel
        )

        // Deduct from character's money
        characterMoney -= amount

        // Create an investment account if needed
        let account = openAccount(type: .investment, initialDeposit: amount)
        if let account = account {
            investment.accountId = account.id
        }

        // Add to investments collection
        investments.append(investment)

        // Create transaction record
        let transaction = Banking_Transaction(
            date: Date(),
            type: .investment,
            amount: amount,
            description: "Investment in \(name)",
            year: Calendar.current.component(.year, from: Date())
        )
        transactionHistory.append(transaction)

        return investment
    }

    // Calculate net worth
    func calculateNetWorth(currentYear: Int) -> Double {
        var netWorth: Double = 0

        // Add character's cash
        netWorth += characterMoney

        // Add bank account balances (only positive balances)
        for account in accounts where account.isActive {
            if account.balance > 0 {
                netWorth += account.balance
            }
        }

        // Add investment values
        for investment in investments {
            netWorth += investment.currentValue
        }

        // Add property equity (value minus mortgage) instead of full value
        netWorth += calculateTotalPropertyEquity(currentYear: currentYear)

        // Add other loans/debts (excluding mortgages which are already accounted for in property equity)
        for account in accounts where account.isActive &&
            account.accountType != .mortgage &&
            account.balance < 0 {
            netWorth += account.balance // Adding because loan balances are stored as negative
        }

        return netWorth
    }

    // MARK: - Taxation methods

    // Calculate income tax
    func calculateIncomeTax(currentYear: Int) -> Double {
        // Get total income for the year
        var totalIncome: Double = 0

        // Add employment income
        for record in employmentHistory where getYearFromDate(record.date) == currentYear {
            totalIncome += record.income
        }

        // Simple progressive tax calculation
        var tax: Double = 0

        if totalIncome <= 10000 {
            tax = totalIncome * 0.10
        } else if totalIncome <= 40000 {
            tax = 1000 + (totalIncome - 10000) * 0.15
        } else if totalIncome <= 85000 {
            tax = 5500 + (totalIncome - 40000) * 0.25
        } else if totalIncome <= 163000 {
            tax = 16750 + (totalIncome - 85000) * 0.28
        } else if totalIncome <= 207000 {
            tax = 38590 + (totalIncome - 163000) * 0.33
        } else {
            tax = 53090 + (totalIncome - 207000) * 0.37
        }

        return tax
    }

    // Calculate property tax
    func calculatePropertyTax(currentYear: Int) -> Double {
        var totalPropertyTax: Double = 0

        // Calculate property tax for each property
        for property in propertyInvestments {
            let propertyTax = property.currentValue * property.propertyTaxRate
            totalPropertyTax += propertyTax
        }

        return totalPropertyTax
    }

    // Calculate capital gains tax
    func calculateCapitalGainsTax(currentYear: Int) -> Double {
        var totalCapitalGains: Double = 0

        // Calculate capital gains from selling investments
        for transaction in transactionHistory
            where transaction.type.rawValue == "Investment Return" && getYearFromDate(transaction.date) == currentYear {
            // Simple approximation - assuming 15% of sale amount is capital gains
            let capitalGains = transaction.amount * 0.15
            totalCapitalGains += capitalGains
        }

        // Calculate tax rate (simplified)
        let taxRate = 0.15 // 15% capital gains tax rate

        return totalCapitalGains * taxRate
    }

    // Calculate interest income tax
    func calculateInterestIncomeTax(currentYear: Int) -> Double {
        var totalInterestIncome: Double = 0

        // Calculate interest income from accounts
        for transaction in transactionHistory
            where transaction.type == .interest && getYearFromDate(transaction.date) == currentYear {
            totalInterestIncome += transaction.amount
        }

        // Use the same income tax rate
        let taxRate = 0.25 // 25% tax rate

        return totalInterestIncome * taxRate
    }

    // Get year from date helper
    private func getYearFromDate(_ date: Date) -> Int {
        return Calendar.current.component(.year, from: date)
    }

    // MARK: - Codable Implementation

    enum CodingKeys: String, CodingKey {
        case accounts, loans, investments, transactionHistory, collateralAssets
        case propertyInvestments, taxPaymentHistory, employmentHistory
        case characterMoney, characterBirthYear
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(accounts, forKey: .accounts)
        try container.encode(loans, forKey: .loans)
        try container.encode(investments, forKey: .investments)
        try container.encode(transactionHistory, forKey: .transactionHistory)
        try container.encode(collateralAssets, forKey: .collateralAssets)
        try container.encode(propertyInvestments, forKey: .propertyInvestments)
        try container.encode(taxPaymentHistory, forKey: .taxPaymentHistory)
        try container.encode(employmentHistory, forKey: .employmentHistory)
        try container.encode(characterMoney, forKey: .characterMoney)
        try container.encode(characterBirthYear, forKey: .characterBirthYear)
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        accounts = try container.decode([Banking_Account].self, forKey: .accounts)
        loans = try container.decode([Banking_Loan].self, forKey: .loans)
        investments = try container.decode([Banking_Investment].self, forKey: .investments)
        transactionHistory = try container.decode([Banking_Transaction].self, forKey: .transactionHistory)
        collateralAssets = try container.decode([Banking_CollateralAsset].self, forKey: .collateralAssets)
        propertyInvestments = try container.decode([PropertyInvestment].self, forKey: .propertyInvestments)
        taxPaymentHistory = try container.decode([TaxPayment].self, forKey: .taxPaymentHistory)
        employmentHistory = try container.decode([EmploymentRecord].self, forKey: .employmentHistory)
        characterMoney = try container.decode(Double.self, forKey: .characterMoney)
        characterBirthYear = try container.decode(Int.self, forKey: .characterBirthYear)
    }
}
