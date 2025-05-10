//
//  BankManager.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation
import SwiftUI

class BankManager: ObservableObject, BankManagerProtocol, Codable {
    @Published var accounts: [BankAccount] = []
    @Published var creditScore: Int = 650 // Starting credit score (300-850 range)
    @Published var collateralAssets: [LoanCollateral] = []
    @Published var marketCondition: MarketCondition = .normal // Current economic condition
    @Published var transactionHistory: [BankTransaction] = [] // Global transaction history
    @Published var propertyInvestments: [PropertyInvestment] = []
    @Published var taxPaymentHistory: [TaxPayment] = []
    @Published var employmentHistory: [EmploymentRecord] = []
    
    // Private properties
    private var _taxationSystem: TaxationSystem?
    private var _employmentStatus: EmploymentStatus = .employed
    
    // Property to access character's money (to be set by GameManager)
    public var characterMoney: Double = 0
    public var characterBirthYear: Int = 0
    
    // Methods to get and set character money (for GameManager)
    func getCharacterMoney() -> Double {
        return characterMoney
    }
    
    func setCharacterMoney(_ amount: Double) {
        characterMoney = amount
        objectWillChange.send()
    }
    
    // Annual income tracking
    public var annualIncome: Double = 0
    
    // Employment status enum
    enum EmploymentStatus: String, Codable {
        case employed = "Employed"
        case unemployed = "Unemployed"
        case selfEmployed = "Self-Employed"
        case retired = "Retired"
        case student = "Student"
    }
    
    // Taxation system accessor
    var taxationSystem: TaxationSystem {
        get {
            if _taxationSystem == nil {
                _taxationSystem = TaxationSystem()
            }
            return _taxationSystem!
        }
        set {
            _taxationSystem = newValue
            objectWillChange.send()
        }
    }
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case accounts, creditScore, collateralAssets, marketCondition
        case transactionHistory, propertyInvestments, taxPaymentHistory
        case employmentHistory, characterMoney, characterBirthYear
        case taxationSystem, employmentStatus, annualIncome
    }
    
    // MARK: - Initialization and Codable Implementation
    
    init() {
        // Initialize with empty collections
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accounts = try container.decode([BankAccount].self, forKey: .accounts)
        creditScore = try container.decode(Int.self, forKey: .creditScore)
        collateralAssets = try container.decode([LoanCollateral].self, forKey: .collateralAssets)
        marketCondition = try container.decode(MarketCondition.self, forKey: .marketCondition)
        transactionHistory = try container.decode([BankTransaction].self, forKey: .transactionHistory)
        propertyInvestments = try container.decode([PropertyInvestment].self, forKey: .propertyInvestments)
        // Decode tax payment history - safely handling potential type mismatches
        do {
            taxPaymentHistory = try container.decode([TaxPayment].self, forKey: .taxPaymentHistory)
        } catch {
            print("Failed to decode tax payment history: \(error)")
            taxPaymentHistory = []
        }
        
        // Decode employment history - safely handling potential type mismatches
        do {
            employmentHistory = try container.decode([EmploymentRecord].self, forKey: .employmentHistory)
        } catch {
            print("Failed to decode employment history: \(error)")
            employmentHistory = []
        }
        characterMoney = try container.decode(Double.self, forKey: .characterMoney)
        characterBirthYear = try container.decode(Int.self, forKey: .characterBirthYear)
        annualIncome = try container.decodeIfPresent(Double.self, forKey: .annualIncome) ?? 0
        
        // Decode optional properties
        _taxationSystem = try container.decodeIfPresent(TaxationSystem.self, forKey: .taxationSystem)
        _employmentStatus = try container.decodeIfPresent(EmploymentStatus.self, forKey: .employmentStatus) ?? .employed
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts, forKey: .accounts)
        try container.encode(creditScore, forKey: .creditScore)
        try container.encode(collateralAssets, forKey: .collateralAssets)
        try container.encode(marketCondition, forKey: .marketCondition)
        try container.encode(transactionHistory, forKey: .transactionHistory)
        try container.encode(propertyInvestments, forKey: .propertyInvestments)
        try container.encode(taxPaymentHistory, forKey: .taxPaymentHistory)
        try container.encode(employmentHistory, forKey: .employmentHistory)
        try container.encode(characterMoney, forKey: .characterMoney)
        try container.encode(characterBirthYear, forKey: .characterBirthYear)
        try container.encode(annualIncome, forKey: .annualIncome)
        
        try container.encodeIfPresent(_taxationSystem, forKey: .taxationSystem)
        try container.encode(_employmentStatus, forKey: .employmentStatus)
    }
    
    // MARK: - BankManagerProtocol Implementation
    
    // Account Management
    func getAccounts() -> [BankAccount] {
        return accounts
    }
    
    func getActiveAccounts() -> [BankAccount] {
        return accounts.filter { $0.isActive }
    }
    
    func getAccount(id: UUID) -> BankAccount? {
        return accounts.first { $0.id == id }
    }
    
    func openAccount(type: BankAccountType, initialDeposit: Double, currentYear: Int, term: Int? = nil, collateralId: UUID? = nil) -> BankAccount? {
        // Check if initial deposit meets minimum requirement
        if initialDeposit < type.minimumInitialDeposit() {
            return nil
        }
        
        // Adjust interest rate based on market conditions
        let interestRate = type.defaultInterestRate()
        
        // Create the account
        var account = BankAccount(
            accountType: type,
            initialDeposit: initialDeposit,
            interestRate: interestRate,
            creationYear: currentYear
        )
        
        // Set term if provided
        if let term = term {
            account.term = term
        }
        
        // Add the account
        accounts.append(account)
        
        // Add transaction record
        let transactionType: BankTransactionType = (type == .loan || type == .mortgage || 
                                                    type == .autoLoan || type == .studentLoan) ? 
                                                    .loan : .deposit
        
        let transaction = BankTransaction(
            type: transactionType,
            amount: initialDeposit,
            description: "Opened new \(type.rawValue) account",
            date: Date(),
            year: currentYear
        )
        transactionHistory.append(transaction)
        
        return account
    }
    
    func closeAccount(accountId: UUID) -> (success: Bool, balance: Double) {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            return (false, 0)
        }
        
        let account = accounts[index]
        
        // Can't close accounts with negative balance
        if account.balance < 0 {
            return (false, account.balance)
        }
        
        // Mark as inactive instead of removing
        accounts[index].isActive = false
        
        // Return the remaining balance
        return (true, account.balance)
    }
    
    // Transaction Operations
    func deposit(accountId: UUID, amount: Double) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            return false
        }
        
        // Try to deposit
        let success = accounts[index].deposit(amount: amount)
        
        // Add to transaction history
        if success {
            let transaction = BankTransaction(
                type: .deposit,
                amount: amount,
                description: "Deposit to \(accounts[index].accountType.rawValue)",
                date: Date(),
                year: Calendar.current.component(.year, from: Date())
            )
            transactionHistory.append(transaction)
        }
        
        return success
    }
    
    func withdraw(accountId: UUID, amount: Double) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            return false
        }
        
        // Try to withdraw
        let success = accounts[index].withdraw(amount: amount)
        
        // Add to transaction history
        if success {
            let transaction = BankTransaction(
                type: .withdrawal,
                amount: amount,
                description: "Withdrawal from \(accounts[index].accountType.rawValue)",
                date: Date(),
                year: Calendar.current.component(.year, from: Date())
            )
            transactionHistory.append(transaction)
        }
        
        return success
    }
    
    func transfer(fromAccountId: UUID, toAccountId: UUID, amount: Double) -> Bool {
        guard let fromIndex = accounts.firstIndex(where: { $0.id == fromAccountId }),
              let toIndex = accounts.firstIndex(where: { $0.id == toAccountId }) else {
            return false
        }
        
        // Check if withdrawal is possible
        if accounts[fromIndex].withdraw(amount: amount) {
            // Deposit to receiving account
            let success = accounts[toIndex].deposit(amount: amount)
            if success {
                // Add transaction record
                let transaction = BankTransaction(
                    type: .transfer,
                    amount: amount,
                    description: "Transfer from \(accounts[fromIndex].accountType.rawValue) to \(accounts[toIndex].accountType.rawValue)",
                    date: Date(),
                    year: Calendar.current.component(.year, from: Date())
                )
                transactionHistory.append(transaction)
                return true
            } else {
                // Rollback if deposit failed
                let _ = accounts[fromIndex].deposit(amount: amount)
            }
        }
        return false
    }
    
    func makeLoanPayment(loanId: UUID, amount: Double) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.id == loanId }) else {
            return false
        }
        
        // Make payment
        let success = accounts[index].makePayment(amount: amount)
        
        // Add transaction record
        if success {
            let transaction = BankTransaction(
                type: .payment,
                amount: amount,
                description: "Payment to \(accounts[index].accountType.rawValue)",
                date: Date(),
                year: Calendar.current.component(.year, from: Date())
            )
            transactionHistory.append(transaction)
            
            // Update credit score for on-time payments
            adjustCreditScore(change: 3)
        }
        
        return success
    }
    
    // Credit and Financial Status
    func adjustCreditScore(change: Int) {
        creditScore = max(300, min(850, creditScore + change))
    }
    
    func creditScoreCategory() -> String {
        switch creditScore {
        case 300...579: return "Poor"
        case 580...669: return "Fair"
        case 670...739: return "Good"
        case 740...799: return "Very Good"
        case 800...850: return "Excellent"
        default: return "Unknown"
        }
    }
    
    func calculateNetWorth() -> Double {
        var netWorth = characterMoney
        
        // Add account balances
        for account in accounts where account.isActive {
            netWorth += account.balance
        }
        
        // Add property values
        for property in propertyInvestments {
            netWorth += property.currentValue
            
            // Subtract mortgage balance if present
            if let mortgageId = property.mortgageAccountId,
               let mortgage = getAccount(id: mortgageId) {
                netWorth += mortgage.balance // Will subtract since mortgage balance is negative
            }
        }
        
        // Add collateral assets
        for asset in collateralAssets {
            // Only add if not already counted as part of property
            if asset.loanId == nil {
                netWorth += asset.value
            }
        }
        
        return netWorth
    }
    
    func getTotalDebt() -> Double {
        var totalDebt = 0.0
        
        // Add negative balances from accounts
        for account in accounts where account.isActive && account.balance < 0 {
            totalDebt += abs(account.balance)
        }
        
        return totalDebt
    }
    
    func getTotalSavings() -> Double {
        var totalSavings = 0.0
        
        // Add positive balances from savings-type accounts
        for account in accounts where account.isActive && account.balance > 0 &&
            (account.accountType == .savings || account.accountType == .checking || 
             account.accountType == .cd || account.accountType == .retirementAccount) {
            totalSavings += account.balance
        }
        
        return totalSavings
    }
    
    func requestCreditReport() -> [String: Any] {
        // Calculate debt-to-income ratio
        let totalDebt = getTotalDebt()
        let debtToIncomeRatio = totalDebt / 50000.0 // Assuming $50k annual income
        
        // Generate report
        return [
            "creditScore": creditScore,
            "category": creditScoreCategory(),
            "accounts": accounts.count,
            "activeAccounts": getActiveAccounts().count,
            "totalDebt": totalDebt,
            "debtToIncomeRatio": debtToIncomeRatio,
            "creditUtilization": calculateCreditUtilization()
        ]
    }
    
    // Calculate credit utilization (credit used / total available credit)
    func calculateCreditUtilization() -> Double {
        var totalCreditLimit: Double = 0
        var totalCreditUsed: Double = 0
        
        for account in accounts where account.isActive && account.accountType == .creditCard {
            // Credit limit is stored as part of the account object
            let creditLimit = account.creditLimit > 0 ? account.creditLimit : 1000 // Default if not set
            totalCreditLimit += creditLimit
            
            // Credit used is the negative balance (credit cards have negative balances when used)
            if account.balance < 0 {
                totalCreditUsed += abs(account.balance)
            }
        }
        
        // Avoid division by zero
        if totalCreditLimit <= 0 {
            return 0.0
        }
        
        // Return as percentage (0-1)
        return totalCreditUsed / totalCreditLimit
    }
    
    // Collateral Management
    func addCollateralAsset(type: CollateralType, description: String, value: Double, purchaseYear: Int) -> LoanCollateral {
        let collateral = LoanCollateral(
            type: type,
            description: description,
            value: value,
            purchaseYear: purchaseYear
        )
        collateralAssets.append(collateral)
        return collateral
    }
    
    func getAvailableCollateral() -> [LoanCollateral] {
        return collateralAssets.filter { $0.loanId == nil }
    }
    
    func getCollateral(forLoanId loanId: UUID) -> LoanCollateral? {
        return collateralAssets.first { $0.loanId == loanId }
    }
    
    // MARK: - Employment Status Management
    
    // Public accessor for employment status
    var employmentStatus: EmploymentStatus {
        return _employmentStatus
    }
    
    // Method to update employment status - for use by extensions
    func updateEmploymentStatus(_ status: EmploymentStatus) {
        _employmentStatus = status
        objectWillChange.send()
    }
    
    // MARK: - Additional Methods
    
    // Process yearly updates
    func processYearlyUpdate(currentYear: Int) -> [LifeEvent] {
        var events: [LifeEvent] = []
        
        // Process accounts
        for i in 0..<accounts.count where accounts[i].isActive {
            // Apply interest
            let interest = accounts[i].applyYearlyInterest()
            
            if abs(interest) > 1.0 {
                // Create interest event if significant
                let eventTitle = accounts[i].balance > 0 ? "Interest Earned" : "Interest Charged"
                let eventDescription = accounts[i].balance > 0 
                    ? "You earned interest on your \(accounts[i].accountType.rawValue)."
                    : "Interest was charged on your \(accounts[i].accountType.rawValue)."
                
                let interestEvent = LifeEvent(
                    title: eventTitle,
                    description: eventDescription,
                    type: .financial,
                    year: currentYear,
                    outcome: "Amount: $\(Int(abs(interest))).",
                    effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(interest))]
                )
                events.append(interestEvent)
            }
            
            // Apply monthly fees (12 months)
            let yearlyFees = accounts[i].applyMonthlyFee() * 12
            if yearlyFees > 0 {
                let feeEvent = LifeEvent(
                    title: "Account Fees",
                    description: "You paid fees on your \(accounts[i].accountType.rawValue).",
                    type: .financial,
                    year: currentYear,
                    outcome: "Total fees: $\(Int(yearlyFees)).",
                    effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(yearlyFees))]
                )
                events.append(feeEvent)
            }
        }
        
        // Update properties
        for i in 0..<propertyInvestments.count {
            let valueChange = propertyInvestments[i].updateValue(currentYear: currentYear, marketCondition: marketCondition)
            
            if abs(valueChange) > 1000 {
                // Create property value change event if significant
                let changeDirection = valueChange > 0 ? "increased" : "decreased"
                let propertyEvent = LifeEvent(
                    title: "Property Value Change",
                    description: "Your property \(changeDirection) in value.",
                    type: .financial,
                    year: currentYear,
                    outcome: "Change: $\(Int(valueChange)).",
                    effects: []
                )
                events.append(propertyEvent)
            }
            
            // Process rental income if applicable
            if propertyInvestments[i].isRental {
                let rentalIncome = propertyInvestments[i].calculateAnnualRentalIncome()
                characterMoney += rentalIncome
                
                let rentalEvent = LifeEvent(
                    title: "Rental Income",
                    description: "You collected rent from your property.",
                    type: .financial,
                    year: currentYear,
                    outcome: "Total income: $\(Int(rentalIncome)).",
                    effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(rentalIncome))]
                )
                events.append(rentalEvent)
            }
        }
        
        return events
    }
    
    // Generate random banking events
    func generateRandomBankingEvents(currentYear: Int) -> [LifeEvent] {
        var events: [LifeEvent] = []
        
        // Random chance for banking events
        let eventChance = Double.random(in: 0...1)
        
        if eventChance < 0.3 { // 30% chance for a banking event
            // Choose a random event type
            let eventType = Int.random(in: 0...3)
            
            switch eventType {
            case 0: // Bank fee
                if accounts.first(where: { $0.isActive && 
                    ($0.accountType == .checking || $0.accountType == .savings) }) != nil {
                    
                    let feeAmount = Double.random(in: 10...50)
                    let feeTypes = ["Overdraft", "Service", "ATM", "Foreign Transaction"]
                    let feeType = feeTypes.randomElement() ?? "Service"
                    
                    let feeEvent = LifeEvent(
                        title: "Bank Fee",
                        description: "Your bank charged you a $\(Int(feeAmount)) \(feeType) fee.",
                        type: .financial,
                        year: currentYear,
                        outcome: "Your account was debited.",
                        effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(feeAmount))]
                    )
                    events.append(feeEvent)
                }
                
            case 1: // Bank promotion
                let promotionAmount = Double.random(in: 50...200)
                
                let promotionEvent = LifeEvent(
                    title: "Bank Promotion",
                    description: "Your bank is offering a $\(Int(promotionAmount)) bonus for opening a new account.",
                    type: .financial,
                    year: currentYear,
                    choices: [
                        EventChoice(
                            text: "Open a new checking account",
                            outcome: "You opened a new checking account and received the bonus.",
                            effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(promotionAmount))]
                        ),
                        EventChoice(
                            text: "Open a new savings account",
                            outcome: "You opened a new savings account and received the bonus.",
                            effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(promotionAmount))]
                        ),
                        EventChoice(
                            text: "Ignore the offer",
                            outcome: "You decided not to open a new account.",
                            effects: []
                        )
                    ]
                )
                events.append(promotionEvent)
                
            case 2: // Interest rate change
                let isIncrease = Bool.random()
                let changeAmount = Double.random(in: 0.005...0.02) // 0.5% to 2%
                
                let changeType = isIncrease ? "increased" : "decreased"
                let changeEffect = isIncrease ? "This is good for savings but bad for loans." : 
                                              "This is bad for savings but good for loans."
                
                let rateEvent = LifeEvent(
                    title: "Interest Rate Change",
                    description: "The Federal Reserve has \(changeType) interest rates by \(String(format: "%.1f", changeAmount * 100))%. \(changeEffect)",
                    type: .financial,
                    year: currentYear,
                    outcome: "Your account interest rates have been adjusted.",
                    effects: []
                )
                events.append(rateEvent)
                
            case 3: // Credit score change
                let isImproved = Bool.random()
                let changeAmount = Int.random(in: 5...25)
                
                let changeDirection = isImproved ? "improved" : "decreased"
                let changeEffect = isImproved ? 
                    "This will help you get better loan rates in the future." :
                    "This might make future loans more expensive."
                
                // Adjust credit score
                adjustCreditScore(change: isImproved ? changeAmount : -changeAmount)
                
                let creditEvent = LifeEvent(
                    title: "Credit Score Change",
                    description: "Your credit score has \(changeDirection) by \(changeAmount) points.",
                    type: .financial,
                    year: currentYear,
                    outcome: "\(changeEffect) Your new credit score is \(creditScore) (\(creditScoreCategory())).",
                    effects: []
                )
                events.append(creditEvent)
                
            default:
                break
            }
        }
        
        return events
    }
    
    // Get current market condition
    func getCurrentMarketCondition() -> Banking_MarketCondition {
        // Convert from MarketCondition to Banking_MarketCondition
        switch marketCondition {
        case .depression: return .depression
        case .recession: return .recession
        case .recovery: return .recovery
        case .normal: return .normal
        case .expansion: return .expansion
        case .boom: return .boom
        }
    }
    
    // Create a mortgage
    func createMortgage(propertyValue: Double, downPayment: Double, term: Int, currentYear: Int) -> (success: Bool, mortgage: BankAccount?) {
        // Minimum down payment is 5% of property value
        let minimumDownPayment = propertyValue * 0.05
        if downPayment < minimumDownPayment {
            return (false, nil)
        }
        
        // Check if character has enough money
        if characterMoney < downPayment {
            return (false, nil)
        }
        
        // Loan amount is property value minus down payment
        let loanAmount = propertyValue - downPayment
        
        // Create the mortgage account
        let mortgage = openAccount(
            type: .mortgage,
            initialDeposit: loanAmount,
            currentYear: currentYear,
            term: term
        )
        
        if let mortgage = mortgage {
            // Deduct down payment
            characterMoney -= downPayment
            return (true, mortgage)
        }
        
        return (false, nil)
    }
}