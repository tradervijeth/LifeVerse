//
//  PropertyInvestmentView.swift
//  LifeVerse
//
import SwiftUI
import Foundation

// Note: The ViewMarketCondition enum is now defined in Models/ViewMarketCondition.swift

// MARK: - Helper Extensions for accessing BankManager
extension PropertyInvestmentView {
    // Helper functions to access BankManager methods
    private func calculateTotalPropertyValue() -> Double {
        return bankManager.calculateTotalPropertyValue()
    }

    // Helper to calculate total annual net rental income
    private func calculateTotalAnnualNetRentalIncome() -> Double {
        // Use the proper method name that exists in PropertyInvestment
        return bankManager.getRentalProperties().reduce(0) { $0 + $1.calculateNetAnnualIncome() }
    }

    // Helper to get a specific property by ID
    private func getPropertyInvestment(id: UUID) -> PropertyInvestment? {
        return bankManager.getPropertyInvestment(id: id)
    }

    // Helper to get rental properties
    private func getRentalProperties() -> [PropertyInvestment] {
        return bankManager.getRentalProperties()
    }


}

struct PropertyInvestmentView: View {
    // Helper method to convert Banking market condition to View market condition
    private func convertToViewMarketCondition(_ bankingCondition: Banking_MarketCondition) -> ViewMarketCondition {
        return bankingCondition.toViewMarketCondition()
    }

    // Helper to get current market condition
    private var currentCondition: ViewMarketCondition {
        return bankManager.getCurrentMarketCondition().toViewMarketCondition()
    }
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
            Text("Convert to Rental View") // Placeholder until you implement this view
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

                            if let mortgageId = property.mortgageAccountId,
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
                        PropertyCard(
                            property: property,
                            bankManager: bankManager,
                            currentYear: gameManager.currentYear
                        )
                        .onTapGesture {
                            selectedPropertyId = property.id
                        }
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
                        PropertyCard(
                            property: property,
                            bankManager: bankManager,
                            currentYear: gameManager.currentYear
                        )
                        .onTapGesture {
                            selectedPropertyId = property.id
                        }
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
                        ForEach(ViewMarketCondition.allCases, id: \.self) { condition in
                            Rectangle()
                                .frame(height: 8)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(marketConditionColor(condition))
                                .opacity(convertToViewMarketCondition(bankManager.getCurrentMarketCondition()) == condition ? 1.0 : 0.4)
                        }
                    }
                    .cornerRadius(4)

                    HStack {
                        let currentCondition = convertToViewMarketCondition(bankManager.getCurrentMarketCondition())
                        Text("Current: \(currentCondition.rawValue)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(marketConditionColor(currentCondition))

                        Spacer()

                        Text(marketConditionDescription(currentCondition))
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
                            value: appreciationRateText(for: currentCondition),
                            color: appreciationRateColor(for: currentCondition)
                        )

                        Divider()

                        marketMetricRow(
                            title: "Current Mortgage Rate",
                            value: "\(String(format: "%.2f", (Banking_AccountType.mortgage.defaultInterestRate() + bankManager.getCurrentMarketCondition().interestRateEffect()) * 100))%",
                            color: .primary
                        )

                        Divider()

                        marketMetricRow(
                            title: "Rental Market",
                            value: rentalMarketText(for: currentCondition),
                            color: rentalMarketColor(for: currentCondition)
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
        let currentMarketCondition = convertToViewMarketCondition(bankManager.getCurrentMarketCondition())

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

    // Analytics view
    var analyticsView: some View {
        Text("Analytics View Coming Soon")
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

    // MARK: - Helper methods for market conditions

    // Helper function for market condition color
    func marketConditionColor(_ condition: ViewMarketCondition) -> Color {
        switch condition {
        case .depression: return .red
        case .recession: return .orange
        case .recovery: return .yellow
        case .normal: return .green
        case .expansion: return .blue
        case .boom: return .purple
        }
    }

    // Helper for appreciation rate text
    func appreciationRateText(for condition: ViewMarketCondition) -> String {
        switch condition {
        case .depression: return "-10.0%"
        case .recession: return "-5.0%"
        case .recovery: return "+2.0%"
        case .normal: return "+3.0%"
        case .expansion: return "+4.0%"
        case .boom: return "+8.0%"
        }
    }

    // Helper for appreciation rate color
    func appreciationRateColor(for condition: ViewMarketCondition) -> Color {
        switch condition {
        case .depression, .recession: return .red
        case .recovery: return .yellow
        case .normal, .expansion, .boom: return .green
        }
    }

    // Helper for rental market text
    func rentalMarketText(for condition: ViewMarketCondition) -> String {
        switch condition {
        case .depression: return "High Vacancy"
        case .recession: return "Soft Demand"
        case .recovery: return "Improving"
        case .normal: return "Stable"
        case .expansion: return "Strong Demand"
        case .boom: return "Low Vacancy"
        }
    }

    // Helper for rental market color
    func rentalMarketColor(for condition: ViewMarketCondition) -> Color {
        switch condition {
        case .depression, .recession: return .red
        case .recovery: return .yellow
        case .normal, .expansion, .boom: return .green
        }
    }

    // Helper for market condition description
    func marketConditionDescription(_ condition: ViewMarketCondition) -> String {
        switch condition {
        case .recession: return "Declining values, higher inventory"
        case .depression: return "Significant value drops, difficult financing"
        case .recovery: return "Stabilizing values, improving sales"
        case .expansion: return "Rising values, strong demand"
        case .boom: return "Rapid appreciation, competitive market"
        case .normal: return "Balanced market conditions"
        }
    }
}

// Simple PropertyCard implementation
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
                if let mortgageId = property.mortgageAccountId,
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
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }

    // Calculate equity for the property
    private func calculateEquity() -> Double {
        let mortgageDebt: Double

        if let mortgageId = property.mortgageAccountId,
           let mortgage = bankManager.getAccount(id: mortgageId) {
            mortgageDebt = abs(mortgage.balance)
        } else {
            mortgageDebt = 0.0
        }

        return property.currentValue - mortgageDebt
    }
}

// Simple PropertyDetailView
struct PropertyDetailView: View {
    let property: PropertyInvestment
    let bankManager: BankManager
    let currentYear: Int
    @Binding var isPresented: Bool

    // Add init with optional binding
    init(property: PropertyInvestment, bankManager: BankManager, currentYear: Int, isPresented: Binding<Bool>? = nil) {
        self.property = property
        self.bankManager = bankManager
        self.currentYear = currentYear
        self._isPresented = isPresented ?? .constant(false)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Property Details")
                .font(.headline)

            VStack(alignment: .leading) {
                Text("Value: $\(Int(property.currentValue).formattedWithSeparator())")
                Text("Purchased: \(property.purchaseYear)")
                if property.isRental {
                    Text("Monthly Rent: $\(Int(property.monthlyRent).formattedWithSeparator())")
                }
            }
        }
        .padding()
    }
}

// Simple NewPropertyView
struct NewPropertyView: View {
    @ObservedObject var bankManager: BankManager
    let currentYear: Int
    @Binding var isPresented: Bool

    @State private var propertyValue: String = ""
    @State private var downPayment: String = ""
    @State private var isRental: Bool = false
    @State private var monthlyRent: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Property Details")) {
                    TextField("Property Value", text: $propertyValue)
                        .keyboardType(.decimalPad)
                    TextField("Down Payment", text: $downPayment)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Rental Property")) {
                    Toggle("Set as Rental Property", isOn: $isRental)
                    if isRental {
                        TextField("Monthly Rent", text: $monthlyRent)
                            .keyboardType(.decimalPad)
                    }
                }

                Section {
                    Button("Purchase Property") {
                        // This would actually create the property in a real implementation
                        isPresented = false
                    }
                }
            }
            .navigationTitle("Buy Property")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }
}

// Extension for BankAccount to get initial loan amount
extension BankAccount {
    func initialLoanAmount() -> Double {
        if let firstTransaction = transactions.first {
            return firstTransaction.amount
        }
        return abs(balance)
    }
}
