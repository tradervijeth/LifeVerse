//
//  DummyBankAccount.swift
//  LifeVerse
//
//  Created to implement missing DummyBankAccount type
//

import Foundation

// MARK: - Dummy Bank Account
// This is a simplified version of a bank account used for testing and dummy data
struct DummyBankAccount: Codable, Identifiable {
    var id = UUID()
    var accountType: Banking_AccountType
    var balance: Double
    var interestRate: Double
    var isActive: Bool = true
    var transactions: [BankTransaction] = []
    var creationYear: Int

    // Helper to convert between transaction types
    private func convertToBankTransactionType(_ type: Banking_TransactionType) -> BankTransactionType {
        switch type {
        case .deposit: return .deposit
        case .withdrawal: return .withdrawal
        case .transfer: return .transfer
        case .payment: return .payment
        case .fee: return .fee
        case .interest: return .interest
        case .loan: return .loan
        case .purchase: return .purchase
        case .refund: return .refund
        case .cashback: return .cashback
        case .directDeposit: return .directDeposit
        case .check: return .check
        case .atmTransaction: return .atmTransaction
        case .wireTransfer: return .wireTransfer
        case .investmentReturn: return .investmentReturn
        case .sale, .tax, .investment, .specialEvent:
            // These don't exist in BankTransactionType, default to something sensible
            return .transfer
        }
    }
    
    // Initialization
    init(type: Banking_AccountType, balance: Double, interestRate: Double? = nil, creationYear: Int? = nil) {
        self.id = UUID()
        self.accountType = type
        self.balance = balance
        self.interestRate = interestRate ?? type.defaultInterestRate()
        self.creationYear = creationYear ?? Calendar.current.component(.year, from: Date())
        self.isActive = true
    }

    // Add a transaction
    mutating func addTransaction(type: Banking_TransactionType, amount: Double, description: String) {
        // Convert Banking_TransactionType to BankTransactionType
        let bankType = convertToBankTransactionType(type)
        
        let transaction = BankTransaction(
            type: bankType,
            amount: amount,
            description: description,
            date: Date(),
            year: Calendar.current.component(.year, from: Date())
        )

        // Update balance based on transaction type
        switch type {
        case .deposit, .refund, .directDeposit, .interest, .cashback, .investmentReturn, .sale:
            self.balance += amount
        case .withdrawal, .payment, .fee, .purchase, .atmTransaction, .tax:
            self.balance -= amount
        case .transfer, .loan, .investment, .specialEvent, .wireTransfer, .check:
            // For transfers, investments, and special events, handle separately depending on context
            break
        }

        // Add the transaction to history
        transactions.append(transaction)
    }

    // Apply interest
    mutating func applyInterest(year: Int) -> Double {
        // Only apply interest to certain account types
        guard [Banking_AccountType.savings,
              Banking_AccountType.cd,
              Banking_AccountType.businessAccount].contains(accountType) else {
            return 0.0
        }

        let interestAmount = balance * interestRate

        // Create an interest transaction
        let transaction = BankTransaction(
            type: .interest,
            amount: interestAmount,
            description: "Interest payment",
            date: Date(),
            year: year
        )

        // Add the transaction and update balance
        transactions.append(transaction)
        balance += interestAmount

        return interestAmount
    }
}
