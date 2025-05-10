//
//  BankingSystemIntegration.swift
//  LifeVerse
//
//  Created by Claude on 27/04/2025.
//

import Foundation
import Combine

class BankingSystemIntegration: ObservableObject {
    @Published var bankManager: BankManager
    @Published var bankingSystem: BankingSystem
    
    // Notification publisher for banking events
    let notificationPublisher = PassthroughSubject<BankingNotification, Never>()
    
    init(bankManager: BankManager, bankingSystem: BankingSystem) {
        self.bankManager = bankManager
        self.bankingSystem = bankingSystem
    }
    
    // Get all active accounts
    func getActiveAccounts() -> [BankAccount] {
        return bankManager.getActiveAccounts()
    }
    
    // Open a new account
    func openAccount(type: BankAccountType, initialDeposit: Double, currentYear: Int) -> BankAccount? {
        let account = bankManager.openAccount(type: type, initialDeposit: initialDeposit, currentYear: currentYear)
        
        if let account = account {
            // Notify system of new account
            notificationPublisher.send(BankingNotification(
                type: .accountOpened,
                message: "New \(type.rawValue) account opened",
                accountId: account.id
            ))
        }
        
        return account
    }
    
    // Deposit money into an account
    func deposit(accountId: UUID, amount: Double) -> Bool {
        let success = bankManager.deposit(accountId: accountId, amount: amount)
        
        if success {
            notificationPublisher.send(BankingNotification(
                type: .deposit,
                message: "Deposit of $\(Int(amount)) successful",
                accountId: accountId
            ))
        }
        
        return success
    }
    
    // Process yearly banking update
    func processYearlyUpdate(currentYear: Int) -> [LifeEvent] {
        let events = bankManager.processYearlyUpdate(currentYear: currentYear)
        
        // Update market conditions based on year
        updateMarketConditions(currentYear: currentYear)
        
        return events
    }
    
    // Update market conditions based on historical data or simulation
    private func updateMarketConditions(currentYear: Int) {
        // Simple implementation - periodically cycle through market conditions
        // A more sophisticated implementation would use historical data for realism
        
        if currentYear % 10 == 0 {
            // Every decade, a chance for a major recession
            if Double.random(in: 0...1) < 0.3 {
                bankManager.marketCondition = .recession
            }
        } else if currentYear % 5 == 0 {
            // Every 5 years, a chance for a boom
            if Double.random(in: 0...1) < 0.4 {
                bankManager.marketCondition = .boom
            }
        } else {
            // Otherwise, random conditions with weighted probabilities
            bankManager.marketCondition = MarketCondition.random()
        }
        
        // Notify of market condition changes
        notificationPublisher.send(BankingNotification(
            type: .marketUpdate,
            message: "Economic conditions updated to \(bankManager.marketCondition.rawValue)"
        ))
    }
}

// Banking system notification structure
struct BankingNotification {
    enum NotificationType {
        case accountOpened
        case accountClosed
        case deposit
        case withdrawal
        case transfer
        case payment
        case interestApplied
        case marketUpdate
        case error
    }
    
    let type: NotificationType
    let message: String
    let accountId: UUID?
    let timestamp = Date()
    
    init(type: NotificationType, message: String, accountId: UUID? = nil) {
        self.type = type
        self.message = message
        self.accountId = accountId
    }
}
