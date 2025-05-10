//
//  Banking_AccountType.swift
//  LifeVerse
//
//  Created to fix duplicate enums issue
//

import Foundation

// Define the enum directly rather than using a type alias
enum Banking_AccountType: String, Codable, CaseIterable {
    case checking = "Checking"
    case savings = "Savings"
    case creditCard = "Credit Card"
    case loan = "Loan"
    case cd = "Certificate of Deposit"
    case investment = "Investment"
    case mortgage = "Mortgage"
    case autoLoan = "Auto Loan"
    case studentLoan = "Student Loan"
    case businessAccount = "Business Account"
    case retirementAccount = "Retirement Account"
    
    // Get the minimum initial deposit required for this account type
    func minimumInitialDeposit() -> Double {
        switch self {
        case .checking: return 25.0
        case .savings: return 50.0
        case .creditCard: return 0.0
        case .cd: return 500.0
        case .investment: return 1000.0
        case .mortgage: return 0.0 // Down payment handled separately
        case .autoLoan: return 0.0 // Down payment handled separately
        case .studentLoan: return 0.0
        case .loan: return 0.0
        case .businessAccount: return 100.0
        case .retirementAccount: return 250.0
        }
    }
    
    // Get the default interest rate for this account type
    func defaultInterestRate() -> Double {
        switch self {
        case .checking: return 0.0025 // 0.25%
        case .savings: return 0.01 // 1%
        case .creditCard: return 0.18 // 18%
        case .cd: return 0.03 // 3%
        case .investment: return 0.0 // Variable returns
        case .mortgage: return 0.045 // 4.5%
        case .autoLoan: return 0.06 // 6%
        case .studentLoan: return 0.05 // 5%
        case .loan: return 0.08 // 8%
        case .businessAccount: return 0.015 // 1.5%
        case .retirementAccount: return 0.0 // Variable returns
        }
    }
    
    // Get the default term in years (for term-based accounts)
    func defaultTerm() -> Int {
        switch self {
        case .cd: return 1
        case .mortgage: return 30
        case .autoLoan: return 5
        case .studentLoan: return 10
        case .loan: return 5
        default: return 0
        }
    }
}
