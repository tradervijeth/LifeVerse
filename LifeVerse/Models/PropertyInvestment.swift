//
//  PropertyInvestment.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

struct PropertyInvestment: Codable, Identifiable {
    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, collateralId, purchasePrice, purchaseYear, currentValue, mortgageId, isRental, monthlyRent
        case occupancyRate, propertyTaxRate, maintenanceCostRate, insuranceCostRate, propertyManagerFeeRate
        case rentalTransactions, location
    }
    var id = UUID()
    var collateralId: UUID // Reference to the LoanCollateral asset
    var purchasePrice: Double
    var currentValue: Double
    var purchaseYear: Int
    var isRental: Bool = false
    var monthlyRent: Double = 0
    var occupancyRate: Double = 0.95 // Default 95% occupancy
    var propertyTaxRate: Double = 0.01 // Default 1% property tax
    var maintenanceCostRate: Double = 0.01 // Default 1% of property value for maintenance
    var insuranceCostRate: Double = 0.005 // Default 0.5% of property value for insurance
    var propertyManagerFeeRate: Double = 0.1 // Default 10% of rental income for property management
    var mortgageId: UUID? // Reference to the mortgage account if financed
    var rentalTransactions: [RentalTransaction] = []

    // Property location (for tax purposes)
    var location: PropertyLocation = .suburban

    // Initialize a new property investment
    init(collateralId: UUID, purchasePrice: Double, purchaseYear: Int, mortgageId: UUID? = nil, location: PropertyLocation = .suburban) {
        self.collateralId = collateralId
        self.purchasePrice = purchasePrice
        self.currentValue = purchasePrice
        self.purchaseYear = purchaseYear
        self.mortgageId = mortgageId
        self.location = location
    }

    // Set up as a rental property
    mutating func setupAsRental(monthlyRent: Double, occupancyRate: Double = 0.95) {
        self.isRental = true
        self.monthlyRent = monthlyRent
        self.occupancyRate = occupancyRate
    }

    // Calculate annual rental income (before expenses)
    func calculateAnnualRentalIncome() -> Double {
        return monthlyRent * 12 * occupancyRate
    }

    // Calculate annual property expenses
    func calculateAnnualExpenses() -> Double {
        let propertyTax = currentValue * propertyTaxRate
        let maintenance = currentValue * maintenanceCostRate
        let insurance = currentValue * insuranceCostRate
        let managementFee = calculateAnnualRentalIncome() * propertyManagerFeeRate

        return propertyTax + maintenance + insurance + managementFee
    }

    // Calculate annual net rental income (after expenses, before mortgage)
    func calculateAnnualNetRentalIncome() -> Double {
        if !isRental {
            return 0
        }

        return calculateAnnualRentalIncome() - calculateAnnualExpenses()
    }

    // Calculate cash-on-cash return (annual net income / initial investment)
    func calculateCashOnCashReturn(initialInvestment: Double) -> Double {
        if initialInvestment <= 0 {
            return 0
        }

        return calculateAnnualNetRentalIncome() / initialInvestment
    }

    // Calculate cap rate (annual net income / property value)
    func calculateCapRate() -> Double {
        return calculateAnnualNetRentalIncome() / currentValue
    }

    // Update property value based on market conditions and years passed
    mutating func updateValue(currentYear: Int, marketCondition: MarketCondition) {
        // Years owned is used for future enhancements like age-based depreciation
        _ = currentYear - purchaseYear

        // Base appreciation rate (3% per year on average)
        var appreciationRate = 0.03

        // Adjust based on market conditions
        switch marketCondition {
        case .recession:
            appreciationRate = -0.05 // Property values decline in recession
        case .depression:
            appreciationRate = -0.10 // Property values decline more in depression
        case .recovery:
            appreciationRate = 0.02 // Slower growth during recovery
        case .expansion:
            appreciationRate = 0.04 // Faster growth during expansion
        case .boom:
            appreciationRate = 0.08 // Rapid growth during boom
        }

        // Apply appreciation for the current year
        currentValue *= (1.0 + appreciationRate)
    }

    // Process monthly rental income and expenses
    mutating func processMonthlyRental(currentYear: Int) -> RentalTransaction {
        // Skip if not a rental property
        if !isRental {
            return RentalTransaction(year: currentYear, month: 1, income: 0, expenses: 0, netIncome: 0)
        }

        // Calculate monthly figures
        let monthlyIncome = monthlyRent * occupancyRate
        let monthlyExpenses = calculateAnnualExpenses() / 12
        let monthlyNetIncome = monthlyIncome - monthlyExpenses

        // Create transaction record
        let month = (rentalTransactions.count % 12) + 1
        let transaction = RentalTransaction(
            year: currentYear,
            month: month,
            income: monthlyIncome,
            expenses: monthlyExpenses,
            netIncome: monthlyNetIncome
        )

        rentalTransactions.append(transaction)
        return transaction
    }

    // Get total rental income for a specific year
    func getTotalRentalIncome(year: Int) -> Double {
        return rentalTransactions
            .filter { $0.year == year }
            .reduce(0) { $0 + $1.income }
    }

    // Get total rental expenses for a specific year
    func getTotalRentalExpenses(year: Int) -> Double {
        return rentalTransactions
            .filter { $0.year == year }
            .reduce(0) { $0 + $1.expenses }
    }

    // Get total net rental income for a specific year
    func getTotalNetRentalIncome(year: Int) -> Double {
        return rentalTransactions
            .filter { $0.year == year }
            .reduce(0) { $0 + $1.netIncome }
    }

    // Calculate return on investment
    func calculateROI(initialInvestment: Double, currentYear: Int) -> Double {
        if initialInvestment <= 0 {
            return 0
        }

        // Calculate total net income since purchase
        let totalNetIncome = rentalTransactions.reduce(0) { $0 + $1.netIncome }

        // Calculate appreciation
        let appreciation = currentValue - purchasePrice

        // ROI = (Total Net Income + Appreciation) / Initial Investment
        return (totalNetIncome + appreciation) / initialInvestment
    }
}

// Structure to track rental income and expenses
struct RentalTransaction: Codable, Identifiable {
    var id = UUID()
    var year: Int
    var month: Int
    var income: Double
    var expenses: Double
    var netIncome: Double
    var date: Date = Date()

    init(year: Int, month: Int, income: Double, expenses: Double, netIncome: Double) {
        self.year = year
        self.month = month
        self.income = income
        self.expenses = expenses
        self.netIncome = netIncome

        // Create date from year and month
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1
        self.date = Calendar.current.date(from: dateComponents) ?? Date()
    }

    // Format amount as currency string
    func formattedIncome() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: income)) ?? "$\(income)"
    }

    // Format expenses as currency string
    func formattedExpenses() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: expenses)) ?? "$\(expenses)"
    }

    // Format net income as currency string
    func formattedNetIncome() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: netIncome)) ?? "$\(netIncome)"
    }
}