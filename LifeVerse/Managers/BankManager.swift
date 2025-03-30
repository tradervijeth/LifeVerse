//
//  BankManager.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

class BankManager: ObservableObject, Codable {
    @Published var accounts: [BankAccount] = []
    @Published var creditScore: Int = 650 // Starting credit score (300-850 range)
    @Published var collateralAssets: [LoanCollateral] = []
    @Published var propertyInvestments: [PropertyInvestment] = [] // Property investments collection
    @Published var marketCondition: MarketCondition = .expansion // Current economic condition
    @Published var transactionHistory: [BankTransaction] = [] // Global transaction history
    @Published var overdraftProtection: Bool = false // Whether overdraft protection is enabled
    @Published var creditReportRequests: Int = 0 // Number of credit report requests (affects score)
    
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case accounts, creditScore, collateralAssets, propertyInvestments, marketCondition, transactionHistory, overdraftProtection, creditReportRequests
    }
    
    // Required for Codable when using @Published
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accounts = try container.decode([BankAccount].self, forKey: .accounts)
        creditScore = try container.decode(Int.self, forKey: .creditScore)
        
        // Decode new properties with backward compatibility
        collateralAssets = try container.decodeIfPresent([LoanCollateral].self, forKey: .collateralAssets) ?? []
        propertyInvestments = try container.decodeIfPresent([PropertyInvestment].self, forKey: .propertyInvestments) ?? []
        marketCondition = try container.decodeIfPresent(MarketCondition.self, forKey: .marketCondition) ?? .expansion
        transactionHistory = try container.decodeIfPresent([BankTransaction].self, forKey: .transactionHistory) ?? []
        overdraftProtection = try container.decodeIfPresent(Bool.self, forKey: .overdraftProtection) ?? false
        creditReportRequests = try container.decodeIfPresent(Int.self, forKey: .creditReportRequests) ?? 0
    }
    
    // Encode for Codable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts, forKey: .accounts)
        try container.encode(creditScore, forKey: .creditScore)
        try container.encode(collateralAssets, forKey: .collateralAssets)
        try container.encode(propertyInvestments, forKey: .propertyInvestments)
        try container.encode(marketCondition, forKey: .marketCondition)
        try container.encode(transactionHistory, forKey: .transactionHistory)
        try container.encode(overdraftProtection, forKey: .overdraftProtection)
        try container.encode(creditReportRequests, forKey: .creditReportRequests)
    }
    
    // Default initializer
    init() {}
    
    // MARK: - Account Management
    
    // Open a new bank account
    func openAccount(type: BankAccountType, initialDeposit: Double, currentYear: Int, term: Int? = nil, collateralId: UUID? = nil) -> BankAccount? {
        // Check if initial deposit meets minimum requirement
        if initialDeposit < type.minimumInitialDeposit() {
            return nil
        }
        
        // For loans, check credit score and handle collateral
        if type == .loan || type == .mortgage || type == .autoLoan || type == .studentLoan {
            // Check if can qualify for loan amount
            if !canQualifyForLoan(amount: initialDeposit, loanType: type) {
                return nil
            }
            
            // For secured loans, verify collateral
            if (type == .mortgage || type == .autoLoan) && collateralId == nil {
                return nil // Secured loans require collateral
            }
            
            // If collateral provided, verify it's valid and not already used
            if let collateralId = collateralId {
                guard let collateralIndex = collateralAssets.firstIndex(where: { $0.id == collateralId }),
                      collateralAssets[collateralIndex].loanId == nil else {
                    return nil
                }
                
                // Check if loan amount is within allowed LTV ratio
                let collateral = collateralAssets[collateralIndex]
                let maxLoanAmount = collateral.currentValue(currentYear: currentYear) * 
                                    collateral.type.maxLoanToValueRatio()
                
                if initialDeposit > maxLoanAmount {
                    return nil // Loan exceeds maximum allowed for this collateral
                }
            }
        }
        
        // Adjust interest rate based on market conditions and credit score
        var interestRate = type.defaultInterestRate()
        interestRate += marketCondition.interestRateEffect() // Apply market effect
        
        // Apply credit score effect for loans and credit cards
        if type == .loan || type == .mortgage || type == .autoLoan || 
           type == .studentLoan || type == .creditCard {
            interestRate += creditScoreCategoryObject().interestRateModifier()
        }
        
        // Ensure interest rate doesn't go negative or too low
        interestRate = max(0.001, interestRate)
        
        // For credit cards, determine limit based on credit score
        var creditLimit = 0.0
        if type == .creditCard {
            creditLimit = calculateCreditLimit()
        }
        
        // Set appropriate term for term-based accounts
        var accountTerm = term ?? type.defaultTerm()
        
        // Create the account
        var account = BankAccount(
            accountType: type,
            initialDeposit: initialDeposit,
            interestRate: interestRate,
            creationYear: currentYear
        )
        
        // Set additional properties based on account type
        account.term = accountTerm
        
        if type == .creditCard {
            account.creditLimit = creditLimit
        }
        
        // For business accounts, add higher fees but better benefits
        if type == .businessAccount {
            account.monthlyFee = 15.0
            account.minimumBalance = 500.0
        }
        
        // For retirement accounts, add withdrawal restrictions
        if type == .retirementAccount {
            // Can't withdraw until 65 years old (handled in withdraw method)
        }
        
        // Add the account
        accounts.append(account)
        
        // If this is a secured loan, link the collateral
        if let collateralId = collateralId {
            if let index = collateralAssets.firstIndex(where: { $0.id == collateralId }) {
                collateralAssets[index].loanId = account.id
            }
        }
        
        // Small credit score boost for opening new accounts (except loans)
        if type != .loan && type != .mortgage && type != .autoLoan && type != .studentLoan {
            adjustCreditScore(change: 2)
        }
        
        // Add to global transaction history
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
    
    // Close an account
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
    
    // Get all active accounts
    func getActiveAccounts() -> [BankAccount] {
        return accounts.filter { $0.isActive }
    }
    
    // Get accounts by type
    func getAccounts(ofType type: BankAccountType) -> [BankAccount] {
        return accounts.filter { $0.accountType == type && $0.isActive }
    }
    
    // Get account by ID
    func getAccount(id: UUID) -> BankAccount? {
        return accounts.first { $0.id == id }
    }
    
    // MARK: - Transaction Processing
    
    // Deposit money into an account
    func deposit(accountId: UUID, amount: Double) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            return false
        }
        
        let success = accounts[index].deposit(amount: amount)
        
        // Update credit score for loan payments
        if success && accounts[index].accountType == .loan {
            adjustCreditScore(change: 2) // Small positive impact
        }
        
        return success
    }
    
    // Withdraw money from an account
    func withdraw(accountId: UUID, amount: Double) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else {
            return false
        }
        
        return accounts[index].withdraw(amount: amount)
    }
    
    // Transfer between accounts
    func transfer(fromAccountId: UUID, toAccountId: UUID, amount: Double) -> Bool {
        guard let fromIndex = accounts.firstIndex(where: { $0.id == fromAccountId }),
              let toIndex = accounts.firstIndex(where: { $0.id == toAccountId }) else {
            return false
        }
        
        // Check if withdrawal is possible
        if accounts[fromIndex].withdraw(amount: amount) {
            // Add transfer transaction
            accounts[fromIndex].addTransaction(
                type: .transfer,
                amount: amount,
                description: "Transfer to \(accounts[toIndex].accountType.rawValue)"
            )
            
            // Deposit to receiving account
            let success = accounts[toIndex].deposit(amount: amount)
            if success {
                accounts[toIndex].addTransaction(
                    type: .transfer,
                    amount: amount,
                    description: "Transfer from \(accounts[fromIndex].accountType.rawValue)"
                )
            } else {
                // Rollback if deposit failed
                accounts[fromIndex].deposit(amount: amount)
                return false
            }
            return true
        }
        return false
    }
    
    // Make a loan payment
    func makeLoanPayment(loanId: UUID, amount: Double) -> Bool {
        guard let index = accounts.firstIndex(where: { $0.id == loanId && $0.accountType == .loan }) else {
            return false
        }
        
        let success = accounts[index].makePayment(amount: amount)
        
        // Update credit score for on-time payments
        if success {
            adjustCreditScore(change: 3) // Positive impact
        }
        
        return success
    }
    
    // MARK: - Yearly Processing
    
    // Process all accounts for yearly update
    func processYearlyUpdate(currentYear: Int) -> [LifeEvent] {
        var events: [LifeEvent] = []
        var totalInterest: Double = 0
        var totalFees: Double = 0
        
        // Update market conditions
        updateMarketConditions()
        
        // Process each account
        for i in 0..<accounts.count {
            // Skip inactive accounts
            if !accounts[i].isActive { continue }
            
            // Apply monthly fees (12 months)
            let yearlyFees = (0..<12).reduce(0.0) { total, _ in
                total + accounts[i].applyMonthlyFee()
            }
            totalFees += yearlyFees
            
            // Apply yearly interest (adjusted for market conditions)
            var marketAdjustedInterestRate = accounts[i].interestRate
            if accounts[i].accountType != .investment { // Investments handled separately
                marketAdjustedInterestRate += marketCondition.interestRateEffect()
                accounts[i].interestRate = max(0.001, marketAdjustedInterestRate) // Ensure positive rate
            }
            
            let interest = accounts[i].applyYearlyInterest()
            totalInterest += interest
            
            // Check for mature CDs
            if accounts[i].accountType == .cd && accounts[i].isMature(currentYear: currentYear) {
                // Create maturity event
                let cdEvent = LifeEvent(
                    title: "CD Matured",
                    description: "Your Certificate of Deposit has matured with a balance of $\(Int(accounts[i].balance)).",
                    type: .financial,
                    year: currentYear,
                    choices: [
                        EventChoice(
                            text: "Withdraw funds",
                            outcome: "You withdrew $\(Int(accounts[i].balance)) from your matured CD.",
                            effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(accounts[i].balance))]
                        ),
                        EventChoice(
                            text: "Renew CD",
                            outcome: "You renewed your CD for another term.",
                            effects: []
                        )
                    ]
                )
                events.append(cdEvent)
            }
            
            // Check for loans that are due to be paid off
            if (accounts[i].accountType == .loan || accounts[i].accountType == .mortgage || 
                accounts[i].accountType == .autoLoan || accounts[i].accountType == .studentLoan) && 
               accounts[i].term > 0 && (currentYear - accounts[i].creationYear) >= accounts[i].term {
                
                // If loan is not paid off by the end of term
                if accounts[i].balance < 0 {
                    // Create loan due event
                    let loanDueEvent = LifeEvent(
                        title: "Loan Term Ended",
                        description: "Your \(accounts[i].accountType.rawValue) term has ended, but you still owe $\(Int(abs(accounts[i].balance))).",
                        type: .financial,
                        year: currentYear,
                        choices: [
                            EventChoice(
                                text: "Pay off the remaining balance",
                                outcome: "You paid off the remaining balance of your loan.",
                                effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(abs(accounts[i].balance)))]
                            ),
                            EventChoice(
                                text: "Refinance the loan",
                                outcome: "You refinanced your loan for another term.",
                                effects: [EventChoice.CharacterEffect(attribute: "
    
    // MARK: - Collateral and Secured Loans Management
    
    // Add a new collateral asset
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
    
    // Get all available collateral (not tied to a loan)
    func getAvailableCollateral() -> [LoanCollateral] {
        return collateralAssets.filter { $0.loanId == nil }
    }
    
    // Get collateral for a specific loan
    func getCollateral(forLoanId loanId: UUID) -> LoanCollateral? {
        return collateralAssets.first { $0.loanId == loanId }
    }
    
    // Release collateral when loan is paid off
    func releaseCollateral(loanId: UUID) -> Bool {
        guard let index = collateralAssets.firstIndex(where: { $0.loanId == loanId }) else {
            return false
        }
        
        collateralAssets[index].loanId = nil
        return true
    }
    
    // Create a mortgage loan with real estate collateral
    func createMortgage(propertyValue: Double, downPayment: Double, term: Int, currentYear: Int) -> (account: BankAccount?, collateral: LoanCollateral?) {
        // Minimum down payment is 5% of property value
        let minimumDownPayment = propertyValue * 0.05
        if downPayment < minimumDownPayment {
            return (nil, nil)
        }
        
        // Create the collateral asset
        let collateral = addCollateralAsset(
            type: .realEstate,
            description: "Residential Property",
            value: propertyValue,
            purchaseYear: currentYear
        )
        
        // Loan amount is property value minus down payment
        let loanAmount = propertyValue - downPayment
        
        // Create the mortgage account
        let account = openAccount(
            type: .mortgage,
            initialDeposit: loanAmount,
            currentYear: currentYear,
            term: term,
            collateralId: collateral.id
        )
        
        return (account, account != nil ? collateral : nil)
    }
    
    // Create an auto loan with vehicle collateral
    func createAutoLoan(vehicleValue: Double, downPayment: Double, term: Int, currentYear: Int) -> (account: BankAccount?, collateral: LoanCollateral?) {
        // Minimum down payment is 10% of vehicle value
        let minimumDownPayment = vehicleValue * 0.1
        if downPayment < minimumDownPayment {
            return (nil, nil)
        }
        
        // Create the collateral asset
        let collateral = addCollateralAsset(
            type: .vehicle,
            description: "Vehicle",
            value: vehicleValue,
            purchaseYear: currentYear
        )
        
        // Loan amount is vehicle value minus down payment
        let loanAmount = vehicleValue - downPayment
        
        // Create the auto loan account
        let account = openAccount(
            type: .autoLoan,
            initialDeposit: loanAmount,
            currentYear: currentYear,
            term: term,
            collateralId: collateral.id
        )
        
        return (account, account != nil ? collateral : nil)
    }
    
    // MARK: - Credit Score Management
    
    // Adjust credit score
    func adjustCreditScore(change: Int) {
        creditScore = max(300, min(850, creditScore + change))
    }
    
    // Calculate credit score category
    func creditScoreCategory() -> String {
        return creditScoreCategoryObject().rawValue
    }
    
    // Get credit score category as enum
    func creditScoreCategoryObject() -> CreditScoreCategory {
        switch creditScore {
        case 300...579: return .poor
        case 580...669: return .fair
        case 670...739: return .good
        case 740...799: return .veryGood
        case 800...850: return .excellent
        default: return .poor
        }
    }
    
    // Request a credit report (affects credit score slightly)
    func requestCreditReport() -> [String: Any] {
        // Too many requests can hurt credit score
        creditReportRequests += 1
        if creditReportRequests > 2 {
            adjustCreditScore(change: -2) // Small negative impact for frequent checks
        }
        
        // Calculate debt-to-income ratio (assuming annual income)
        let totalDebt = getTotalDebt()
        let debtToIncomeRatio = totalDebt / 50000.0 // Assuming $50k annual income
        
        // Calculate credit utilization
        let creditUtilization = calculateCreditUtilization()
        
        // Generate report
        return [
            "creditScore": creditScore,
            "category": creditScoreCategory(),
            "accounts": accounts.count,
            "activeAccounts": getActiveAccounts().count,
            "totalDebt": totalDebt,
            "debtToIncomeRatio": debtToIncomeRatio,
            "creditUtilization": creditUtilization,
            "maxLoanAmount": maximumLoanAmount(),
            "inquiries": creditReportRequests,
            "delinquentAccounts": getDelinquentAccounts().count
        ]
    }
    
    // Check if can qualify for loan
    func canQualifyForLoan(amount: Double, loanType: BankAccountType = .loan) -> Bool {
        // Get base qualification amount
        let baseAmount = maximumLoanAmount()
        
        // Adjust based on loan type
        var adjustedAmount = baseAmount
        switch loanType {
        case .mortgage:
            // Mortgages can be higher but require collateral
            adjustedAmount = baseAmount * 5
        case .autoLoan:
            // Auto loans can be higher but require collateral
            adjustedAmount = baseAmount * 2
        case .studentLoan:
            // Student loans have special qualification criteria
            adjustedAmount = baseAmount * 1.5
        default:
            break
        }
        
        // Check debt-to-income ratio
        let totalDebt = getTotalDebt()
        let debtToIncomeRatio = totalDebt / 50000.0 // Assuming $50k annual income
        
        // If debt ratio is too high, reduce qualification amount
        if debtToIncomeRatio > 0.4 { // 40% debt-to-income ratio
            adjustedAmount *= 0.5 // Reduce by half
        }
        
        // Check credit utilization
        let utilization = calculateCreditUtilization()
        if utilization > 0.7 { // 70% utilization
            adjustedAmount *= 0.7 // Reduce by 30%
        }
        
        return amount <= adjustedAmount
    }
    
    // Calculate maximum loan amount based on credit score and other factors
    func maximumLoanAmount(loanType: BankAccountType = .loan) -> Double {
        // Base amount based on credit score
        let baseAmount: Double
        switch creditScore {
        case 300...579: baseAmount = 1000
        case 580...669: baseAmount = 5000
        case 670...739: baseAmount = 15000
        case 740...799: baseAmount = 50000
        case 800...850: baseAmount = 100000
        default: baseAmount = 0
        }
        
        // Adjust based on loan type
        var adjustedAmount = baseAmount
        switch loanType {
        case .mortgage:
            // Mortgages can be higher but require collateral
            adjustedAmount = baseAmount * 5
        case .autoLoan:
            // Auto loans can be higher but require collateral
            adjustedAmount = baseAmount * 2
        case .studentLoan:
            // Student loans have special qualification criteria
            adjustedAmount = baseAmount * 1.5
        default:
            break
        }
        
        // Adjust based on market conditions
        switch marketCondition {
        case .recession, .depression:
            adjustedAmount *= 0.8 // 20% reduction during economic downturns
        case .boom:
            adjustedAmount *= 1.2 // 20% increase during booms
        default:
            break
        }
        
        // Adjust based on existing debt
        let totalDebt = getTotalDebt()
        let debtToIncomeRatio = totalDebt / 50000.0 // Assuming $50k annual income
        
        if debtToIncomeRatio > 0.4 { // 40% debt-to-income ratio
            adjustedAmount *= 0.7 // Reduce by 30%
        }
        
        return adjustedAmount
    }
    
    // Calculate credit utilization (used credit / available credit)
    func calculateCreditUtilization() -> Double {
        let creditCards = accounts.filter { $0.accountType == .creditCard && $0.isActive }
        
        if creditCards.isEmpty {
            return 0.0
        }
        
        let totalUsed = creditCards.reduce(0.0) { total, account in
            return total + abs(min(0, account.balance))
        }
        
        let totalAvailable = creditCards.reduce(0.0) { total, account in
            return total + account.creditLimit
        }
        
        return totalAvailable > 0 ? totalUsed / totalAvailable : 0
    }
    
    // Get delinquent accounts (accounts with missed payments)
    func getDelinquentAccounts() -> [BankAccount] {
        return accounts.filter { account in
            if !account.isActive { return false }
            
            // Credit cards and loans with negative balance are considered delinquent
            if (account.accountType == .creditCard || account.accountType == .loan || 
                account.accountType == .mortgage || account.accountType == .autoLoan || 
                account.accountType == .studentLoan) && account.balance < 0 {
                
                // Check if there's been a payment in the last year
                let hasRecentPayment = account.transactions.contains { transaction in
                    transaction.type == .payment && 
                    Calendar.current.dateComponents([.year], from: transaction.date, to: Date()).year ?? 1 < 1
                }
                
                return !hasRecentPayment
            }
            
            return false
        }
    }
    
    // Calculate credit limit for credit cards
    private func calculateCreditLimit() -> Double {
        switch creditScore {
        case 300...579: return 500
        case 580...669: return 2000
        case 670...739: return 5000
        case 740...799: return 10000
        case 800...850: return 25000
        default: return 500
        }
    }
    
    // Calculate credit card interest rate based on credit score
    private func calculateCreditCardInterestRate() -> Double {
        switch creditScore {
        case 300...579: return 0.25 // 25%
        case 580...669: return 0.20 // 20%
        case 670...739: return 0.17 // 17%
        case 740...799: return 0.14 // 14%
        case 800...850: return 0.10 // 10%
        default: return 0.25
        }
    }
    
    // MARK: - Banking Events
    
    // Generate random banking events
    func generateRandomBankingEvents(currentYear: Int) -> [LifeEvent] {
        var events: [LifeEvent] = []
        
        // Only generate events if there are active accounts
        if getActiveAccounts().isEmpty {
            return events
        }
        
        // Random chance for banking events
        let eventChance = Double.random(in: 0...1)
        
        if eventChance < 0.3 { // 30% chance for a banking event
            // Possible events
            let possibleEvents = [
                generateBankFeeEvent(currentYear: currentYear),
                generateBankPromotionEvent(currentYear: currentYear),
                generateFraudEvent(currentYear: currentYear),
                generateInterestRateChangeEvent(currentYear: currentYear)
            ]
            
            // Randomly select one event
            if let event = possibleEvents.randomElement(), event != nil {
                events.append(event!)
            }
        }
        
        return events
    }
    
    // Generate a bank fee event
    private func generateBankFeeEvent(currentYear: Int) -> LifeEvent? {
        // Only generate if there are checking or savings accounts
        let eligibleAccounts = accounts.filter { 
            ($0.accountType == .checking || $0.accountType == .savings) && $0.isActive 
        }
        
        guard let account = eligibleAccounts.randomElement() else {
            return nil
        }
        
        let feeAmount = Double.random(in: 10...50)
        let feeTypes = ["Overdraft", "Service", "ATM", "Foreign Transaction", "Wire Transfer"]
        let feeType = feeTypes.randomElement() ?? "Service"
        
        // Apply the fee
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index].balance -= feeAmount
            accounts[index].addTransaction(type: .fee, amount: feeAmount, description: "\(feeType) Fee")
        }
        
        return LifeEvent(
            title: "Bank Fee",
            description: "Your bank charged you a $\(Int(feeAmount)) \(feeType) fee.",
            type: .financial,
            year: currentYear,
            outcome: "Your account was debited.",
            effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(feeAmount))]
        )
    }
    
    // Generate a bank promotion event
    private func generateBankPromotionEvent(currentYear: Int) -> LifeEvent? {
        let promotionAmount = Double.random(in: 50...200)
        
        return LifeEvent(
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
    }
    
    // Generate a fraud event
    private func generateFraudEvent(currentYear: Int) -> LifeEvent? {
        // Only generate if there are credit cards or checking accounts
        let eligibleAccounts = accounts.filter { 
            ($0.accountType == .creditCard || $0.accountType == .checking) && $0.isActive 
        }
        
        guard let account = eligibleAccounts.randomElement() else {
            return nil
        }
        
        let fraudAmount = Double.random(in: 100...1000)
        
        return LifeEvent(
            title: "Suspicious Activity",
            description: "Your bank detected suspicious activity on your \(account.accountType.rawValue). Someone attempted to charge $\(Int(fraudAmount)).",
            type: .financial,
            year: currentYear,
            choices: [
                EventChoice(
                    text: "Report fraud",
                    outcome: "You reported the fraud and your bank blocked the transaction.",
                    effects: [EventChoice.CharacterEffect(attribute: "happiness", change: -5)]
                ),
                EventChoice(
                    text: "Ignore it",
                    outcome: "You ignored the warning and lost money to fraud.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "money", change: -Int(fraudAmount)),
                        EventChoice.CharacterEffect(attribute: "happiness", change: -10)
                    ]
                )
            ]
        )
    }
    
    // Generate an interest rate change event
    private func generateInterestRateChangeEvent(currentYear: Int) -> LifeEvent? {
        // Only generate if there are interest-bearing accounts
        let eligibleAccounts = accounts.filter { $0.isActive }
        
        guard !eligibleAccounts.isEmpty else {
            return nil
        }
        
        let isIncrease = Bool.random()
        let changeAmount = Double.random(in: 0.005...0.02) // 0.5% to 2%
        
        // Apply the change to all accounts
        for i in 0..<accounts.count where accounts[i].isActive {
            if isIncrease {
                accounts[i].interestRate += changeAmount
            } else {
                accounts[i].interestRate = max(0.001, accounts[i].interestRate - changeAmount)
            }
        }
        
        let changeType = isIncrease ? "increased" : "decreased"
        let changeEffect = isIncrease ? "This is good for savings but bad for loans." : "This is bad for savings but good for loans."
        
        return LifeEvent(
            title: "Interest Rate Change",
            description: "The Federal Reserve has \(changeType) interest rates by \(String(format: "%.1f", changeAmount * 100))%. \(changeEffect)",
            type: .financial,
            year: currentYear,
            outcome: "Your account interest rates have been adjusted.",
            effects: []
        )
    }
    
    // MARK: - Utility Methods
    
    // Calculate net worth (all assets minus all debts)
    func calculateNetWorth() -> Double {
        return accounts.reduce(0) { total, account in
            if account.isActive {
                return total + account.balance
            }
            return total
        }
    }
    
    // Get total debt
    func getTotalDebt() -> Double {
        return accounts.reduce(0) { total, account in
            if account.isActive && account.balance < 0 {
                return total + abs(account.balance)
            }
            return total
        }
    }
    
    // Get total savings
    func getTotalSavings() -> Double {
        return accounts.reduce(0) { total, account in
            if account.isActive && account.balance > 0 && 
               (account.accountType == .savings || account.accountType == .checking || account.accountType == .cd) {
                return total + account.balance
            }
            return total
        }
    }
    
    // Get total investments
    func getTotalInvestments() -> Double {
        return accounts.reduce(0) { total, account in
            if account.isActive && account.accountType == .investment {
                return total + account.balance
            }
            return total
        }
    }
}