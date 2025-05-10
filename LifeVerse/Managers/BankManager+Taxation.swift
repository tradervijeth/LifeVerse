//
//  BankManager+Taxation.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

// Import the models so we can use the existing TaxPayment and EmploymentRecord types
// Note: The code was previously defining these types directly, which caused duplication
// Now we're using the existing models from the Models directory

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
        
        // Record tax payment using the model's TaxPayment class
        let taxPayment = TaxPayment(
            year: currentYear, 
            amount: incomeTax + propertyTax + capitalGainsTax + interestTax,
            type: .incomeTax, // Using the main type as income tax
            date: Date(),
            deductions: [] // No deductions recorded
        )
        taxPaymentHistory.append(taxPayment)
        
        // Return total taxes paid
        return (incomeTax, propertyTax, capitalGainsTax, interestTax)
    }
    
    // Income tax calculation method
    private func calculateIncomeTax(currentYear: Int) -> Double {
        // Use the annualIncome property to calculate taxes
        // This is a simplified tax calculation
        if annualIncome <= 0 {
            return 0
        }
        
        // Simple progressive tax calculation
        if annualIncome <= 10000 {
            return annualIncome * 0.10 // 10% tax bracket
        } else if annualIncome <= 40000 {
            return 1000 + (annualIncome - 10000) * 0.15 // 15% bracket
        } else if annualIncome <= 85000 {
            return 5500 + (annualIncome - 40000) * 0.25 // 25% bracket
        } else if annualIncome <= 160000 {
            return 16750 + (annualIncome - 85000) * 0.28 // 28% bracket
        } else if annualIncome <= 215000 {
            return 37750 + (annualIncome - 160000) * 0.33 // 33% bracket
        } else {
            return 55900 + (annualIncome - 215000) * 0.35 // 35% bracket
        }
    }
    
    // Property tax calculation method
    private func calculatePropertyTax(currentYear: Int) -> Double {
        var totalPropertyTax = 0.0
        
        // Calculate property tax for owned properties
        for property in propertyInvestments {
            let taxRate = property.propertyTaxRate
            totalPropertyTax += property.currentValue * taxRate
        }
        
        return totalPropertyTax
    }
    
    // Capital gains tax calculation method
    private func calculateCapitalGainsTax(currentYear: Int) -> Double {
        // For now, return 0 as we don't track investment sales
        // In a more complex implementation, this would calculate 
        // taxes on sold investments or properties
        return 0.0
    }
    
    // Interest income tax calculation method
    private func calculateInterestIncomeTax(currentYear: Int) -> Double {
        var totalInterestEarned = 0.0
        
        // Calculate interest earned from savings accounts, CDs, etc.
        for account in accounts {
            if account.isActive && account.balance > 0 {
                // Only include certain account types that earn taxable interest
                if account.accountType == .savings || 
                   account.accountType == .cd || 
                   account.accountType == .checking {
                    
                    // Find interest transactions for this account in current year
                    let interestTransactions = account.transactions.filter { transaction in
                        transaction.type == .interest && transaction.year == currentYear
                    }
                    
                    // Sum up interest earned
                    let interestEarned = interestTransactions.reduce(0) { $0 + $1.amount }
                    totalInterestEarned += interestEarned
                }
            }
        }
        
        // Simple flat tax on interest (e.g., 15%)
        return totalInterestEarned * 0.15
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
        // Update annual income
        annualIncome = income
        
        // Use the proper method to update employment status
        updateEmploymentStatus(status)
        
        // Add to employment history 
        let record = EmploymentRecord(
            employer: "Current Employer", 
            jobTitle: "Current Position", 
            startYear: Calendar.current.component(.year, from: Date()),
            salary: income,
            isFullTime: status == .employed
        )
        employmentHistory.append(record)
        
        // Limit history to last 10 years
        if employmentHistory.count > 10 {
            employmentHistory.removeFirst(employmentHistory.count - 10)
        }
    }
    
    // Calculate debt-to-income ratio
    func calculateDebtToIncomeRatio() -> Double {
        // Correctly calculate DTI ratio using monthly payments divided by monthly income
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
    
    // Calculate mortgage payment
    private func calculateMortgagePayment(principal: Double, monthlyInterestRate: Double, numberOfPayments: Int) -> Double {
        if monthlyInterestRate <= 0 || numberOfPayments <= 0 {
            return principal / Double(numberOfPayments)
        }
        
        let rateFactorNumerator = monthlyInterestRate * pow(1 + monthlyInterestRate, Double(numberOfPayments))
        let rateFactorDenominator = pow(1 + monthlyInterestRate, Double(numberOfPayments)) - 1
        
        return principal * (rateFactorNumerator / rateFactorDenominator)
    }
    
    // Get maximum allowable debt-to-income ratio based on loan type
    private func getMaxAllowableDTI(loanType: Banking_AccountType) -> Double {
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
    private func checkEmploymentStability(loanType: Banking_AccountType) -> Bool {
        // For mortgages, typically need 2 years of stable employment
        if loanType == .mortgage {
            // Need at least 2 years of history
            if employmentHistory.count < 2 {
                return false
            }
            
            // Check for employment gaps or significant income decreases
            for i in 1..<min(employmentHistory.count, 3) {
                // Check for fulltime status instead of using status property
                if !employmentHistory[i].isFullTime {
                    return false
                }
                
                // Check for significant income decrease (more than 25%)
                if employmentHistory[i].salary < employmentHistory[i-1].salary * 0.75 {
                    return false
                }
            }
        } else {
            // For other loans, just check current employment status
            // Using the public accessor now
            return employmentStatus != .unemployed
        }
        
        return true
    }
}
