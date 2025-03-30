//
//  PropertyInvestmentView.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import SwiftUI

struct PropertyInvestmentView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showNewPropertySheet: Bool = false
    @State private var showConvertToRentalSheet: Bool = false
    @State private var selectedPropertyId: UUID? = nil
    
    private var bankManager: BankManager {
        return gameManager.bankManager
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.title2)
                    Text("Property Investments")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                if let character = gameManager.character {
                    Text("Build your real estate portfolio")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Property portfolio summary
                HStack(spacing: 15) {
                    VStack(alignment: .leading) {
                        Text("Total Properties")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("\(bankManager.getPropertyInvestments().count)")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Total Equity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(Int(bankManager.calculateTotalPropertyEquity(currentYear: gameManager.currentYear)).formattedWithSeparator())")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Annual Rental Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(Int(bankManager.calculateTotalAnnualNetRentalIncome()).formattedWithSeparator())")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
            }
            .padding()
            
            // Content
            ScrollView {
                VStack(spacing: 15) {
                    if selectedPropertyId == nil {
                        // Show all properties
                        if bankManager.getPropertyInvestments().isEmpty {
                            Text("You don't own any properties yet. Purchase a property to get started.")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        } else {
                            // Rental properties section
                            let rentalProperties = bankManager.getRentalProperties()
                            if !rentalProperties.isEmpty {
                                Text("Rental Properties")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                ForEach(rentalProperties) { property in
                                    PropertyCard(property: property, bankManager: bankManager, currentYear: gameManager.currentYear)
                                        .onTapGesture {
                                            selectedPropertyId = property.id
                                        }
                                }
                            }
                            
                            // Personal properties section
                            let personalProperties = bankManager.getPropertyInvestments().filter { !$0.isRental }
                            if !personalProperties.isEmpty {
                                Text("Personal Properties")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 10)
                                
                                ForEach(personalProperties) { property in
                                    PropertyCard(property: property, bankManager: bankManager, currentYear: gameManager.currentYear)
                                        .onTapGesture {
                                            selectedPropertyId = property.id
                                        }
                                }
                            }
                            
                            // Real estate market overview
                            marketOverviewSection
                        }
                    } else {
                        // Show property detail
                        if let property = bankManager.getPropertyInvestment(id: selectedPropertyId!) {
                            HStack {
                                Button(action: {
                                    selectedPropertyId = nil
                                }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back to Properties")
                                    }
                                    .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                            
                            PropertyDetailView(property: property, bankManager: bankManager, currentYear: gameManager.currentYear)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80) // Space for button
            }
            
            // Footer with action buttons
            HStack(spacing: 20) {
                // Buy Property button
                Button(action: {
                    showNewPropertySheet = true
                }) {
                    VStack {
                        Image(systemName: "house.circle.fill")
                            .font(.system(size: 24))
                        Text("Buy Property")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
                
                Spacer()
                
                // Convert to Rental button (only show if we have a non-rental property)
                if bankManager.getPropertyInvestments().contains(where: { !$0.isRental }) {
                    Button(action: {
                        showConvertToRentalSheet = true
                    }) {
                        VStack {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 24))
                            Text("Convert to Rental")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                // Market Analysis button
                Button(action: {
                    // Could show detailed market analysis here
                }) {
                    VStack {
                        Image(systemName: "chart.line.uptrend.xyaxis.circle.fill")
                            .font(.system(size: 24))
                        Text("Market Analysis")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
        .sheet(isPresented: $showNewPropertySheet) {
            NewPropertyView(bankManager: bankManager, currentYear: gameManager.currentYear, isPresented: $showNewPropertySheet)
        }
        .sheet(isPresented: $showConvertToRentalSheet) {
            ConvertToRentalView(bankManager: bankManager, isPresented: $showConvertToRentalSheet)
        }
    }
    
    // Market overview section
    var marketOverviewSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Real Estate Market Overview")
                .font(.headline)
                .padding(.top, 15)
            
            // Market condition indicator
            HStack {
                Text("Market Condition:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(bankManager.marketCondition.rawValue)
                    .fontWeight(.medium)
                    .foregroundColor(marketConditionColor(bankManager.marketCondition))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(marketConditionColor(bankManager.marketCondition).opacity(0.2))
                    .cornerRadius(4)
            }
            
            // Average appreciation rate
            HStack {
                Text("Average Appreciation Rate:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(appreciationRateText(for: bankManager.marketCondition))
                    .fontWeight(.medium)
                    .foregroundColor(appreciationRateColor(for: bankManager.marketCondition))
            }
            
            // Mortgage rates
            HStack {
                Text("Current Mortgage Rate:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(String(format: "%.2f%%", (BankAccountType.mortgage.defaultInterestRate() + bankManager.marketCondition.interestRateEffect()) * 100))
                    .fontWeight(.medium)
            }
            
            // Rental market
            HStack {
                Text("Rental Market:")
                    .foregroundColor(.secondary)
                Spacer()
                Text(rentalMarketText(for: bankManager.marketCondition))
                    .fontWeight(.medium)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    // Helper functions for market conditions
    func marketConditionColor(_ condition: MarketCondition) -> Color {
        switch condition {
        case .recession, .depression: return .red
        case .recovery: return .yellow
        case .expansion: return .green
        case .boom: return .blue
        }
    }
    
    func appreciationRateText(for condition: MarketCondition) -> String {
        switch condition {
        case .recession: return "-5% per year"
        case .depression: return "-10% per year"
        case .recovery: return "2% per year"
        case .expansion: return "4% per year"
        case .boom: return "8% per year"
        }
    }
    
    func appreciationRateColor(for condition: MarketCondition) -> Color {
        switch condition {
        case .recession, .depression: return .red
        case .recovery, .expansion, .boom: return .green
        }
    }
    
    func rentalMarketText(for condition: MarketCondition) -> String {
        switch condition {
        case .recession: return "High Vacancy"
        case .depression: return "Very High Vacancy"
        case .recovery: return "Moderate Demand"
        case .expansion: return "Strong Demand"
        case .boom: return "Very Strong Demand"
        }
    }
}

// Property card component
struct PropertyCard: View {
    let property: PropertyInvestment
    let bankManager: BankManager
    let currentYear: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Property type and status
            HStack {
                Image(systemName: property.isRental ? "house.circle.fill" : "house.circle")
                    .foregroundColor(property.isRental ? .green : .blue)
                
                Text(property.isRental ? "Rental Property" : "Personal Property")
                    .font(.headline)
                
                Spacer()
                
                // Show mortgage status if applicable
                if let mortgageId = property.mortgageId,
                   let mortgage = bankManager.getAccount(id: mortgageId) {
                    Text("Mortgaged")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                } else {
                    Text("Owned")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }
            
            Divider()
            
            // Property value and equity
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Value")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("$\(Int(property.currentValue).formattedWithSeparator())")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Equity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Calculate equity
                    let mortgageBalance = property.mortgageId.flatMap { mortgageId in
                        bankManager.getAccount(id: mortgageId)?.balance
                    } ?? 0
                    
                    let equity = property.currentValue - abs(mortgageBalance)
                    
                    Text("$\(Int(equity).formattedWithSeparator())")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            
            // Show rental income if it's a rental property
            if property.isRental {
                Divider()
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Monthly Rent")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(Int(property.monthlyRent).formattedWithSeparator())")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Annual Net Income")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(Int(property.calculateAnnualNetRentalIncome()).formattedWithSeparator())")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                }
            }
            
            // Purchase info
            HStack {
                Text("Purchased \(currentYear - property.purchaseYear) years ago for $\(Int(property.purchasePrice).formattedWithSeparator())")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// Property detail view
struct PropertyDetailView: View {
    let property: PropertyInvestment
    let bankManager: BankManager
    let currentYear: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Property header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.isRental ? "Investment Property" : "Personal Property")
                        .font(.headline)
                    
                    if let collateral = bankManager.collateralAssets.first(where: { $0.id == property.collateralId }) {
                        Text(collateral.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Property age
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Owned for")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("\(currentYear - property.purchaseYear) years")
                        .font(.subheadline)
                }
            }
            
            Divider()
            
            // Property value section
            VStack(alignment: .leading, spacing: 10) {
                Text("Property Value")
                    .font(.headline)
                
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Purchase Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(Int(property.purchasePrice).formattedWithSeparator())")
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Current Value")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("$\(Int(property.currentValue).formattedWithSeparator())")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                // Appreciation/depreciation
                let valueChange = property.currentValue - property.purchasePrice
                let percentChange = (valueChange / property.purchasePrice) * 100
                
                HStack {
                    Text("Total Appreciation:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("$\(Int(valueChange).formattedWithSeparator()) (\(String(format: "%.1f", percentChange))%)")
                        .font(.subheadline)
                        .foregroundColor(valueChange >= 0 ? .green : .red)
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(10)
            
            // Mortgage section if applicable
            if let mortgageId = property.mortgageId,
               let mortgage = bankManager.getAccount(id: mortgageId) {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Mortgage Details")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Original Loan")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            // Original loan amount would be the initial deposit
                            let originalLoan = mortgage.transactions.first?.amount ?? 0
                            Text("$\(Int(originalLoan).formattedWithSeparator())")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Current Balance")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(Int(abs(mortgage.balance)).formattedWithSeparator())")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Interest Rate")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(String(format: "%.2f", mortgage.interestRate * 100))%")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Term")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(mortgage.term) years")
                                .font(.subheadline)
                        }
                    }
                    
                    // Calculate monthly payment
                    let principal = abs(mortgage.balance)
                    let monthlyInterestRate = mortgage.interestRate / 12
                    let remainingMonths = mortgage.term * 12 - (currentYear - mortgage.creationYear) * 12
                    
                    let monthlyPayment = calculateMortgagePayment(
                        principal: principal,
                        monthlyInterestRate: monthlyInterestRate,
                        numberOfPayments: max(1, remainingMonths)
                    )
                    
                    HStack {
                        Text("Monthly Payment:")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("$\(Int(monthlyPayment).formattedWithSeparator())")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    
                    // Loan-to-value ratio
                    let loanToValue = abs(mortgage.balance) / property.currentValue
                    
                    HStack {
                        Text("Loan-to-Value Ratio:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", loanToValue * 100))%")
                            .font(.subheadline)
                            .foregroundColor(loanToValue > 0.8 ? .red : (loanToValue > 0.5 ? .orange : .green))
                    }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
            }
            
            // Rental income section if applicable
            if property.isRental {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rental Income")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly Rent")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("$\(Int(property.monthlyRent).formattedWithSeparator())")
                                .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Occupancy Rate")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(Int(property.occupancyRate * 100))%")
                                .font(.subheadline)
                        }
                    }
                    
                    Divider()
                    
                    // Income breakdown
                    Text("Annual Income Breakdown")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("Gross Rental Income:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("$\(Int(property.calculateAnnualRentalIncome()).formattedWithSeparator())")
                            .font(.subheadline)
                    }
                    
                    HStack {
                        Text("Property Expenses:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("$\(Int(property.calculateAnnualExpenses()).formattedWithSeparator())")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Net Rental Income:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text("$\(Int(property.calculateAnnualNetRentalIncome()).formattedWithSeparator())")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    
                    // Investment metrics
                    Divider()
                    
                    Text("Investment Metrics")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // Calculate down payment (initial investment)
                    let downPayment = property.mortgageId.flatMap { mortgageId -> Double in
                        if let mortgage = bankManager.getAccount(id: mortgageId) {
                            // Original loan amount would be the initial deposit
                            let originalLoan = mortgage.transactions.first?.amount ?? 0
                            return property.purchasePrice - originalLoan
                        }
                        return property.purchasePrice
                    } ?? property.purchasePrice
                    
                    // Cap rate
                    let capRate = property.calculateCapRate() * 100
                    
                    HStack {
                        Text("Cap Rate:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.2f", capRate))%")
                            .font(.subheadline)
                            .foregroundColor(capRate > 8 ? .green : (capRate > 5 ? .orange : .red))
                    }
                    
                    // Cash-on-cash return
                    let cashOnCash = property.calculateCashOnCashReturn(initialInvestment: downPayment) * 100
                    
                    HStack {
                        Text("Cash-on-Cash Return:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.2f", cashOnCash))%")
                            .font(.subheadline)
                            .foregroundColor(cashOnCash > 10 ? .green : (cashOnCash > 6 ? .orange : .red))
                    }
                    
                    // ROI
                    let roi = property.calculateROI(initialInvestment: downPayment, currentYear: currentYear) * 100
                    
                    HStack {
                        Text("Total ROI:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.2f", roi))%")
                            .font(.subheadline)
                            .foregroundColor(roi > 50 ? .green : (roi > 20 ? .orange : .red))
                    }
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
            }
        }
    }
    
    // Helper method to calculate mortgage payment
    private func calculateMortgagePayment(principal: Double, monthlyInterestRate: Double, numberOfPayments: Int) -> Double {
        // Handle edge cases
        if monthlyInterestRate <= 0 || numberOfPayments <= 0 {
            return principal / numberOfPayments
        }
        
        // Standard mortgage payment formula: P * (r(1+r)^n) / ((1+r)^n - 1)
        let rate = monthlyInterestRate
        let rateFactorNumerator = rate * pow(1 + rate, Double(numberOfPayments))
        let rateFactorDenominator = pow(1 + rate, Double(numberOfPayments)) - 1
        
        return principal * (rateFactorNumerator / rateFactorDenominator)
    }
}

// New property view
struct NewPropertyView: View {
    @ObservedObject var bankManager: BankManager
    let currentYear: Int
    @Binding var isPresented: Bool
    
    @State private var propertyValue: String = ""
    @State private var downPayment: String = ""
    @State private var isRental: Bool = false
    @State private var monthlyRent: String = ""
    @State private var term: Int = 30
    @State private var errorMessage: String = ""
    
    private var propertyValueDouble: Double {
        return Double(propertyValue) ?? 0
    }
    
    private var downPaymentDouble: Double {
        return Double(downPayment) ?? 0
    }
    
    private var monthlyRentDouble: Double {
        return Double(monthlyRent) ?? 0
    }
    
    private var minimumDownPayment: Double {
        return propertyValueDouble * (isRental ? 0.2 : 0.05)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Property Value", text: $propertyValue)
                        .keyboardType(.decimalPad)
                    
                    TextField("Down Payment", text: $downPayment)
                        .keyboardType(.decimalPad)
                    
                    if downPaymentDouble < minimumDownPayment && !downPayment.isEmpty {
                        Text("Minimum down payment: $\(Int(minimumDownPayment))")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Picker("Mortgage Term", selection: $term) {
                        Text("15 Years").tag(15)
                        Text("20 Years").tag(