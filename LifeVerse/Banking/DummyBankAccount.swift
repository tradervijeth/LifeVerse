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
    var transactions: [Banking_Transaction] = []
    var creationYear: Int

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
        let transaction = Banking_Transaction(
            date: Date(),
            type: type,
            amount: amount,
            description: description,
            year: Calendar.current.component(.year, from: Date())
        )

        // Update balance based on transaction type
        switch type {
        case .deposit, .refund, .directDeposit, .interest, .cashback, .investmentReturn, .sale:
            self.balance += amount
        case .withdrawal, .payment, .fee, .purchase, .atmTransaction, .tax:
            self.balance -= amount
        case .transfer, .loan, .investment, .specialEvent:
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
        let transaction = Banking_Transaction(
            date: Date(),
            type: .interest,
            amount: interestAmount,
            description: "Interest payment",
            year: year
        )

        // Add the transaction and update balance
        transactions.append(transaction)
        balance += interestAmount

        return interestAmount
    }
}
