//
//  BankingSystem.swift
//  LifeVerse
//
//  Created by Claude on 27/04/2025.
//

import Foundation

class BankingSystem: ObservableObject, Codable {
    // Central bank reference
    private var centralBank: CentralBank?

    // Banking regulations
    var minimumReserveRatio: Double = 0.1 // 10% minimum reserve
    var depositInsuranceLimit: Double = 250000 // FDIC-type insurance
    var maximumLoanToValueRatio: Double = 0.8 // 80% LTV for mortgages

    // Interest rate model
    var baseInterestRate: Double = 0.03 // 3% base rate

    // Current banking environment variables
    var inflationRate: Double = 0.02 // 2% inflation
    var economicGrowthRate: Double = 0.025 // 2.5% GDP growth

    // Initialize the banking system
    init() {
        self.centralBank = CentralBank(baseRate: baseInterestRate)
    }

    // Get the central bank
    func getCentralBank() -> CentralBank {
        if centralBank == nil {
            centralBank = CentralBank(baseRate: baseInterestRate)
        }
        return centralBank!
    }

    // Set the base interest rate (affects all new accounts and loans)
    func setBaseInterestRate(_ rate: Double) {
        baseInterestRate = max(0.001, min(0.2, rate)) // Limit between 0.1% and 20%
        centralBank?.setBaseRate(baseInterestRate)
    }

    // Calculate loan interest rates based on credit score, loan type, and term
    func calculateLoanInterestRate(creditScore: Int, loanType: BankAccountType, term: Int) -> Double {
        // Start with base rate
        var rate = baseInterestRate

        // Adjust for credit score (lower score = higher rate)
        let creditScoreAdjustment: Double
        switch creditScore {
        case 800...850: creditScoreAdjustment = -0.01 // -1%
        case 740...799: creditScoreAdjustment = -0.005 // -0.5%
        case 670...739: creditScoreAdjustment = 0 // No adjustment
        case 580...669: creditScoreAdjustment = 0.01 // +1%
        case 300...579: creditScoreAdjustment = 0.03 // +3%
        default: creditScoreAdjustment = 0
        }
        rate += creditScoreAdjustment

        // Adjust for loan type
        switch loanType {
        case .mortgage:
            rate += 0.005 // +0.5% for mortgages
        case .autoLoan:
            rate += 0.02 // +2% for auto loans
        case .studentLoan:
            rate -= 0.005 // -0.5% for student loans (subsidized)
        case .loan:
            rate += 0.03 // +3% for personal loans (higher risk)
        case .creditCard:
            rate += 0.12 // +12% for credit cards
        default:
            break // No adjustment for other types
        }

        // Adjust for term length (longer term = higher rate)
        if term > 15 {
            rate += 0.005 // +0.5% for terms over 15 years
        } else if term > 7 {
            rate += 0.002 // +0.2% for terms over 7 years
        }

        // Ensure minimum profitability
        return max(0.01, rate) // Minimum 1% interest rate
    }

    // Encode/decode methods for Codable conformance
    enum CodingKeys: String, CodingKey {
        case minimumReserveRatio, depositInsuranceLimit, maximumLoanToValueRatio
        case baseInterestRate, inflationRate, economicGrowthRate
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        minimumReserveRatio = try container.decode(Double.self, forKey: .minimumReserveRatio)
        depositInsuranceLimit = try container.decode(Double.self, forKey: .depositInsuranceLimit)
        maximumLoanToValueRatio = try container.decode(Double.self, forKey: .maximumLoanToValueRatio)
        baseInterestRate = try container.decode(Double.self, forKey: .baseInterestRate)
        inflationRate = try container.decode(Double.self, forKey: .inflationRate)
        economicGrowthRate = try container.decode(Double.self, forKey: .economicGrowthRate)

        // Initialize central bank
        centralBank = CentralBank(baseRate: baseInterestRate)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(minimumReserveRatio, forKey: .minimumReserveRatio)
        try container.encode(depositInsuranceLimit, forKey: .depositInsuranceLimit)
        try container.encode(maximumLoanToValueRatio, forKey: .maximumLoanToValueRatio)
        try container.encode(baseInterestRate, forKey: .baseInterestRate)
        try container.encode(inflationRate, forKey: .inflationRate)
        try container.encode(economicGrowthRate, forKey: .economicGrowthRate)
    }
}
