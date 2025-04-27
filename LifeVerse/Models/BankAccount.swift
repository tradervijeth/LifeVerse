//
//  BankAccount.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

struct BankAccount: Codable, Identifiable {
    var id = UUID()
    var accountType: BankAccountType
    var balance: Double
    var interestRate: Double
    var creationYear: Int
    var transactions: [BankTransaction] = []
    var monthlyFee: Double = 0
    var minimumBalance: Double = 0
    var creditLimit: Double = 0 // Only used for credit accounts
    var term: Int = 0 // Only used for CDs and loans (in years)
    var isActive: Bool = true
    
    // Initialize a new bank account
    init(accountType: BankAccountType, initialDeposit: Double, interestRate: Double, creationYear: Int) {
        self.accountType = accountType
        self.balance = initialDeposit
        self.interestRate = interestRate
        self.creationYear = creationYear
        
        // Set default values based on account type
        switch accountType {
        case .checking:
            self.monthlyFee = 5.0
            self.minimumBalance = 100.0
        case .savings:
            self.minimumBalance = 50.0
        case .creditCard:
            self.balance = 0
            self.creditLimit = 1000.0
        case .loan:
            self.balance = -initialDeposit // Negative balance represents debt
            self.term = 5 // Default 5-year term
        case .cd:
            self.term = 1 // Default 1-year term
            self.minimumBalance = initialDeposit // Can't withdraw before term
        case .investment:
            // Investment accounts have variable returns instead of fixed interest
            self.interestRate = 0.0
        case .mortgage:
            self.balance = -initialDeposit // Negative balance represents debt
            self.term = 30 // Default 30-year term
        case .autoLoan:
            self.balance = -initialDeposit // Negative balance represents debt
            self.term = 5 // Default 5-year term
        case .studentLoan:
            self.balance = -initialDeposit // Negative balance represents debt
            self.term = 10 // Default 10-year term
        case .businessAccount:
            self.monthlyFee = 15.0
            self.minimumBalance = 500.0
        case .retirementAccount:
            // No special initialization needed
            break
        }
        
        // Record initial transaction
        if initialDeposit > 0 && accountType != .creditCard && accountType != .loan {
            addTransaction(type: .deposit, amount: initialDeposit, description: "Initial deposit")
        } else if accountType == .loan {
            addTransaction(type: .loan, amount: initialDeposit, description: "Loan disbursement")
        }
    }
    
    // Add a transaction to this account
    mutating func addTransaction(type: BankTransactionType, amount: Double, description: String) {
        let transaction = BankTransaction(
            type: type,
            amount: amount,
            description: description,
            date: Date(),
            year: creationYear
        )
        transactions.append(transaction)
    }
    
    // Apply yearly interest to the account
    mutating func applyYearlyInterest() -> Double {
        // Don't apply interest to credit cards with zero balance or inactive accounts
        if (accountType == .creditCard && balance == 0) || !isActive {
            return 0
        }
        
        let interestAmount: Double
        
        switch accountType {
        case .checking, .savings, .cd, .businessAccount, .retirementAccount:
            // Positive interest on deposits
            interestAmount = balance * interestRate
            balance += interestAmount
        case .creditCard, .loan, .mortgage, .autoLoan, .studentLoan:
            // Interest charged on debt (negative balance)
            interestAmount = abs(balance) * interestRate
            balance -= interestAmount // Increases debt
        case .investment:
            // Investments have variable returns
            let marketPerformance = Double.random(in: -0.15...0.25) // -15% to +25%
            interestAmount = balance * marketPerformance
            balance += interestAmount
        }
        
        // Record the interest transaction
        let transactionType: BankTransactionType = (interestAmount >= 0) ? .interest : .fee
        let description = (interestAmount >= 0) ? "Interest earned" : "Interest charged"
        addTransaction(type: transactionType, amount: abs(interestAmount), description: description)
        
        return interestAmount
    }
    
    // Apply monthly fees
    mutating func applyMonthlyFee() -> Double {
        // Only apply if there's a fee and the account is active
        if monthlyFee > 0 && isActive {
            // Check if minimum balance requirement is met
            if balance < minimumBalance {
                balance -= monthlyFee
                addTransaction(type: .fee, amount: monthlyFee, description: "Monthly maintenance fee")
                return monthlyFee
            }
        }
        return 0
    }
    
    // Make a payment (for loans and credit cards)
    mutating func makePayment(amount: Double) -> Bool {
        if accountType == .loan || accountType == .creditCard {
            if amount > 0 {
                balance += amount // Reduces debt
                addTransaction(type: .payment, amount: amount, description: "Payment")
                
                // Check if loan is paid off
                if accountType == .loan && balance >= 0 {
                    isActive = false
                    balance = 0 // Reset to exactly zero
                }
                return true
            }
        }
        return false
    }
    
    // Make a withdrawal
    mutating func withdraw(amount: Double) -> Bool {
        // Can't withdraw from inactive accounts or CDs before term
        if !isActive || (accountType == .cd && term > 0) {
            return false
        }
        
        switch accountType {
        case .checking, .savings, .investment:
            if amount > 0 && balance >= amount {
                balance -= amount
                addTransaction(type: .withdrawal, amount: amount, description: "Withdrawal")
                return true
            }
        case .creditCard:
            // Credit card withdrawals are cash advances
            if amount > 0 && (abs(balance) + amount) <= creditLimit {
                balance -= amount // Increases debt
                addTransaction(type: .withdrawal, amount: amount, description: "Cash advance")
                return true
            }
        default:
            return false
        }
        return false
    }
    
    // Make a deposit
    mutating func deposit(amount: Double) -> Bool {
        if amount > 0 && isActive {
            if accountType != .loan {
                balance += amount
                addTransaction(type: .deposit, amount: amount, description: "Deposit")
                return true
            } else {
                // For loans, deposits are payments
                return makePayment(amount: amount)
            }
        }
        return false
    }
    
    // Check if account is mature (for CDs)
    func isMature(currentYear: Int) -> Bool {
        return accountType == .cd && (currentYear - creationYear) >= term
    }
    
    // Get available balance (considers credit limit for credit cards)
    func availableBalance() -> Double {
        switch accountType {
        case .creditCard:
            return creditLimit - abs(min(0, balance))
        case .checking, .savings, .cd, .investment, .mortgage, .autoLoan, 
             .studentLoan, .loan, .businessAccount, .retirementAccount:
            return max(0, balance)
        }
    }
}