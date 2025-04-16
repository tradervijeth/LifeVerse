//
//  BankManager+Taxation.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

// Extension to BankManager to handle taxation and income-based loan qualification
extension BankManager {
    // MARK: - Taxation Methods

    // Process yearly taxes
    func processYearlyTaxes(currentYear: Int) -> (incomeTax: Double, propertyTax: Double, capitalGainsTax: Double, interestTax: Double) {
        // Calculate income tax
        let incomeTax = calculateIncomeTax(currentYear: currentYear)

        // Calculate property tax
        let propertyTax = calculatePropertyTax(currentYear: currentYear)

        // Calculate capital gains tax
        let capitalGainsTax = calculateCapitalGainsTax(currentYear: currentYear)

        // Calculate interest income tax
        let interestTax = calculateInterestIncomeTax(currentYear: currentYear)

        // Record tax payment
        let taxPayment = TaxPayment(
            year: currentYear,
            incomeTax: incomeTax,
            propertyTax: propertyTax,
            capitalGainsTax: capitalGainsTax,
            interestTax: interestTax
        )
        taxPaymentHistory.append(taxPayment)

        // Return total taxes paid
        return (incomeTax, propertyTax, capitalGainsTax, interestTax)
    }

    // Calculate income tax
    private func calculateIncomeTax(currentYear: Int) -> Double {
        // Get deductions
        let mortgageInterest = calculateMortgageInterestPaid(currentYear: currentYear)
        let propertyTaxPaid = calculatePropertyTax(currentYear: currentYear)
        let studentLoanInterest = calculateStudentLoanInterestPaid(currentYear: currentYear)

        // Calculate deductions
        let deductions = taxationSystem.calculateDeductions(
            mortgageInterest: mortgageInterest,
            propertyTaxPaid: propertyTaxPaid,
            studentLoanInterest: studentLoanInterest
        )

        // Calculate taxable income
        let taxableIncome = max(0, annualIncome - deductions)

        // Calculate income tax
        return taxationSystem.calculateIncomeTax(annualIncome: taxableIncome)
    }

    // Calculate property tax for all owned properties
    private func calculatePropertyTax(currentYear: Int) -> Double {
        var totalPropertyTax: Double = 0

        // Calculate property tax for each property
        for property in propertyInvestments {
            let propertyTax = taxationSystem.calculatePropertyTax(
                propertyValue: property.currentValue,
                location: property.location
            )
            totalPropertyTax += propertyTax
        }

        return totalPropertyTax
    }

    // Calculate capital gains tax for investment sales in the current year
    private func calculateCapitalGainsTax(currentYear: Int) -> Double {
        var totalCapitalGainsTax: Double = 0

        // Find investment transactions that represent sales (capital gains)
        let investmentSales = transactionHistory.filter { transaction in
            transaction.type == .investmentReturn && transaction.year == currentYear && transaction.amount > 0
        }

        // Calculate capital gains tax for each sale
        for sale in investmentSales {
            // Determine holding period (simplified for now)
            let holdingPeriod = 1 // Assume 1 year for now

            // Calculate capital gains tax
            let capitalGainsTax = taxationSystem.calculateCapitalGainsTax(
                gain: sale.amount,
                holdingPeriodYears: holdingPeriod
            )

            totalCapitalGainsTax += capitalGainsTax
        }

        return totalCapitalGainsTax
    }

    // Calculate tax on interest income
    private func calculateInterestIncomeTax(currentYear: Int) -> Double {
        var totalInterestTax: Double = 0

        // Find interest transactions for the current year
        let interestTransactions = transactionHistory.filter { transaction in
            transaction.type == .interest && transaction.year == currentYear && transaction.amount > 0
        }

        // Calculate tax for each interest transaction
        for transaction in interestTransactions {
            let interestTax = taxationSystem.calculateInterestIncomeTax(interestAmount: transaction.amount)
            totalInterestTax += interestTax
        }

        return totalInterestTax
    }

    // Calculate mortgage interest paid in the current year
    private func calculateMortgageInterestPaid(currentYear: Int) -> Double {
        var totalMortgageInterest: Double = 0

        // Get all mortgage accounts
        let mortgages = accounts.filter { $0.accountType == .mortgage && $0.isActive }

        // Calculate interest paid for each mortgage
        for mortgage in mortgages {
            // Find interest transactions for this mortgage in the current year
            let interestTransactions = mortgage.transactions.filter { transaction in
                transaction.type == .interest && transaction.year == currentYear
            }

            // Sum up interest paid
            let interestPaid = interestTransactions.reduce(0) { $0 + $1.amount }
            totalMortgageInterest += interestPaid
        }

        return totalMortgageInterest
    }

    // Calculate student loan interest paid in the current year
    private func calculateStudentLoanInterestPaid(currentYear: Int) -> Double {
        var totalStudentLoanInterest: Double = 0

        // Get all student loan accounts
        let studentLoans = accounts.filter { $0.accountType == .studentLoan && $0.isActive }

        // Calculate interest paid for each student loan
        for loan in studentLoans {
            // Find interest transactions for this loan in the current year
            let interestTransactions = loan.transactions.filter { transaction in
                transaction.type == .interest && transaction.year == currentYear
            }

            // Sum up interest paid
            let interestPaid = interestTransactions.reduce(0) { $0 + $1.amount }
            totalStudentLoanInterest += interestPaid
        }

        return totalStudentLoanInterest
    }

    // MARK: - Income-Based Loan Qualification

    // Update annual income
    func updateAnnualIncome(income: Double, status: EmploymentStatus) {
        annualIncome = income
        employmentStatus = status

        // Add to employment history
        let record = EmploymentRecord(income: income, status: status)
        employmentHistory.append(record)

        // Limit history to last 10 years
        if employmentHistory.count > 10 {
            employmentHistory.removeFirst(employmentHistory.count - 10)
        }
    }

    // Calculate debt-to-income ratio
    func calculateDebtToIncomeRatio() -> Double {
        // Total debt is used for other calculations but not needed here
        _ = getTotalDebt()
        let monthlyDebtPayments = calculateMonthlyDebtPayments()
        let monthlyIncome = annualIncome / 12

        // Monthly debt-to-income ratio
        return monthlyIncome > 0 ? monthlyDebtPayments / monthlyIncome : 1.0
    }

    // Calculate monthly debt payments
    private func calculateMonthlyDebtPayments() -> Double {
        var totalMonthlyPayments: Double = 0

        // Calculate for each loan type
        for account in accounts {
            if !account.isActive { continue }

            switch account.accountType {
            case .mortgage, .autoLoan, .studentLoan, .loan:
                // Calculate monthly payment based on remaining balance, interest rate, and term
                let principal = abs(account.balance)
                let monthlyInterestRate = account.interestRate / 12
                let remainingMonths = account.term * 12

                if remainingMonths > 0 && principal > 0 {
                    let monthlyPayment = calculateMortgagePayment(
                        principal: principal,
                        monthlyInterestRate: monthlyInterestRate,
                        numberOfPayments: remainingMonths
                    )
                    totalMonthlyPayments += monthlyPayment
                }

            case .creditCard:
                // Minimum payment on credit cards (typically 2-4% of balance)
                let minimumPayment = max(25, abs(account.balance) * 0.03) // 3% or $25, whichever is higher
                totalMonthlyPayments += minimumPayment

            default:
                break
            }
        }

        return totalMonthlyPayments
    }

    // Enhanced loan qualification check that considers income
    func canQualifyForLoanWithIncome(amount: Double, loanType: BankAccountType = .loan, term: Int? = nil) -> Bool {
        // First check the basic qualification (credit score, etc.)
        if !canQualifyForLoan(amount: amount, loanType: loanType) {
            return false
        }

        // Calculate monthly payment for this loan
        let interestRate = loanType.defaultInterestRate() +
                          marketCondition.interestRateEffect() +
                          creditScoreCategoryObject().interestRateModifier()

        let loanTerm = term ?? loanType.defaultTerm()
        let monthlyInterestRate = interestRate / 12
        let numberOfPayments = loanTerm * 12

        let monthlyPayment = calculateMortgagePayment(
            principal: amount,
            monthlyInterestRate: monthlyInterestRate,
            numberOfPayments: numberOfPayments
        )

        // Calculate current debt-to-income ratio
        let currentDTI = calculateDebtToIncomeRatio()

        // Calculate new debt-to-income ratio with this loan
        let monthlyIncome = annualIncome / 12
        let currentMonthlyDebtPayments = currentDTI * monthlyIncome
        let newMonthlyDebtPayments = currentMonthlyDebtPayments + monthlyPayment
        let newDTI = monthlyIncome > 0 ? newMonthlyDebtPayments / monthlyIncome : 1.0

        // Check if new DTI is acceptable
        let maxAllowableDTI = getMaxAllowableDTI(loanType: loanType)

        // Check employment stability
        let hasStableEmployment = checkEmploymentStability(loanType: loanType)

        return newDTI <= maxAllowableDTI && hasStableEmployment
    }

    // Get maximum allowable debt-to-income ratio based on loan type
    private func getMaxAllowableDTI(loanType: BankAccountType) -> Double {
        switch loanType {
        case .mortgage:
            return 0.43 // 43% is typical for qualified mortgages
        case .autoLoan:
            return 0.50 // 50% for auto loans
        case .studentLoan:
            return 0.55 // 55% for student loans (more flexible)
        case .loan:
            return 0.45 // 45% for personal loans
        default:
            return 0.45 // Default for other loan types
        }
    }

    // Check employment stability based on employment history
    private func checkEmploymentStability(loanType: BankAccountType) -> Bool {
        // For mortgages, typically need 2 years of stable employment
        if loanType == .mortgage {
            // Need at least 2 years of history
            if employmentHistory.count < 2 {
                return false
            }

            // Check for employment gaps or significant income decreases
            for i in 1..<min(employmentHistory.count, 3) {
                if employmentHistory[i].status == .unemployed {
                    return false
                }

                // Check for significant income decrease (more than 25%)
                if employmentHistory[i].income < employmentHistory[i-1].income * 0.75 {
                    return false
                }
            }
        } else {
            // For other loans, just check current employment
            if employmentStatus == .unemployed {
                return false
            }
        }

        return true
    }

    // Calculate maximum loan amount based on income
    func calculateMaxLoanAmountBasedOnIncome(loanType: BankAccountType, term: Int? = nil) -> Double {
        // Get maximum allowable DTI
        let maxDTI = getMaxAllowableDTI(loanType: loanType)

        // Calculate monthly income
        let monthlyIncome = annualIncome / 12

        // Calculate current monthly debt payments
        let currentMonthlyDebtPayments = calculateMonthlyDebtPayments()

        // Calculate available monthly payment amount
        let availableMonthlyPayment = (monthlyIncome * maxDTI) - currentMonthlyDebtPayments

        // If no room in budget, return 0
        if availableMonthlyPayment <= 0 {
            return 0
        }

        // Calculate loan amount based on available payment
        let loanTerm = term ?? loanType.defaultTerm()
        let interestRate = loanType.defaultInterestRate() +
                          marketCondition.interestRateEffect() +
                          creditScoreCategoryObject().interestRateModifier()
        let monthlyInterestRate = interestRate / 12
        let numberOfPayments = loanTerm * 12

        // Calculate maximum loan amount
        // Formula: P = PMT * [(1 - (1 + r)^-n) / r]
        // Where P = principal, PMT = monthly payment, r = monthly interest rate, n = number of payments
        let maxLoanAmount: Double

        if monthlyInterestRate > 0 {
            maxLoanAmount = availableMonthlyPayment *
                           (1 - pow(1 + monthlyInterestRate, -Double(numberOfPayments))) /
                           monthlyInterestRate
        } else {
            // If interest rate is 0, simple division
            maxLoanAmount = availableMonthlyPayment * Double(numberOfPayments)
        }

        // Compare with credit-based maximum and take the lower amount
        let creditBasedMax = maximumLoanAmount(loanType: loanType)

        return min(maxLoanAmount, creditBasedMax)
    }
}

// MARK: - Supporting Types

// Employment status enum
enum EmploymentStatus: String, Codable {
    case employed = "Employed"
    case selfEmployed = "Self-Employed"
    case partTime = "Part-Time"
    case unemployed = "Unemployed"
    case retired = "Retired"

    // Get loan qualification multiplier
    func loanQualificationMultiplier() -> Double {
        switch self {
        case .employed: return 1.0 // Full qualification
        case .selfEmployed: return 0.8 // 80% qualification (higher risk)
        case .partTime: return 0.6 // 60% qualification
        case .unemployed: return 0.0 // Cannot qualify
        case .retired: return 0.7 // 70% qualification
        }
    }
}

// Employment record for tracking employment history
struct EmploymentRecord: Codable {
    var date: Date = Date()
    var income: Double
    var status: EmploymentStatus

    init(income: Double, status: EmploymentStatus) {
        self.income = income
        self.status = status
    }
}

// Tax payment record
struct TaxPayment: Codable, Identifiable {
    var id = UUID()
    var date: Date = Date()
    var year: Int
    var incomeTax: Double
    var propertyTax: Double
    var capitalGainsTax: Double
    var interestTax: Double

    // Get total tax paid
    var totalTaxPaid: Double {
        return incomeTax + propertyTax + capitalGainsTax + interestTax
    }

    // Format total tax as currency string
    func formattedTotalTax() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: totalTaxPaid)) ?? "$\(totalTaxPaid)"
    }
}

