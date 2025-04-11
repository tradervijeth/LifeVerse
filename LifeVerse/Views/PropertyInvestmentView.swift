//
//  PropertyInvestmentView.swift
//  LifeVerse
//
import SwiftUI
import Foundation

// MARK: - Helper Extensions for BankManager
extension BankManager {
    // Add helper methods for property investments
    func calculateTotalPropertyValue() -> Double {
        return getPropertyInvestments().reduce(0) { $0 + $1.currentValue }
    }

    // Add method to calculate total annual net rental income
    func calculateTotalAnnualNetRentalIncome() -> Double {
        return getRentalProperties().reduce(0) { $0 + $1.calculateAnnualNetRentalIncome() }
    }

    // Add method to get a specific property by ID
    func getPropertyInvestment(id: UUID) -> PropertyInvestment? {
        return getPropertyInvestments().first { $0.id == id }
    }

    // Property to access market condition through CentralBank
    var marketCondition: Banking_MarketCondition {
        // Default to normal if we can't determine it
        return .normal
    }
}

struct PropertyInvestmentView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showNewPropertySheet: Bool = false
    @State private var showConvertToRentalSheet: Bool = false
    @State private var selectedPropertyId: UUID? = nil
    @State private var selectedTab: String = "Portfolio"
    @Binding var isPresented: Bool

    private var bankManager: BankManager {
        gameManager.bankManager
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "house.fill")
                        .font(.title2)
                    Text("Real Estate")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    // Add Banking button
                    Button(action: {
                        // Close this view and show financial hub
                        isPresented = false
                        gameManager.showBankingView = true
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "banknote.fill")
                            Text("Banking")
                        }
                        .foregroundColor(.green)
                    }
                    .padding(.trailing, 15)

                    Button(action: {
                        isPresented = false
                    }) {
                        Text("Done")
                            .foregroundColor(.blue)
                    }
                }

                // Portfolio summary cards - visually appealing
                portfolioSummaryView
            }
            .padding()

            // Tab bar
            tabBarView

            // Content based on selected tab
            ScrollView {
                VStack(spacing: 15) {
                    switch selectedTab {
                    case "Portfolio":
                        if selectedPropertyId == nil {
                            portfolioView
                        } else {
                            propertyDetailContentView
                        }
                    case "Market":
                        marketView
                    case "Analytics":
                        analyticsView
                    default:
                        portfolioView
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80) // Space for floating action button
            }

            // Floating action button for primary action
            floatingActionButton
        }
        .sheet(isPresented: $showNewPropertySheet) {
            NewPropertyView(bankManager: bankManager, currentYear: gameManager.currentYear, isPresented: $showNewPropertySheet)
        }
        .sheet(isPresented: $showConvertToRentalSheet) {
            ConvertToRentalView(bankManager: bankManager, currentYear: gameManager.currentYear, isPresented: $showConvertToRentalSheet)
        }
    }

    // Portfolio summary with visual cards
    var portfolioSummaryView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                // Total Value Card
                summaryCard(
                    title: "Portfolio Value",
                    value: "$\(Int(bankManager.calculateTotalPropertyValue()).formattedWithSeparator())",
                    icon: "house.circle.fill",
                    color: .blue
                )

                // Total Equity Card
                summaryCard(
                    title: "Total Equity",
                    value: {
                        let totalEquity = bankManager.calculateTotalPropertyEquity(currentYear: gameManager.currentYear)
                        // Debug print to verify equity is calculated correctly
                        print("DEBUG: Displaying total equity: \(totalEquity)")

                        // Double check the equity calculation
                        let properties = bankManager.getPropertyInvestments()
                        let manualEquity = properties.reduce(0.0) { total, property in
                            let propertyValue = property.currentValue
                            var mortgageDebt = 0.0

                            if let mortgageId = property.mortgageId,
                               let mortgage = bankManager.getAccount(id: mortgageId) {
                                mortgageDebt = abs(mortgage.balance)
                            }

                            return total + (propertyValue - mortgageDebt)
                        }

                        print("DEBUG: Manual equity calculation: \(manualEquity)")
                        return "$\(Int(totalEquity).formattedWithSeparator())"
                    }(),
                    icon: "chart.pie.fill",
                    color: .green
                )

                // Rental Income Card
                summaryCard(
                    title: "Annual Income",
                    value: "$\(Int(bankManager.calculateTotalAnnualNetRentalIncome()).formattedWithSeparator())",
                    icon: "dollarsign.circle.fill",
                    color: .orange
                )

                // Property Count Card
                summaryCard(
                    title: "Properties",
                    value: "\(bankManager.getPropertyInvestments().count)",
                    icon: "building.2.fill",
                    color: .purple
                )
            }
            .padding(.vertical, 8)
        }
    }

    // Helper function to create consistent summary cards
    func summaryCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .frame(width: 150, height: 80)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(15)
    }

    // Tab bar for navigation
    var tabBarView: some View {
        HStack(spacing: 0) {
            ForEach(["Portfolio", "Market", "Analytics"], id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                    if tab != "Portfolio" {
                        selectedPropertyId = nil
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: tab))
                            .font(.system(size: 20))
                        Text(tab)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .foregroundColor(selectedTab == tab ? .blue : .gray)
                    .background(
                        selectedTab == tab ?
                            Color.blue.opacity(0.2) :
                            Color.clear
                    )
                }
            }
        }
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
    }

    // Helper for tab icons
    func tabIcon(for tab: String) -> String {
        switch tab {
        case "Portfolio":
            return "house.fill"
        case "Market":
            return "chart.line.uptrend.xyaxis"
        case "Analytics":
            return "chart.bar.fill"
        default:
            return "house.fill"
        }
    }

    // Portfolio view - shows property cards
    var portfolioView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if bankManager.getPropertyInvestments().isEmpty {
                emptyStateView
            } else {
                // Section titles with categorized properties
                if !bankManager.getRentalProperties().isEmpty {
                    sectionHeader(title: "Rental Properties", icon: "house.circle.fill")

                    ForEach(bankManager.getRentalProperties()) { property in
                        PropertyCardModern(
                            property: property,
                            bankManager: bankManager,
                            currentYear: gameManager.currentYear,
                            onTap: {
                                selectedPropertyId = property.id
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(selectedPropertyId == property.id ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .padding(.bottom, 8)
                    }
                }

                // Personal properties section
                let personalProperties = bankManager.getPropertyInvestments().filter { !$0.isRental }
                if !personalProperties.isEmpty {
                    sectionHeader(title: "Personal Properties", icon: "house.circle")

                    ForEach(personalProperties) { property in
                        PropertyCardModern(
                            property: property,
                            bankManager: bankManager,
                            currentYear: gameManager.currentYear,
                            onTap: {
                                selectedPropertyId = property.id
                            }
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(selectedPropertyId == property.id ? Color.blue : Color.clear, lineWidth: 2)
                        )
                        .padding(.bottom, 8)
                    }
                }
            }
        }
    }

    // Helper for section headers
    func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }

    // Empty state view
    var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "house.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)

            Text("No Properties Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start building your real estate portfolio by purchasing your first property.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)

            Button(action: {
                showNewPropertySheet = true
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Buy Property")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.top)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // Property detail content
    var propertyDetailContentView: some View {
        VStack {
            if let property = bankManager.getPropertyInvestments().first(where: { $0.id == selectedPropertyId }) {
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
                .padding(.bottom, 10)

                PropertyDetailView(property: property, bankManager: bankManager, currentYear: gameManager.currentYear, isPresented: $isPresented)
            }
        }
    }

    // Market view
    var marketView: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionHeader(title: "Market Overview", icon: "chart.line.uptrend.xyaxis")

            // Enhanced market overview with better visuals
            VStack(alignment: .leading, spacing: 20) {
                // Market condition visualization
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current Market Condition")
                        .font(.headline)

                    HStack(spacing: 0) {
                        ForEach(MarketCondition.allCases, id: \.self) { condition in
                            Rectangle()
                                .frame(height: 8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(marketConditionColor(condition))
                                .opacity(bankManager.marketCondition == condition ? 1.0 : 0.4)
                        }
                    }
                    .cornerRadius(4)

                    HStack {
                        Text("Current: \(bankManager.marketCondition.rawValue)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(marketConditionColor(bankManager.marketCondition))

                        Spacer()

                        Text(marketConditionDescription(bankManager.marketCondition))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                // Key metrics
                VStack(alignment: .leading, spacing: 10) {
                    Text("Key Metrics")
                        .font(.headline)

                    Group {
                        marketMetricRow(
                            title: "Average Appreciation Rate",
                            value: appreciationRateText(for: bankManager.marketCondition),
                            color: appreciationRateColor(for: bankManager.marketCondition)
                        )

                        Divider()

                        marketMetricRow(
                            title: "Current Mortgage Rate",
                            value: "\(String(format: "%.2f", (Banking_AccountType.mortgage.defaultInterestRate() + bankManager.marketCondition.interestRateEffect()) * 100))%",
                            color: .primary
                        )

                        Divider()

                        marketMetricRow(
                            title: "Rental Market",
                            value: rentalMarketText(for: bankManager.marketCondition),
                            color: rentalMarketColor(for: bankManager.marketCondition)
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                // Market forecast
                VStack(alignment: .leading, spacing: 10) {
                    Text("Market Forecast")
                        .font(.headline)

                    Text(marketForecast())
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    // Helper for market metric row
    func marketMetricRow(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }

    // Helper for market forecast text
    func marketForecast() -> String {
        let currentMarketCondition = bankManager.marketCondition

        switch currentMarketCondition {
        case .recession:
            return "The market is expected to remain challenging for the near future with potential for stabilization within 1-2 years. Focus on cash flow rather than appreciation."
        case .depression:
            return "Current severe downturn may present buying opportunities for investors with available capital. Recovery could begin within 2-3 years."
        case .recovery:
            return "The market is showing early signs of growth. Property values are expected to gradually increase over the next few years."
        case .expansion:
            return "Strong economic indicators suggest continued property value growth. Consider expanding your portfolio while conditions remain favorable."
        case .boom:
            return "Market is near peak levels. Consider securing fixed-rate financing and focusing on properties with strong cash flow fundamentals."
        case .normal:
            return "The market is balanced with moderate growth expected. Both buyers and sellers have relatively equal negotiating power."
        }
    }

    // Helper for rental market color
    func rentalMarketColor(for condition: MarketCondition) -> Color {
        switch condition {
        case .recession, .depression: return .red
        case .recovery: return .yellow
        case .expansion, .normal: return .green
        case .boom: return .blue
        }
    }

    // Helper for market condition description
    func marketConditionDescription(_ condition: MarketCondition) -> String {
        switch condition {
        case .recession: return "Declining values, higher inventory"
        case .depression: return "Significant value drops, difficult financing"
        case .recovery: return "Stabilizing values, improving sales"
        case .expansion: return "Rising values, strong demand"
        case .boom: return "Rapid appreciation, competitive market"
        case .normal: return "Balanced market conditions"
        }
    }

    // Analytics view
    var analyticsView: some View {
        VStack(alignment: .leading, spacing: 20) {
            if bankManager.getRentalProperties().isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)

                    Text("No Rental Properties")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Purchase a rental property to see performance analytics.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                sectionHeader(title: "Portfolio Performance", icon: "chart.bar.fill")

                // Income breakdown with improved visuals
                VStack(alignment: .leading, spacing: 15) {
                    Text("Annual Income Breakdown")
                        .font(.headline)

                    let rentalProperties = bankManager.getRentalProperties()
                    let grossRentalIncome = rentalProperties.reduce(0) { $0 + $1.calculateAnnualRentalIncome() }
                    let propertyExpenses = rentalProperties.reduce(0) { $0 + $1.calculateAnnualExpenses() }
                    let mortgagePayments = rentalProperties.reduce(0) { total, property in
                        return total + property.calculateAnnualMortgagePayment(bankManager: bankManager, currentYear: gameManager.currentYear)
                    }
                    let netRentalIncome = grossRentalIncome - propertyExpenses - mortgagePayments

                    // Visualize breakdown with bars
                    VStack(spacing: 15) {
                        incomeBreakdownBar(
                            label: "Gross Rental Income",
                            amount: grossRentalIncome,
                            color: .blue,
                            showAmount: true
                        )

                        incomeBreakdownBar(
                            label: "Property Expenses",
                            amount: propertyExpenses,
                            color: .red,
                            showAmount: true,
                            isExpense: true
                        )

                        if mortgagePayments > 0 {
                            incomeBreakdownBar(
                                label: "Mortgage Payments",
                                amount: mortgagePayments,
                                color: .orange,
                                showAmount: true,
                                isExpense: true
                            )
                        }

                        Divider()

                        incomeBreakdownBar(
                            label: "Net Income",
                            amount: netRentalIncome,
                            color: netRentalIncome >= 0 ? .green : .red,
                            showAmount: true,
                            isBold: true
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)

                // Investment metrics with improved visuals
                VStack(alignment: .leading, spacing: 15) {
                    Text("Investment Metrics")
                        .font(.headline)

                    let rentalProperties = bankManager.getRentalProperties()
                    let totalProperties = Double(rentalProperties.count)

                    let capRate = rentalProperties.isEmpty ? 0 :
                        rentalProperties.reduce(0) { $0 + $1.calculateCapRate() } / totalProperties * 100

                    // Calculate total down payment (initial investment)
                    let totalDownPayment = rentalProperties.reduce(0) { total, property in
                        let downPayment = property.mortgageId.flatMap { mortgageId -> Double in
                            if let mortgage = bankManager.getAccount(id: mortgageId) {
                                let originalLoan = mortgage.initialLoanAmount()
                                return property.purchasePrice - originalLoan
                            }
                            return property.purchasePrice
                        } ?? property.purchasePrice
                        return total + downPayment
                    }

                    // Calculate cash on cash return
                    let annualNetIncome = rentalProperties.reduce(0) { total, property in
                        return total + property.calculateAnnualNetRentalIncomeAfterMortgage(bankManager: bankManager, currentYear: gameManager.currentYear)
                    }

                    let cashOnCashReturn = totalDownPayment > 0 ? annualNetIncome / totalDownPayment * 100 : 0

                    // Calculate total ROI
                    let totalEquity = bankManager.calculateTotalPropertyEquity(currentYear: gameManager.currentYear)
                    let totalROI = totalDownPayment > 0 ? ((totalEquity - totalDownPayment) / totalDownPayment) * 100 : 0

                    // Display metrics with gauges
                    HStack(spacing: 15) {
                        metricGauge(
                            title: "Cap Rate",
                            value: capRate,
                            suffix: "%",
                            threshold1: 5,
                            threshold2: 8,
                            color1: .red,
                            color2: .orange,
                            color3: .green
                        )

                        metricGauge(
                            title: "Cash-on-Cash",
                            value: cashOnCashReturn,
                            suffix: "%",
                            threshold1: 5,
                            threshold2: 8,
                            color1: .red,
                            color2: .orange,
                            color3: .green
                        )

                        metricGauge(
                            title: "Total ROI",
                            value: totalROI,
                            suffix: "%",
                            threshold1: 20,
                            threshold2: 50,
                            color1: .red,
                            color2: .orange,
                            color3: .green
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }
        }
    }

    // Helper for income breakdown bars
    func incomeBreakdownBar(label: String, amount: Double, color: Color, showAmount: Bool = false, isExpense: Bool = false, isBold: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .fontWeight(isBold ? .semibold : .regular)
                .foregroundColor(isBold ? .primary : .secondary)

            Spacer()

            if showAmount {
                Text("$\(Int(amount).formattedWithSeparator())")
                    .font(.subheadline)
                    .fontWeight(isBold ? .bold : .semibold)
                    .foregroundColor(color)
            }
        }
    }

    // Helper for metric gauges
    func metricGauge(title: String, value: Double, suffix: String, threshold1: Double, threshold2: Double, color1: Color, color2: Color, color3: Color) -> some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)

            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 10)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: min(1, max(0, value / 100)))
                    .stroke(
                        value < threshold1 ? color1 :
                            (value < threshold2 ? color2 : color3),
                        lineWidth: 10
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 0) {
                    Text("\(Int(value))")
                        .font(.system(size: 20))
                        .fontWeight(.bold)

                    Text(suffix)
                        .font(.caption)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    // Floating action button
    var floatingActionButton: some View {
        VStack {
            Spacer()

            HStack {
                Spacer()

                Button(action: {
                    showNewPropertySheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(.trailing, 20)
                .padding(.bottom, 20)
            }
        }
        .frame(maxHeight: .infinity, alignment: .bottom)
    }
}

// We'll use the PropertyCardModern from ModernUIComponents.swift
// See the modified implementation below to use with our custom property equity calculation

// Make PropertyCard more visually appealing
struct PropertyCard: View {
    let property: PropertyInvestment
    let bankManager: BankManager
    let currentYear: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with property type and status
            HStack {
                Circle()
                    .fill(property.isRental ? Color.green : Color.blue)
                    .frame(width: 12, height: 12)

                Text(property.isRental ? "Rental Property" : "Personal Property")
                    .font(.headline)

                Spacer()

                // Property status badge
                if let mortgageId = property.mortgageId,
                   let _ = bankManager.getAccount(id: mortgageId) {
                    Text("Mortgaged")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .cornerRadius(4)
                } else {
                    Text("Owned")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.2))
                        .foregroundColor(.green)
                        .cornerRadius(4)
                }
            }

            Divider()

            // Property details with visual layout
            HStack(alignment: .top, spacing: 20) {
                // Left column - Value info
                VStack(alignment: .leading, spacing: 8) {
                    // Property value
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Value")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("$\(Int(property.currentValue).formattedWithSeparator())")
                            .font(.headline)
                    }

                    // Purchase info
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Purchased")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("\(currentYear - property.purchaseYear) years ago")
                            .font(.subheadline)
                    }
                }

                Divider()

                // Right column - Financial info
                VStack(alignment: .leading, spacing: 8) {
                    // Equity
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Equity")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("$\(Int(calculateEquity()).formattedWithSeparator())")
                            .font(.headline)
                    }

                    // Show rental income if applicable
                    if property.isRental {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Monthly Rent")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text("$\(Int(property.monthlyRent).formattedWithSeparator())")
                                .font(.subheadline)
                        }
                    }
                }
            }

            // Performance indicator
            if property.isRental {
                Divider()

                HStack(alignment: .center, spacing: 8) {
                    let performance = calculatePerformanceMetric()

                    Circle()
                        .fill(performanceColor(performance))
                        .frame(width: 10, height: 10)

                    Text(performanceText(performance))
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("Details")
                        .font(.caption)
                        .foregroundColor(.blue)

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // Performance calculation for rental properties
    private func calculatePerformanceMetric() -> Double {
        if !property.isRental {
            return 0
        }

        let capRate = property.calculateCapRate() * 100
        let cashFlow = property.calculateAnnualNetRentalIncome()

        if cashFlow <= 0 {
            return 0 // Poor performance
        } else if capRate < 5 {
            return 0.5 // Mediocre performance
        } else if capRate < 8 {
            return 0.75 // Good performance
        } else {
            return 1.0 // Excellent performance
        }
    }

    private func performanceColor(_ value: Double) -> Color {
        if value <= 0 {
            return .red
        } else if value <= 0.5 {
            return .orange
        } else if value <= 0.75 {
            return .yellow
        } else {
            return .green
        }
    }

    private func performanceText(_ value: Double) -> String {
        if value <= 0 {
            return "Poor Performance"
        } else if value <= 0.5 {
            return "Average Performance"
        } else if value <= 0.75 {
            return "Good Performance"
        } else {
            return "Excellent Performance"
        }
    }

    // Calculate equity calculations with improved handling
    private func calculateEquity() -> Double {
        // Enhanced calculation code
        let mortgageDebt: Double
        print("DEBUG: Calculating equity for property: \(property.id)")
        print("DEBUG: Property value: \(property.currentValue)")

        if let mortgageId = property.mortgageId,
           let mortgage = bankManager.getAccount(id: mortgageId) {
            // Found mortgage account
            print("DEBUG: Found mortgage account with balance: \(mortgage.balance)")

            if mortgage.balance < 0 {
                // Normal case: negative balance is debt
                mortgageDebt = abs(mortgage.balance)
                print("DEBUG: Using negative balance as debt: \(mortgageDebt)")
            } else if mortgage.balance > 0 {
                // Special case: mortgage has positive balance (likely an error)
                // For a mortgage, we know it should be negative (the amount you owe)
                print("DEBUG: Unusual positive balance on mortgage account: \(mortgage.balance)")

                // Calculate a more accurate debt amount
                let downPaymentPercent = property.isRental ? 0.2 : 0.05
                let loanAmount = property.purchasePrice * (1.0 - downPaymentPercent)
                mortgageDebt = loanAmount
                print("DEBUG: Using calculated loan amount: \(mortgageDebt)")
            } else {
                // Balance is exactly 0, loan is paid off
                mortgageDebt = 0
                print("DEBUG: Mortgage has zero balance, fully paid off")
            }
        } else if property.mortgageId != nil {
            // Mortgage ID exists but account not found
            let downPaymentPercent = property.isRental ? 0.2 : 0.05
            let estimatedLoanAmount = property.purchasePrice * (1.0 - downPaymentPercent)
            mortgageDebt = estimatedLoanAmount
            print("DEBUG: Mortgage account not found, using estimated amount: \(estimatedLoanAmount)")
        } else {
            // No mortgage on property
            mortgageDebt = 0.0
            print("DEBUG: No mortgage on property")
        }

        let equity = property.currentValue - mortgageDebt
        print("DEBUG: Final equity calculation: \(property.currentValue) - \(mortgageDebt) = \(equity)")
        return equity
    }
}

// Property detail view
struct PropertyDetailView: View {
    let property: PropertyInvestment
    let bankManager: BankManager
    let currentYear: Int
    @State private var showRefinanceSheet: Bool = false
    @State private var showExtraPaymentSheet: Bool = false
    @State private var navigateToBanking: Bool = false
    @Binding var isPresented: Bool

    // Add init with optional binding
    init(property: PropertyInvestment, bankManager: BankManager, currentYear: Int, isPresented: Binding<Bool>? = nil) {
        self.property = property
        self.bankManager = bankManager
        self.currentYear = currentYear
        self._isPresented = isPresented ?? .constant(false)
    }

    // Add the income breakdown view property to PropertyDetailView
    var annualIncomeBreakdown: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Annual Income Breakdown")
                .font(.headline)
                .padding(.top, 5)

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

            // Get mortgage payment if applicable
            let mortgagePayment = property.calculateAnnualMortgagePayment(bankManager: bankManager, currentYear: currentYear)

            if mortgagePayment > 0 {
                HStack {
                    Text("Mortgage Payments:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("$\(Int(mortgagePayment).formattedWithSeparator())")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }

            Divider()

            // Net income after all expenses
            let netIncome = property.calculateAnnualNetRentalIncomeAfterMortgage(bankManager: bankManager, currentYear: currentYear)

            HStack {
                Text("Net Rental Income:")
                    .font(.subheadline)
                Spacer()
                Text("$\(Int(netIncome).formattedWithSeparator())")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(netIncome >= 0 ? .green : .red)
            }
        }
    }

    // Add the investment metrics view property to PropertyDetailView
    var investmentMetrics: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Investment Metrics")
                .font(.headline)
                .padding(.top, 5)

            // Calculate down payment (initial investment)
            let downPayment = property.mortgageId.flatMap { mortgageId -> Double in
                if let mortgage = bankManager.getAccount(id: mortgageId) {
                    let originalLoan = mortgage.initialLoanAmount()
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
            let cashOnCash = property.calculateAnnualNetRentalIncomeAfterMortgage(bankManager: bankManager, currentYear: currentYear) / downPayment * 100

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
            let equity = property.currentValue - (property.mortgageId.flatMap { mortgageId -> Double in
                let mortgage = bankManager.getAccount(id: mortgageId)
                return mortgage?.balance != nil ? abs(mortgage!.balance) : 0
            } ?? 0.0)

            let roi = downPayment > 0 ? ((equity - downPayment) / downPayment) * 100 : 0

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
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Debug information
            Text("DEBUG: PropertyID: \(property.id.uuidString), Value: $\(Int(property.currentValue))")
                .font(.caption)
                .foregroundColor(.red)

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

                    Text("\(String(currentYear - property.purchaseYear)) years")
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

                            Text("\(String(mortgage.term)) years")
                                .font(.subheadline)
                        }
                    }

                    // Calculate monthly payment
                    // Break complex calculations into simpler steps
                    let principal = abs(mortgage.balance)
                    let monthlyInterestRate = mortgage.interestRate / 12

                    // Calculate remaining months for the mortgage
                    let yearsPassed = currentYear - mortgage.creationYear
                    let totalMonths = mortgage.term * 12
                    let remainingMonths = totalMonths - (yearsPassed * 12)
                    let effectiveMonths = max(1, remainingMonths)

                    // Calculate the payment factors separately
                    let baseRate = 1.0 + monthlyInterestRate
                    let powerFactor = pow(baseRate, Double(effectiveMonths))
                    let numerator = monthlyInterestRate * powerFactor
                    let denominator = powerFactor - 1.0

                    // Compute the final monthly payment
                    let monthlyPayment = principal * (numerator / denominator)

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

                    Divider()

                    // Mortgage payment options
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Mortgage Payment Options")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        HStack {
                            Button(action: {
                                // View the mortgage account details in banking section
                                isPresented = false
                                // Ideally we would navigate to banking view filtered for this mortgage
                                // Here we're just closing the current view to allow manual navigation
                            }) {
                                HStack {
                                    Image(systemName: "building.columns.fill")
                                    Text("View in Banking")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }

                            Button(action: {
                                // Make an additional payment
                                showExtraPaymentSheet = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Make Extra Payment")
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.top, 5)

                    // Refinance button
                    Button(action: {
                        showRefinanceSheet = true
                    }) {
                        HStack {
                            Image(systemName: "arrow.2.squarepath")
                            Text("Refinance Mortgage")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding(.top, 8)
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
                    annualIncomeBreakdown

                    // Investment metrics
                    investmentMetrics
                }
                .padding()
                .background(Color(UIColor.tertiarySystemBackground))
                .cornerRadius(10)
            }
        }
        .sheet(isPresented: $showRefinanceSheet) {
            RefinancePropertyView(
                bankManagerRef: bankManager,
                property: property,
                currentYear: currentYear,
                isPresented: $showRefinanceSheet
            )
        }
        .sheet(isPresented: $showExtraPaymentSheet) {
            MortgageExtraPaymentView(
                bankManager: bankManager,
                property: property,
                isPresented: $showExtraPaymentSheet
            )
        }
        .sheet(isPresented: $navigateToBanking, onDismiss: {
            // Close property detail view to allow manual navigation to banking
            isPresented = false
        }) {
            // Show a placeholder view or message - the user will need to navigate manually
            Text("Please go to Banking view to see mortgage details")
                .padding()
        }
    }

    // Helper method to calculate mortgage payment
    private func calculateMortgagePayment(principal: Double, monthlyInterestRate: Double, numberOfPayments: Int) -> Double {
        // Handle edge cases
        if monthlyInterestRate <= 0 || numberOfPayments <= 0 {
            return principal / Double(numberOfPayments)
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
                        Text("20 Years").tag(20)
                        Text("30 Years").tag(30)
                    }
                }

                // Rental property section
                Section(header: Text("Rental Property")) {
                    Toggle("Set as Rental Property", isOn: $isRental)

                    if isRental {
                        TextField("Monthly Rent", text: $monthlyRent)
                            .keyboardType(.decimalPad)

                        // Suggested rent (0.6% to 0.8% of property value per month)
                        if propertyValueDouble > 0 {
                            let suggestedRentLow = propertyValueDouble * 0.006
                            let suggestedRentHigh = propertyValueDouble * 0.008

                            // Calculate maximum allowed rent
                            let maxRent = min(propertyValueDouble * 0.008, 10000.0)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Suggested rent: $\(Int(suggestedRentLow)) - $\(Int(suggestedRentHigh)) per month")
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                Text("Maximum allowed rent: $\(Int(maxRent)) per month")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .bold()
                            }
                        }
                    }
                }

                // Mortgage calculation section
                if propertyValueDouble > 0 && downPaymentDouble > 0 && propertyValueDouble > downPaymentDouble {
                    Section(header: Text("Mortgage Details")) {
                        // Calculate loan amount
                        let loanAmount = propertyValueDouble - downPaymentDouble

                        // Calculate interest rate based on market conditions
                        let baseRate = Banking_AccountType.mortgage.defaultInterestRate()
                        let marketEffect = MarketCondition.normal.interestRateEffect()
                        let interestRate = baseRate + marketEffect

                        HStack {
                            Text("Loan Amount:")
                            Spacer()
                            Text("$\(Int(loanAmount))")
                        }

                        HStack {
                            Text("Interest Rate:")
                            Spacer()
                            Text("\(String(format: "%.2f", interestRate * 100))%")
                        }

                        // Calculate monthly payment
                        let monthlyInterestRate = interestRate / 12
                        let numberOfPayments = term * 12

                        let monthlyPayment = calculateMortgagePayment(
                            principal: loanAmount,
                            monthlyInterestRate: monthlyInterestRate,
                            numberOfPayments: numberOfPayments
                        )

                        HStack {
                            Text("Monthly Payment:")
                            Spacer()
                            Text("$\(Int(monthlyPayment))")
                                .fontWeight(.bold)
                        }
                    }
                }

                // Show any error messages
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                // Purchase button
                Section {
                    Button(action: purchaseProperty) {
                        Text("Purchase Property")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .foregroundColor(.white)
                            .padding()
                            .background(canPurchase ? Color.blue : Color.gray)
                            .cornerRadius(10)
                    }
                    .disabled(!canPurchase)
                }
            }
            .navigationTitle("Buy Property")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }

    private var canPurchase: Bool {
        // Basic validation
        guard propertyValueDouble > 0 && downPaymentDouble >= minimumDownPayment else {
            return false
        }

        // If it's a rental property, ensure monthly rent is specified
        if isRental && monthlyRentDouble <= 0 {
            return false
        }

        return true
    }

    private func purchaseProperty() {
        // Enhanced debug prints to diagnose the issue
        print("DEBUG: Character current money: \(bankManager.getCharacterMoney())")
        print("DEBUG: Attempted down payment: \(downPaymentDouble)")
        print("DEBUG: Property value: \(propertyValueDouble)")
        print("DEBUG: Required minimum down payment: \(minimumDownPayment)")
        print("DEBUG: Is rental property: \(isRental)")
        print("DEBUG: Monthly rent: \(monthlyRentDouble)")
        print("DEBUG: Mortgage term: \(term)")
        print("DEBUG: Current year: \(currentYear)")

        // Validate inputs
        if propertyValueDouble <= 0 {
            errorMessage = "Please enter a valid property value."
            return
        }

        if downPaymentDouble < minimumDownPayment {
            errorMessage = "Down payment must be at least \(isRental ? "20%" : "5%") of property value."
            return
        }

        if isRental {
            if monthlyRentDouble <= 0 {
                errorMessage = "Please enter a valid monthly rent."
                return
            }

            // Calculate maximum allowed rent
            let maxRent = min(propertyValueDouble * 0.008, 10000.0)

            if monthlyRentDouble > maxRent {
                errorMessage = "Monthly rent cannot exceed $\(Int(maxRent)) for this property."
                return
            }
        }

        // Check if character has enough money
        if bankManager.getCharacterMoney() < downPaymentDouble {
            errorMessage = "You don't have enough money for the down payment. You have $\(Int(bankManager.getCharacterMoney()).formattedWithSeparator()) but need $\(Int(downPaymentDouble).formattedWithSeparator())."
            return
        }

        // Create property investment
        let result = bankManager.createPropertyInvestment(
            propertyValue: propertyValueDouble,
            downPayment: downPaymentDouble,
            isRental: isRental,
            monthlyRent: monthlyRentDouble,
            term: term,
            currentYear: currentYear
        )

        if result.property != nil {
            // Property purchase successful

            // Create a notification to update the character's money in GameManager
            NotificationCenter.default.post(
                name: NSNotification.Name("PropertyPurchaseCompleted"),
                object: nil,
                userInfo: [
                    "propertyValue": propertyValueDouble,
                    "downPayment": downPaymentDouble,
                    "isRental": isRental,
                    "year": currentYear
                ]
            )

            print("DEBUG: Property purchase successful. Character money after purchase: \(bankManager.getCharacterMoney())")
            isPresented = false
        } else {
            // More detailed error message
            if bankManager.getCharacterMoney() < downPaymentDouble {
                errorMessage = "Insufficient funds for down payment."
            } else if downPaymentDouble < minimumDownPayment {
                errorMessage = "Down payment is below the minimum required."
            } else {
                errorMessage = "Failed to purchase property. Please check your inputs and try again."
            }

            // Print additional debug info
            print("DEBUG: Property purchase failed. Character money after attempt: \(bankManager.getCharacterMoney())")
        }
    }

    // Helper method to calculate mortgage payment
    private func calculateMortgagePayment(principal: Double, monthlyInterestRate: Double, numberOfPayments: Int) -> Double {
        // Handle edge cases
        if monthlyInterestRate <= 0 || numberOfPayments <= 0 {
            return principal / Double(numberOfPayments)
        }

        // Standard mortgage payment formula: P * (r(1+r)^n) / ((1+r)^n - 1)
        let rate = monthlyInterestRate
        let rateFactorNumerator = rate * pow(1 + rate, Double(numberOfPayments))
        let rateFactorDenominator = pow(1 + rate, Double(numberOfPayments)) - 1

        return principal * (rateFactorNumerator / rateFactorDenominator)
    }
}

// These view definitions are moved to their own files
/*
// Convert to rental view
struct ConvertToRentalView: View {
    @ObservedObject var bankManager: BankManager
    @Binding var isPresented: Bool

    var body: some View {
        // Implementation of the view
    }
}

// Refinance property view
struct RefinancePropertyView: View {
    @ObservedObject var bankManager: BankManager
    let property: PropertyInvestment
    let currentYear: Int
    @Binding var isPresented: Bool

    var body: some View {
        // Implementation of the view
    }
}
*/

// Add the MortgageExtraPaymentView struct
struct MortgageExtraPaymentView: View {
    @ObservedObject var bankManager: BankManager
    let property: PropertyInvestment
    @Binding var isPresented: Bool

    @State private var paymentAmount: String = ""
    @State private var selectedAccount: UUID? = nil
    @State private var errorMessage: String = ""
    @State private var showSuccess: Bool = false

    private var accounts: [BankAccount] {
        return bankManager.accounts.filter { account in
            account.accountType == .checking || account.accountType == .savings
        }
    }

    private var mortgage: BankAccount? {
        guard let mortgageId = property.mortgageId else { return nil }
        return bankManager.getAccount(id: mortgageId)
    }

    private var paymentAmountDouble: Double {
        return Double(paymentAmount) ?? 0
    }

    var body: some View {
        NavigationView {
            Form {
                if let mortgage = mortgage {
                    Section(header: Text("Mortgage Information")) {
                        HStack {
                            Text("Current Balance:")
                            Spacer()
                            Text("$\(Int(abs(mortgage.balance)).formattedWithSeparator())")
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Text("Interest Rate:")
                            Spacer()
                            Text("\(String(format: "%.2f", mortgage.interestRate * 100))%")
                        }
                    }

                    Section(header: Text("Make an Extra Payment")) {
                        TextField("Payment Amount", text: $paymentAmount)
                            .keyboardType(.decimalPad)

                        Picker("Source Account", selection: $selectedAccount) {
                            Text("Select Account").tag(nil as UUID?)

                            ForEach(accounts) { account in
                                let accountText = "\(account.accountType.rawValue) - $\(Int(account.balance).formattedWithSeparator())"
                                Text(accountText)
                                    .tag(account.id as UUID?)
                            }
                        }

                        if let selectedAccountId = selectedAccount {
                            let account = bankManager.getAccount(id: selectedAccountId)
                            if let account = account, paymentAmountDouble > account.balance {
                                Text("Insufficient funds in the selected account.")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                        }
                    }

                    // Benefits information
                    Section(header: Text("Benefits of Extra Payments")) {
                        Text("Extra payments go directly to your principal balance, reducing the total interest paid over the life of the loan and helping you pay off your mortgage sooner.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    // Error messages
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }

                    // Submit button
                    Section {
                        Button(action: makeExtraPayment) {
                            Text("Make Payment")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .foregroundColor(.white)
                                .padding()
                                .background(canMakePayment ? Color.green : Color.gray)
                                .cornerRadius(10)
                        }
                        .disabled(!canMakePayment)
                    }
                } else {
                    Section {
                        Text("No mortgage found for this property.")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Extra Mortgage Payment")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
            .alert(isPresented: $showSuccess) {
                Alert(
                    title: Text("Payment Successful"),
                    message: Text("Your extra payment has been applied to the mortgage principal."),
                    dismissButton: .default(Text("OK")) {
                        isPresented = false
                    }
                )
            }
        }
    }

    private var canMakePayment: Bool {
        guard let selectedAccount = selectedAccount,
              let account = bankManager.getAccount(id: selectedAccount),
              let _ = mortgage else {
            return false
        }

        return paymentAmountDouble > 0 && paymentAmountDouble <= account.balance
    }

    private func makeExtraPayment() {
        guard let selectedAccount = selectedAccount,
              let sourceAccount = bankManager.getAccount(id: selectedAccount),
              let mortgage = mortgage else {
            errorMessage = "Please select a valid account."
            return
        }

        if paymentAmountDouble <= 0 {
            errorMessage = "Please enter a valid payment amount."
            return
        }

        if paymentAmountDouble > sourceAccount.balance {
            errorMessage = "Insufficient funds in the selected account."
            return
        }

        // Transfer money from source account to mortgage account
        let result = bankManager.transfer(
            fromAccountId: sourceAccount.id,
            toAccountId: mortgage.id,
            amount: paymentAmountDouble
        )

        if result {
            showSuccess = true
        } else {
            errorMessage = "Failed to make payment. Please try again."
        }
    }
}

// No need to duplicate these helper functions, they're now in MarketCondition.swift