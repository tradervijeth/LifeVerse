//
//  BankManagerProtocol.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Protocol that defines the banking functionality
protocol BankManagerProtocol {
    // Account management
    func getAccounts() -> [BankAccount]
    func getActiveAccounts() -> [BankAccount]
    func getAccount(id: UUID) -> BankAccount?
    func openAccount(type: BankAccountType, initialDeposit: Double, currentYear: Int, term: Int?, collateralId: UUID?) -> BankAccount?
    func closeAccount(accountId: UUID) -> (success: Bool, balance: Double)
    
    // Transaction operations
    func deposit(accountId: UUID, amount: Double) -> Bool
    func withdraw(accountId: UUID, amount: Double) -> Bool
    func transfer(fromAccountId: UUID, toAccountId: UUID, amount: Double) -> Bool
    func makeLoanPayment(loanId: UUID, amount: Double) -> Bool
    
    // Credit and financial status
    func adjustCreditScore(change: Int)
    func creditScoreCategory() -> String
    func calculateNetWorth() -> Double
    func getTotalDebt() -> Double
    func getTotalSavings() -> Double
    func requestCreditReport() -> [String: Any]
    
    // Collateral management
    func addCollateralAsset(type: CollateralType, description: String, value: Double, purchaseYear: Int) -> LoanCollateral
    func getAvailableCollateral() -> [LoanCollateral]
    func getCollateral(forLoanId loanId: UUID) -> LoanCollateral?
    
    // Market and yearly operations
    func processYearlyUpdate(currentYear: Int) -> [LifeEvent]
    func generateRandomBankingEvents(currentYear: Int) -> [LifeEvent]
}
