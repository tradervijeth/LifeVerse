//
//  BankingView.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import SwiftUI

struct BankingView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedTab: String = "Accounts"
    @State private var selectedAccountId: UUID? = nil
    @State private var showNewAccountSheet: Bool = false
    @State private var showTransferSheet: Bool = false
    @State private var showLoanApplicationSheet: Bool = false
    @State private var amount: String = ""
    @State private var transferToAccountId: UUID? = nil
    
    private var bankManager: BankManager {
        return gameManager.bankManager
    }
    
    private var tabs = ["Accounts", "Credit", "Loans", "Transactions"]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with banking info
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "building.columns.fill")
                        .font(.title2)
                    Text("LifeVerse Bank")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                if let character = gameManager.character {
                    Text("Welcome, \(character.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Credit score indicator
                HStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Credit Score")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(bankManager.creditScore)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    // Credit score meter
                    CreditScoreMeter(score: bankManager.creditScore)
                    
                    VStack(alignment: .trailing) {
                        Text(bankManager.creditScoreCategory())
                            .font(.caption)
                            .foregroundColor(creditScoreCategoryColor())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(creditScoreCategoryColor().opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            .padding()
            
            // Tab selector
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                        // Reset selection when changing tabs
                        if tab != "Accounts" {
                            selectedAccountId = nil
                        }
                    }) {
                        Text(tab)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundColor(selectedTab == tab ? .white : .primary)
                            .background(selectedTab == tab ? Color.blue : Color.clear)
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemBackground))
            
            // Content based on selected tab
            ScrollView {
                VStack(spacing: 15) {
                    switch selectedTab {
                    case "Accounts":
                        accountsView
                    case "Credit":
                        creditView
                    case "Loans":
                        loansView
                    case "Transactions":
                        transactionsView
                    default:
                        accountsView
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80) // Space for button
            }
            
            // Footer with banking actions
            HStack(spacing: 20) {
                // New Account button
                Button(action: {
                    showNewAccountSheet = true
                }) {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                        Text("New Account")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Transfer button
                Button(action: {
                    showTransferSheet = true
                }) {
                    VStack {
                        Image(systemName: "arrow.left.arrow.right.circle.fill")
                            .font(.system(size: 24))
                        Text("Transfer")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }
                
                Spacer()
                
                // Apply for Loan button
                Button(action: {
                    showLoanApplicationSheet = true
                }) {
                    VStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 24))
                        Text("Get Loan")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
        .sheet(isPresented: $showNewAccountSheet) {
            NewAccountView(bankManager: bankManager, currentYear: gameManager.currentYear, isPresented: $showNewAccountSheet)
        }
        .sheet(isPresented: $showTransferSheet) {
            TransferView(bankManager: bankManager, isPresented: $showTransferSheet)
        }
        .sheet(isPresented: $showLoanApplicationSheet) {
            LoanApplicationView(bankManager: bankManager, currentYear: gameManager.currentYear, isPresented: $showLoanApplicationSheet)
        }
    }
    
    // MARK: - Tab Views
    
    var accountsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if selectedAccountId == nil {
                // Show all accounts
                Text("Your Accounts")
                    .font(.headline)
                
                let activeAccounts = bankManager.getActiveAccounts()
                
                if activeAccounts.isEmpty {
                    Text("You don't have any accounts yet. Open a new account to get started.")
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // Group accounts by type
                    let checkingAccounts = bankManager.getAccounts(ofType: .checking)
                    let savingsAccounts = bankManager.getAccounts(ofType: .savings)
                    let cdAccounts = bankManager.getAccounts(ofType: .cd)
                    let investmentAccounts = bankManager.getAccounts(ofType: .investment)
                    let creditCards = bankManager.getAccounts(ofType: .creditCard)
                    
                    // Display account groups
                    if !checkingAccounts.isEmpty {
                        accountGroupView(title: "Checking", accounts: checkingAccounts)
                    }
                    
                    if !savingsAccounts.isEmpty {
                        accountGroupView(title: "Savings", accounts: savingsAccounts)
                    }
                    
                    if !cdAccounts.isEmpty {
                        accountGroupView(title: "Certificates of Deposit", accounts: cdAccounts)
                    }
                    
                    if !investmentAccounts.isEmpty {
                        accountGroupView(title: "Investments", accounts: investmentAccounts)
                    }
                    
                    if !creditCards.isEmpty {
                        accountGroupView(title: "Credit Cards", accounts: creditCards)
                    }
                    
                    // Financial summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Financial Summary")
                            .font(.headline)
                        
                        HStack {
                            Text("Total Deposits:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(Int(bankManager.getTotalDeposits()).formattedWithSeparator())")
                                .fontWeight(.medium)
                        }
                        
                        HStack {
                            Text("Total Debt:")
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("$\(Int(bankManager.getTotalDebt()).formattedWithSeparator())")
                                .fontWeight(.medium)
                                .foregroundColor(.red)
                        }
                        
                        HStack {
                            Text("Net Worth:")
                                .font(.headline)
                            Spacer()
                            Text("$\(Int(bankManager.getNetWorth()).formattedWithSeparator())")
                                .font(.headline)
                                .foregroundColor(bankManager.getNetWorth() >= 0 ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                }
            } else {
                // Show account detail
                if let account = bankManager.getAccount(id: selectedAccountId!) {
                    HStack {
                        Button(action: {
                            selectedAccountId = nil
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back to Accounts")
                            }
                            .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    
                    accountDetailView(account: account)
                }
            }
        }
    }
    
    var creditView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Credit Profile")
                .font(.headline)
            
            // Credit score details
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Credit Score:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(bankManager.creditScore)")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Category:")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(bankManager.creditScoreCategory())
                        .foregroundColor(creditScoreCategoryColor())
                        .fontWeight(.medium)
                }
                
                // Credit score visualization
                VStack(alignment: .leading, spacing: 5) {
                    Text("Score Range")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .frame(height: 8)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .cornerRadius(4)
                        
                        // Colored segments
                        HStack(spacing: 0) {
                            Rectangle()
                                .frame(width: 110, height: 8)
                                .foregroundColor(.red)
                            Rectangle()
                                .frame(width: 90, height: 8)
                                .foregroundColor(.orange)
                            Rectangle()
                                .frame(width: 70, height: 8)
                                .foregroundColor(.yellow)
                            Rectangle()
                                .frame(width: 60, height: 8)
                                .foregroundColor(.green)
                            Rectangle()
                                .frame(width: 50, height: 8)
                                .foregroundColor(.blue)
                        }
                        .cornerRadius(4)
                        
                        // Score indicator
                        Circle()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                            .overlay(Circle().stroke(Color.black, lineWidth: 2))
                            .offset(x: CGFloat(bankManager.creditScore - 300) * (380 / 550) - 8)
                    }
                    
                    // Score labels
                    HStack {
                        Text("300")
                            .font(.caption)
                        Spacer()
                        Text("850")
                            .font(.caption)
                    }
                }
                .padding(.vertical, 10)
                
                // Credit factors
                Text("Factors Affecting Your Score")
                    .font(.subheadline)
                    .padding(.top, 5)
                
                creditFactorRow(icon: "checkmark.circle.fill", factor: "Payment History", description: "Always pay on time", isPositive: true)
                
                creditFactorRow(icon: "dollarsign.circle", factor: "Credit Utilization", description: "\(Int(bankManager.calculateCreditUtilization() * 100))% of available credit used", isPositive: bankManager.calculateCreditUtilization() < 0.3)
                
                creditFactorRow(icon: "clock", factor: "Credit Age", description: "Average account age", isPositive: true)
                
                creditFactorRow(icon: "creditcard", factor: "Credit Mix", description: "Variety of credit types", isPositive: bankManager.getActiveAccounts().count > 2)
                
                creditFactorRow(icon: "magnifyingglass", factor: "Credit Inquiries", description: "\(bankManager.creditReportRequests) recent inquiries", isPositive: bankManager.creditReportRequests < 2)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            
            // Credit report button
            Button(action: {
                // Request credit report
                _ = bankManager.requestCreditReport()
            }) {
                Text("Request Credit Report")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 10)
        }
    }
    
    var loansView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Loans & Mortgages")
                .font(.headline)
            
            // Get all loan types
            let loans = bankManager.getAccounts(ofType: .loan)
            let mortgages = bankManager.getAccounts(ofType: .mortgage)
            let autoLoans = bankManager.getAccounts(ofType: .autoLoan)
            let studentLoans = bankManager.getAccounts(ofType: .studentLoan)
            
            let allLoans = loans + mortgages + autoLoans + studentLoans
            
            if allLoans.isEmpty {
                Text("You don't have any active loans. Apply for a loan to see it here.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                // Show all loans
                ForEach(allLoans) { loan in
                    loanCardView(loan: loan)
                }
                
                // Loan eligibility
                VStack(alignment: .leading, spacing: 10) {
                    Text("Loan Eligibility")
                        .font(.headline)
                    
                    HStack {
                        Text("Maximum Loan Amount:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(Int(bankManager.maximumLoanAmount()).formattedWithSeparator())")
                            .fontWeight(.medium)
                    }
                    
                    // Collateral assets
                    if !bankManager.getAvailableCollateral().isEmpty {
                        Text("Available Collateral")
                            .font(.subheadline)
                            .padding(.top, 5)
                        
                        ForEach(bankManager.getAvailableCollateral()) { collateral in
                            HStack {
                                Image(systemName: collateralTypeIcon(collateral.type))
                                    .foregroundColor(.blue)
                                Text(collateral.description)
                                    .font(.subheadline)
                                Spacer()
                                Text("$\(Int(collateral.currentValue(currentYear: gameManager.currentYear)).formattedWithSeparator())")
                                    .font(.subheadline)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            
            // Loan calculator
            VStack(alignment: .leading, spacing: 10) {
                Text("Loan Calculator")
                    .font(.headline)
                
                Text("Coming soon! Calculate monthly payments and total interest for different loan amounts and terms.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    var transactionsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Transaction History")
                .font(.headline)
            
            if bankManager.transactionHistory.isEmpty {
                Text("No transactions yet. Your banking activity will appear here.")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                // Group transactions by category
                let groupedTransactions = Dictionary(grouping: bankManager.transactionHistory) { $0.category }
                
                // Show spending by category
                VStack(alignment: .leading, spacing: 10) {
                    Text("Spending by Category")
                        .font(.subheadline)
                    
                    // Create a simple bar chart of spending by category
                    ForEach(TransactionCategory.allCases.filter { category in
                        groupedTransactions[category] != nil
                    }, id: \.self) { category in
                        let transactions = groupedTransactions[category] ?? []
                        let total = transactions.reduce(0) { $0 + $1.amount }
                        
                        HStack(spacing: 10) {
                            Image(systemName: category.iconName())
                                .foregroundColor(Color(category.color()))
                            
                            Text(category.rawValue)
                                .font(.caption)
                                .frame(width: 100, alignment: .leading)
                            
                            // Bar representing amount
                            GeometryReader { geometry in
                                let maxAmount = bankManager.transactionHistory.reduce(0) { max($0, $1.amount) }
                                let width = maxAmount > 0 ? CGFloat(total / maxAmount) * geometry.size.width : 0
                                
                                Rectangle()
                                    .fill(Color(category.color()))
                                    .frame(width: width, height: 20)
                                    .cornerRadius(4)
                            }
                            .frame(height: 20)
                            
                            Text("$\(Int(total).formattedWithSeparator())")
                                .font(.caption)
                                .frame(width: 80, alignment: .trailing)
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                
                // Recent transactions
                Text("Recent Transactions")
                    .font(.headline)
                    .padding(.top, 10)
                
                ForEach(bankManager.transactionHistory.prefix(10)) { transaction in
                    transactionRowView(transaction: transaction)
                }
                
                if bankManager.transactionHistory.count > 10 {
                    Text("+ \(bankManager.transactionHistory.count - 10) more transactions...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
    
    // MARK: - Helper Views
    
    func accountGroupView(title: String, accounts: [BankAccount]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ForEach(accounts) { account in
                Button(action: {
                    selectedAccountId = account.id
                }) {
                    accountCardView(account: account)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    func accountCardView(account: BankAccount) -> some View {
        HStack {
            // Account icon
            Image(systemName: accountTypeIcon(account.accountType))
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 40, height: 40)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
            
            // Account info
            VStack(alignment: .leading, spacing: 4) {
                Text(account.accountType.rawValue)
                    .font(.headline)
                
                if account.accountType == .cd {
                    Text("\(account.term) Year Term")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else if account.accountType == .creditCard {
                    Text("Available Credit: $\(Int(account.availableBalance()).formattedWithSeparator())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Balance
            VStack(alignment: .trailing, spacing: 4) {
                if account.accountType == .creditCard || account.accountType == .loan || 
                   account.accountType == .mortgage || account.accountType == .autoLoan || 
                   account.accountType == .studentLoan {
                    // For debt accounts, show amount owed
                    Text("$\(Int(abs(account.balance)).formattedWithSeparator())")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text("\(account.interestRate * 100, specifier: "%.2f")% APR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    // For asset accounts, show positive balance
                    Text("$\(Int(account.balance).formattedWithSeparator())")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("\(account.interestRate * 100, specifier: "%.2f")% APY")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    func accountDetailView(account: BankAccount) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            // Account header
            HStack {
                Image(systemName: accountTypeIcon(account.accountType))
                    .font(.title)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text(account.accountType.rawValue)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Opened in Year \(account.creationYear)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Account details
            VStack(spacing: 15) {
                // Balance information
                VStack(alignment: .leading, spacing: 5) {
                    Text("Balance")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if account.accountType == .creditCard || account.accountType == .loan || 
                       account.accountType == .mortgage || account.accountType == .autoLoan || 
                       account.accountType == .studentLoan {
                        Text("$\(Int(abs(account.balance)).formattedWithSeparator())")
                            .font(.title)
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                        
                        Text("Amount Owed")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("$\(Int(account.balance).formattedWithSeparator())")
                            .font(.title)
                            .foregroundColor(.primary)
                            .fontWeight(.bold)
                        
                        Text("Current Balance")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
                
                // Account details grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    // Interest rate
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Interest Rate")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(account.interestRate * 100, specifier: "%.2f")%")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(UIColor.tertiarySystemBackground))
                    .cornerRadius(10)
                    
                    // Account term (if applicable)
                    if account.term > 0 {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Term")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(account.term) Years")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                    } else if account.accountType == .creditCard {
                        // Credit limit
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Credit Limit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(Int(account.creditLimit).formattedWithSeparator())")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                    } else {
                        // Monthly fee
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Monthly Fee")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(account.monthlyFee, specifier: "%.2f")")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    // Minimum balance
                    if account.minimumBalance > 0 {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Minimum Balance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(Int(account.minimumBalance).formattedWithSeparator())")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                    }
                    
                    // Available balance (for credit cards)
                    if account.accountType == .creditCard {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Available Credit")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(Int(account.availableBalance()).formattedWithSeparator())")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(UIColor.tertiarySystemBackground))
                        .cornerRadius(10)
                    }
                }
            }
            
            // Account actions
            HStack(spacing: 15) {
                // Deposit button
                if account.accountType != .creditCard {
                    Button(action: {
                        // Show deposit sheet
                    }) {
                        VStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.system(size: 24))
                            Text("Deposit")
                                .font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(AccountActionButtonStyle())
                }
                
                // Withdraw/Payment button
                Button(action: {
                    // Show withdraw/payment sheet
                }) {
                    VStack {
                        Image(systemName: account.accountType == .creditCard || account.accountType == .loan ? "arrow.up.circle.fill" : "arrow.up.circle.fill")
                            .font(.system(size: 24))
                        Text(account.accountType == .creditCard || account.accountType == .loan ? "Payment" : "Withdraw")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(AccountActionButtonStyle())
                
                // Close account button
                Button(action: {
                    // Show close account confirmation
                }) {
                    VStack {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                        Text("Close")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(AccountActionButtonStyle())
            }
            
            // Transaction history
            VStack(alignment: .leading, spacing: 10) {
                Text("Recent Transactions")
                    .font(.headline)
                
                if account.transactions.isEmpty {
                    Text("No transactions yet")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(account.transactions.prefix(5)) { transaction in
                        transactionRowView(transaction: transaction)
                    }
                    
                    if account.transactions.count > 5 {
                        Button(action: {
                            // Show all transactions
                        }) {
                            Text("View All Transactions")
                                .font(.caption)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
        }
    }
    
    func loanCardView(loan: BankAccount) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Loan icon
                Image(systemName: accountTypeIcon(loan.accountType))
                    .font(.title3)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                
                // Loan info
                VStack(alignment: .leading, spacing: 4) {
                    Text(loan.accountType.rawValue)
                        .font(.headline)
                    
                    Text("\(loan.term) Year Term")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Balance
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(Int(abs(loan.balance)).formattedWithSeparator())")
                        .font(.headline)
                        .foregroundColor(.red)
                    
                    Text("\(loan.interestRate * 100, specifier: "%.2f")% APR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Progress bar for loan repayment
            VStack(alignment: .leading, spacing: 5) {
                Text("Repayment Progress")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background track
                        Rectangle()
                            .frame(height: 8)
                            .foregroundColor(Color.gray.opacity(0.3))
                            .cornerRadius(4)
                        
                        // Progress
                        let initialAmount = abs(loan.transactions.first?.amount ?? 0)
                        let progress = initialAmount > 0 ? (initialAmount - abs(loan.balance)) / initialAmount : 0
                        
                        Rectangle()
                            .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
                
                // Remaining years
                let yearsElapsed = gameManager.currentYear - loan.creationYear
                let remainingYears = max(0, loan.term - yearsElapsed)
                
                HStack {
                    Text("\(Int(remainingYears)) years remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(action: {
                        // Make payment
                    }) {
                        Text("Make Payment")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .cornerRadius(15)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    func transactionRowView(transaction: BankTransaction) -> some View {
        HStack {
            // Transaction icon
            Image(systemName: transactionTypeIcon(transaction.type))
                .font(.body)
                .foregroundColor(transactionTypeColor(transaction.type))
                .frame(width: 36, height: 36)
                .background(transactionTypeColor(transaction.type).opacity(0.1))
                .cornerRadius(18)
            
            // Transaction info
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.description)
                    .font(.subheadline)
                
                Text(transaction.formattedDate())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Amount
            Text(transaction.formattedAmount())
                .font(.headline)
                .foregroundColor(transactionAmountColor(transaction))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(8)
    }
    
    func creditFactorRow(icon: String, factor: String, description: String, isPositive: Bool) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(isPositive ? .green : .orange)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(factor)
                    .font(.subheadline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                .foregroundColor(isPositive ? .green : .orange)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Helper Functions
    
    func accountTypeIcon(_ type: BankAccountType) -> String {
        switch type {
        case .checking: return "dollarsign.circle"
        case .savings: return "banknote"
        case .creditCard: return "creditcard"
        case .loan: return "dollarsign.square"
        case .cd: return "timer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .mortgage: return "house"
        case .autoLoan: return "car"
        case .studentLoan: return "book"
        case .businessAccount: return "briefcase"
        case .retirementAccount: return "leaf"
        }
    }
    
    func transactionTypeIcon(_ type: BankTransactionType) -> String {
        switch type {
        case .deposit: return "arrow.down"
        case .withdrawal: return "arrow.up"
        case .transfer: return "arrow.left.arrow.right"
        case .payment: return "checkmark"
        case .fee: return "exclamationmark.circle"
        case .interest: return "percent"
        case .loan: return "dollarsign.square"
        case .purchase: return "cart"
        case .refund: return "arrow.uturn.down"
        case .cashback: return "gift"
        case .directDeposit: return "arrow.down.doc"
        case .check: return "doc.text"
        case .atmTransaction: return "building.columns"
        case .wireTransfer: return "network"
        case .investmentReturn: return "chart.line.uptrend.xyaxis"
        }
    }
    
    func transactionTypeColor(_ type: BankTransactionType) -> Color {
        switch type {
        case .deposit, .refund, .cashback, .directDeposit, .interest, .investmentReturn:
            return .green
        case .withdrawal, .fee, .purchase, .atmTransaction:
            return .red
        case .transfer, .wireTransfer:
            return .blue
        case .payment, .check:
            return .purple
        case .loan:
            return .orange
        }
    }
    
    func transactionAmountColor(_ transaction: BankTransaction) -> Color {
        switch transaction.type {
        case .deposit, .refund, .cashback, .directDeposit, .interest, .investmentReturn:
            return .green
        case .withdrawal, .fee, .purchase, .atmTransaction, .payment:
            return .red
        default:
            return .primary
        }
    }
    
    func collateralTypeIcon(_ type: CollateralType) -> String {
        switch type {
        case .realEstate: return "house"
        case .vehicle: return "car"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .savings: return "banknote"
        case .jewelry: return "sparkles"
        case .electronics: return "desktopcomputer"
        case .other: return "cube"
        }
    }
    
    func creditScoreCategoryColor() -> Color {
        switch bankManager.creditScoreCategoryObject() {
        case .poor: return .red
        case .fair: return .orange
        case .good: return .yellow
        case .veryGood: return .green
        case .excellent: return .blue
        }
    }
}

// MARK: - Supporting Views

struct CreditScoreMeter: View {
    let score: Int
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .frame(height: 8)
                    .foregroundColor(Color.gray.opacity(0.3))
                    .cornerRadius(4)
                
                // Colored segments
                HStack(spacing: 0) {
                    Rectangle()
                        .frame(width: geometry.size.width * 0.2, height: 8)
                        .foregroundColor(.red)
                    Rectangle()
                        .frame(width: geometry.size.width * 0.2, height: 8)
                        .foregroundColor(.orange)
                    Rectangle()
                        .frame(width: geometry.size.width * 0.2, height: 8)
                        .foregroundColor(.yellow)
                    Rectangle()
                        .frame(width: geometry.size.width * 0.2, height: 8)
                        .foregroundColor(.green)
                    Rectangle()
                        .frame(width: geometry.size.width * 0.2, height: 8)
                        .foregroundColor(.blue)
                }
                .cornerRadius(4)
                
                // Score indicator
                Circle()
                    .frame(width: 16, height: 16)
                    .foregroundColor(.white)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                    .offset(x: CGFloat(score - 300) * (geometry.size.width / 550) - 8)
            }
        }
        .frame(height: 16)
    }
}

struct AccountActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.vertical, 10)
            .background(configuration.isPressed ? Color.gray.opacity(0.2) : Color.clear)
            .cornerRadius(8)
    }
}

// MARK: - Sheet Views

struct NewAccountView: View {
    @ObservedObject var bankManager: BankManager
    let currentYear: Int
    @Binding var isPresented: Bool
    @State private var selectedAccountType: BankAccountType = .checking
    @State private var initialDeposit: String = ""
    @State private var term: Int = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Account Type")) {
                    Picker("Select Account Type", selection: $selectedAccountType) {
                        ForEach(BankAccountType.allCases.filter { $0 != .mortgage && $0 != .autoLoan }, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text(selectedAccountType.description())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Initial Deposit")) {
                    TextField("Amount", text: $initialDeposit)
                        .keyboardType(.decimalPad)
                    
                    Text("Minimum: $\(Int(selectedAccountType.minimumInitialDeposit()).formattedWithSeparator())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if selectedAccountType == .cd || selectedAccountType == .loan {
                    Section(header: Text("Term")) {
                        Stepper("\(term) \(term == 1 ? "Year" : "Years")", value: $term, in: 1...30)
                    }
                }
                
                Section {
                    Button(action: {
                        openAccount()
                    }) {
                        Text("Open Account")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("New Account")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    private func openAccount() {
        guard let amount = Double(initialDeposit) else { return }
        
        if amount >= selectedAccountType.minimumInitialDeposit() {
            _ = bankManager.openAccount(
                type: selectedAccountType,
                initialDeposit: amount,
                currentYear: currentYear,
                term: selectedAccountType == .cd || selectedAccountType == .loan ? term : nil
            )
            isPresented = false
        }
    }
}

struct TransferView: View {
    @ObservedObject var bankManager: BankManager
    @Binding var isPresented: Bool
    @State private var fromAccountId: UUID? = nil
    @State private var toAccountId: UUID? = nil
    @State private var amount: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("From Account")) {
                    Picker("Select Account", selection: $fromAccountId) {
                        Text("Select Account").tag(nil as UUID?)
                        ForEach(bankManager.getActiveAccounts().filter { $0.balance > 0 }) { account in
                            Text("\(account.accountType.rawValue) - $\(Int(account.balance).formattedWithSeparator())")
                                .tag(account.id as UUID?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("To Account")) {
                    Picker("Select Account", selection: $toAccountId) {
                        Text("Select Account").tag(nil as UUID?)
                        ForEach(bankManager.getActiveAccounts().filter { account in
                            guard let fromId = fromAccountId else { return false }
                            return account.id != fromId
                        }) { account in
                            Text("\(account.accountType.rawValue) - $\(Int(account.balance).formattedWithSeparator())")
                                .tag(account.id as UUID?)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                Section(header: Text("Amount")) {
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                    
                    if let fromId = fromAccountId, let account = bankManager.getAccount(id: fromId) {
                        Text("Available: $\(Int(account.balance).formattedWithSeparator())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(action: {
                        transferFunds()
                    }) {
                        Text("Transfer Funds")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(fromAccountId == nil || toAccountId == nil || amount.isEmpty)
                }
            }
            .navigationTitle("Transfer Money")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    private func transferFunds() {
        guard let fromId = fromAccountId,
              let toId = toAccountId,
              let transferAmount = Double(amount) else { return }
        
        if bankManager.transfer(fromAccountId: fromId, toAccountId: toId, amount: transferAmount) {
            isPresented = false
        }
    }
}

struct LoanApplicationView: View {
    @ObservedObject var bankManager: BankManager
    let currentYear: Int
    @Binding var isPresented: Bool
    @State private var loanType: BankAccountType = .loan
    @State private var loanAmount: String = ""
    @State private var term: Int = 5
    @State private var selectedCollateralId: UUID? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Loan Type")) {
                    Picker("Select Loan Type", selection: $loanType) {
                        Text("Personal Loan").tag(BankAccountType.loan)
                        Text("Student Loan").tag(BankAccountType.studentLoan)
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Text(loanType.description())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Loan Details")) {
                    TextField("Amount", text: $loanAmount)
                        .keyboardType(.decimalPad)
                    
                    Text("Maximum: $\(Int(bankManager.maximumLoanAmount(loanType: loanType)).formattedWithSeparator())")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Stepper("\(term) \(term == 1 ? "Year" : "Years")", value: $term, in: 1...30)
                    
                    Text("Estimated Interest Rate: \(loanType.defaultInterestRate() * 100, specifier: "%.2f")%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Collateral selection for secured loans
                if loanType == .loan && !bankManager.getAvailableCollateral().isEmpty {
                    Section(header: Text("Collateral (Optional)")) {
                        Picker("Select Collateral", selection: $selectedCollateralId) {
                            Text("None").tag(nil as UUID?)
                            ForEach(bankManager.getAvailableCollateral()) { collateral in
                                Text("\(collateral.description) - $\(Int(collateral.currentValue(currentYear: currentYear)).formattedWithSeparator())")
                                    .tag(collateral.id as UUID?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
                
                Section {
                    Button(action: {
                        applyForLoan()
                    }) {
                        Text("Apply for Loan")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Loan Application")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
    
    private func applyForLoan() {
        guard let amount = Double(loanAmount) else { return }
        
        if bankManager.canQualifyForLoan(amount: amount, loanType: loanType) {
            _ = bankManager.openAccount(
                type: loanType,
                initialDeposit: amount,
                currentYear: currentYear,
                term: term,
                collateralId: selectedCollateralId
            )
            isPresented = false
        }
    }
}