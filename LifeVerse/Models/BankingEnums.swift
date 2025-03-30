//
//  BankingEnums.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

// Account types available in the banking system
enum BankAccountType: String, Codable, CaseIterable {
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
    
    // Get description of the account type
    func description() -> String {
        switch self {
        case .checking:
            return "A basic account for everyday transactions with easy access to your money."
        case .savings:
            return "An account that earns interest to help you save for future goals."
        case .creditCard:
            return "A revolving credit line for purchases with a grace period before interest accrues."
        case .cd:
            return "A time deposit account with higher interest rates for leaving your money untouched for a set term."
        case .investment:
            return "An account for investing in stocks, bonds, and other securities with potential for higher returns."
        case .mortgage:
            return "A loan specifically for purchasing real estate with the property as collateral."
        case .autoLoan:
            return "A loan for purchasing a vehicle with the vehicle as collateral."
        case .studentLoan:
            return "A loan for educational expenses with special repayment terms."
        case .loan:
            return "A general personal loan for various purposes."
        case .businessAccount:
            return "An account for business transactions with specialized features for companies."
        case .retirementAccount:
            return "A tax-advantaged account for saving toward retirement."
        }
    }
}

// Types of transactions that can occur in bank accounts
enum BankTransactionType: String, Codable {
    case deposit = "Deposit"
    case withdrawal = "Withdrawal"
    case transfer = "Transfer"
    case payment = "Payment"
    case fee = "Fee"
    case interest = "Interest"
    case loan = "Loan"
    case purchase = "Purchase"
    case refund = "Refund"
    case cashback = "Cashback"
    case directDeposit = "Direct Deposit"
    case check = "Check"
    case atmTransaction = "ATM Transaction"
    case wireTransfer = "Wire Transfer"
    case investmentReturn = "Investment Return"
    
    // Get a description of the transaction type
    func description() -> String {
        switch self {
        case .deposit:
            return "Money added to your account"
        case .withdrawal:
            return "Money removed from your account"
        case .transfer:
            return "Money moved between accounts"
        case .payment:
            return "Payment toward a debt or bill"
        case .fee:
            return "Fee charged by the bank"
        case .interest:
            return "Interest earned or charged"
        case .loan:
            return "Loan disbursement"
        case .purchase:
            return "Purchase made with account"
        case .refund:
            return "Refund received"
        case .cashback:
            return "Cashback rewards"
        case .directDeposit:
            return "Automatic deposit (like payroll)"
        case .check:
            return "Check transaction"
        case .atmTransaction:
            return "Transaction at an ATM"
        case .wireTransfer:
            return "Electronic funds transfer"
        case .investmentReturn:
            return "Return on investment"
        }
    }
}

// Market conditions that affect investment returns and interest rates
enum MarketCondition: String, Codable {
    case recession = "Recession"
    case depression = "Depression"
    case recovery = "Recovery"
    case expansion = "Expansion"
    case boom = "Boom"
    
    // Get the effect on interest rates
    func interestRateEffect() -> Double {
        switch self {
        case .recession: return -0.02 // -2%
        case .depression: return -0.03 // -3%
        case .recovery: return 0.01 // +1%
        case .expansion: return 0.02 // +2%
        case .boom: return 0.03 // +3%
        }
    }
    
    // Get the effect on investment returns
    func investmentReturnEffect() -> (min: Double, max: Double) {
        switch self {
        case .recession: return (min: -0.25, max: 0.05) // -25% to +5%
        case .depression: return (min: -0.40, max: 0.0) // -40% to 0%
        case .recovery: return (min: -0.10, max: 0.15) // -10% to +15%
        case .expansion: return (min: -0.05, max: 0.20) // -5% to +20%
        case .boom: return (min: 0.0, max: 0.30) // 0% to +30%
        }
    }
    
    // Get description of market condition
    func description() -> String {
        switch self {
        case .recession:
            return "The economy is contracting with rising unemployment and falling stock prices."
        case .depression:
            return "A severe and prolonged downturn in economic activity."
        case .recovery:
            return "The economy is beginning to grow again after a downturn."
        case .expansion:
            return "The economy is growing steadily with increasing employment and rising stock prices."
        case .boom:
            return "A period of rapid economic growth and prosperity."
        }
    }
}

// Credit score categories
enum CreditScoreCategory: String, Codable {
    case poor = "Poor"
    case fair = "Fair"
    case good = "Good"
    case veryGood = "Very Good"
    case excellent = "Excellent"
    
    // Get the range for this credit score category
    func range() -> ClosedRange<Int> {
        switch self {
        case .poor: return 300...579
        case .fair: return 580...669
        case .good: return 670...739
        case .veryGood: return 740...799
        case .excellent: return 800...850
        }
    }
    
    // Get interest rate modifier based on credit score
    func interestRateModifier() -> Double {
        switch self {
        case .poor: return 0.05 // +5%
        case .fair: return 0.03 // +3%
        case .good: return 0.0 // No change
        case .veryGood: return -0.01 // -1%
        case .excellent: return -0.02 // -2%
        }
    }
    
    // Get description of credit score category
    func description() -> String {
        switch self {
        case .poor:
            return "Difficult to qualify for most loans and credit cards. High interest rates."
        case .fair:
            return "May qualify for loans but with higher interest rates."
        case .good:
            return "Qualify for most loans with competitive interest rates."
        case .veryGood:
            return "Qualify for loans with favorable terms and lower interest rates."
        case .excellent:
            return "Qualify for the best terms and lowest interest rates available."
        }
    }
}