//
//  PropertyInvestment.swift
//  LifeVerse
//
import Foundation
import SwiftUI

// Use Banking prefixed types directly rather than through typealias
// This avoids multiple declarations and type ambiguity

/// Property investment implementation
struct PropertyInvestment: Codable, Identifiable, Hashable, Equatable {
    // Hashable and Equatable implementation
    static func == (lhs: PropertyInvestment, rhs: PropertyInvestment) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Coding keys for Codable conformance
    enum CodingKeys: String, CodingKey {
        case id, name, collateralId, purchasePrice, purchaseYear, currentValue, mortgageId, isRental, monthlyRent
        case monthlyExpenses, propertyCondition, propertyType, location, squareFootage, bedrooms, bathrooms
        case lastRenovationYear, occupancyRate, propertyTaxRate, maintenanceCostRate, insuranceCostRate
        case propertyManagerFeeRate, rentalTransactions, insuranceCostAnnual, utilityMonthlyAverage
        case mortgageTerm, mortgageYearsRemaining, equityPercentage, hasActiveMortgage, propertyAge
    }

    var id = UUID()
    var name: String
    var collateralId: UUID // Reference to the LoanCollateral asset
    var purchasePrice: Double
    var currentValue: Double
    var purchaseYear: Int
    var isRental: Bool
    var monthlyRent: Double
    var monthlyExpenses: Double
    var mortgageId: UUID? // Reference to the mortgage account if financed
    var mortgageTerm: Int = 30 // Default mortgage term in years
    var mortgageYearsRemaining: Int = 0 // Remaining years on mortgage
    var equityPercentage: Double = 0.0 // Percentage of equity in the property
    var hasActiveMortgage: Bool = false // Whether mortgage is still active
    var propertyAge: Int = 0 // How many years since purchase
    var propertyCondition: Banking_PropertyCondition = .good
    var propertyType: Banking_PropertyType
    var location: Banking_PropertyLocation
    var squareFootage: Double
    var bedrooms: Int
    var bathrooms: Double
    var lastRenovationYear: Int? = nil
    var renovationHistory: [RenovationProject] = []
    var developmentProjects: [DevelopmentProject] = []
    var maintenanceSchedule: [MaintenanceItem] = []
    var tenantHistory: [Tenant] = []
    var currentTenant: Tenant? = nil
    var isVacant: Bool = true
    var vacancyStartDate: Date? = nil
    var propertyTaxRate: Double = 0.01
    var insuranceCostAnnual: Double = 0
    var utilityMonthlyAverage: Double = 0
    var appreciationRate: Double = 0.03 // Default annual appreciation
    var metadata: [String: Any]? = [:] // Use Any instead of UtilityMetadataValue for metadata

    // Additional properties for business logic
    var occupancyRate: Double = 0.95
    var maintenanceCostRate: Double = 0.01
    var insuranceCostRate: Double = 0.005
    var propertyManagerFeeRate: Double = 0.1
    var rentalTransactions: [RentalTransaction] = []

    // Initialize a new property investment
    init(name: String,
         collateralId: UUID,
         purchasePrice: Double,
         purchaseYear: Int,
         isRental: Bool,
         monthlyRent: Double = 0,
         propertyType: Banking_PropertyType = .singleFamily,
         location: Banking_PropertyLocation = .suburban,
         squareFootage: Double = 1500,
         bedrooms: Int = 3,
         bathrooms: Double = 2,
         mortgageTerm: Int = 30) {

        self.name = name
        self.collateralId = collateralId
        self.purchasePrice = purchasePrice
        self.currentValue = purchasePrice
        self.purchaseYear = purchaseYear
        self.isRental = isRental
        self.monthlyRent = isRental ? monthlyRent : 0
        self.propertyType = propertyType
        self.location = location
        self.squareFootage = squareFootage
        self.bedrooms = bedrooms
        self.bathrooms = bathrooms
        self.mortgageTerm = mortgageTerm
        self.mortgageYearsRemaining = mortgageTerm
        self.propertyAge = 0

        // Calculate default monthly expenses (property tax, insurance, maintenance)
        let annualPropertyTax = purchasePrice * propertyTaxRate
        var annualInsurance: Double

        // Set default insurance based on property type and value
        switch propertyType {
        case .singleFamily:
            annualInsurance = purchasePrice * 0.005 // 0.5% of value
        case .multifamily:
            annualInsurance = purchasePrice * 0.007 // 0.7% of value
        case .condo:
            annualInsurance = purchasePrice * 0.004 // 0.4% of value
        case .commercial:
            annualInsurance = purchasePrice * 0.008 // 0.8% of value
        case .land:
            annualInsurance = purchasePrice * 0.002 // 0.2% of value
        }

        self.insuranceCostAnnual = annualInsurance

        // Set utility costs
        if isRental {
            switch propertyType {
            case .singleFamily:
                utilityMonthlyAverage = 150
            case .multifamily:
                utilityMonthlyAverage = 300
            case .condo:
                utilityMonthlyAverage = 100
            case .commercial:
                utilityMonthlyAverage = 500
            case .land:
                utilityMonthlyAverage = 0
            }
        } else {
            // If owner-occupied, utilities are handled separately
            utilityMonthlyAverage = 0
        }

        // Calculate monthly maintenance reserve (rule of thumb: 1% of property value annually)
        let monthlyMaintenance = purchasePrice * 0.01 / 12

        // Sum up all monthly expenses
        self.monthlyExpenses = (annualPropertyTax / 12) + (annualInsurance / 12) + monthlyMaintenance + utilityMonthlyAverage

        // Create initial maintenance schedule
        self.maintenanceSchedule = PropertyInvestment.createDefaultMaintenanceSchedule(for: propertyType)
    }

    // Create default maintenance schedule based on property type
    static func createDefaultMaintenanceSchedule(for propertyType: Banking_PropertyType) -> [MaintenanceItem] {
        var maintenanceItems: [MaintenanceItem] = []

        // Common maintenance items for all property types
        maintenanceItems.append(
            MaintenanceItem(
                name: "HVAC Inspection",
                description: "Regular inspection and servicing of heating and cooling systems",
                frequency: .biannual,
                estimatedCost: 150.0,
                isRecurring: true,
                priority: .medium
            )
        )

        maintenanceItems.append(
            MaintenanceItem(
                name: "Gutter Cleaning",
                description: "Clear gutters of debris to prevent water damage",
                frequency: .biannual,
                estimatedCost: 150.0,
                isRecurring: true,
                priority: .medium
            )
        )

        maintenanceItems.append(
            MaintenanceItem(
                name: "Landscaping",
                description: "Regular lawn maintenance and landscaping",
                frequency: .monthly,
                estimatedCost: 100.0,
                isRecurring: true,
                priority: .low
            )
        )

        // Property-specific maintenance items
        switch propertyType {
        case .singleFamily:
            maintenanceItems.append(
                MaintenanceItem(
                    name: "Roof Inspection",
                    description: "Check roof for damage and leaks",
                    frequency: .annual,
                    estimatedCost: 200.0,
                    isRecurring: true,
                    priority: .high
                )
            )

            maintenanceItems.append(
                MaintenanceItem(
                    name: "Plumbing Check",
                    description: "Inspect for leaks and ensure proper function",
                    frequency: .annual,
                    estimatedCost: 150.0,
                    isRecurring: true,
                    priority: .medium
                )
            )

        case .multifamily:
            maintenanceItems.append(
                MaintenanceItem(
                    name: "Elevator Maintenance",
                    description: "Regular service of elevators if applicable",
                    frequency: .quarterly,
                    estimatedCost: 500.0,
                    isRecurring: true,
                    priority: .critical
                )
            )

            maintenanceItems.append(
                MaintenanceItem(
                    name: "Common Area Cleaning",
                    description: "Regular cleaning of hallways and shared spaces",
                    frequency: .monthly,
                    estimatedCost: 300.0,
                    isRecurring: true,
                    priority: .medium
                )
            )

        case .condo:
            maintenanceItems.append(
                MaintenanceItem(
                    name: "HOA Inspection",
                    description: "Coordinate with HOA for exterior maintenance",
                    frequency: .annual,
                    estimatedCost: 0.0,
                    isRecurring: true,
                    priority: .low
                )
            )

        case .commercial:
            maintenanceItems.append(
                MaintenanceItem(
                    name: "Fire Safety Inspection",
                    description: "Ensure compliance with fire safety regulations",
                    frequency: .annual,
                    estimatedCost: 400.0,
                    isRecurring: true,
                    priority: .critical
                )
            )

            maintenanceItems.append(
                MaintenanceItem(
                    name: "Security System Check",
                    description: "Test and maintain security systems",
                    frequency: .quarterly,
                    estimatedCost: 300.0,
                    isRecurring: true,
                    priority: .high
                )
            )

        case .land:
            maintenanceItems.append(
                MaintenanceItem(
                    name: "Property Boundary Check",
                    description: "Verify property boundaries and check for encroachments",
                    frequency: .annual,
                    estimatedCost: 200.0,
                    isRecurring: true,
                    priority: .medium
                )
            )
        }

        return maintenanceItems
    }

    // Initialize from decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        collateralId = try container.decode(UUID.self, forKey: .collateralId)
        purchasePrice = try container.decode(Double.self, forKey: .purchasePrice)
        currentValue = try container.decode(Double.self, forKey: .currentValue)
        purchaseYear = try container.decode(Int.self, forKey: .purchaseYear)
        isRental = try container.decode(Bool.self, forKey: .isRental)
        monthlyRent = try container.decode(Double.self, forKey: .monthlyRent)
        occupancyRate = try container.decode(Double.self, forKey: .occupancyRate)
        propertyTaxRate = try container.decode(Double.self, forKey: .propertyTaxRate)
        maintenanceCostRate = try container.decode(Double.self, forKey: .maintenanceCostRate)
        insuranceCostRate = try container.decode(Double.self, forKey: .insuranceCostRate)
        propertyManagerFeeRate = try container.decode(Double.self, forKey: .propertyManagerFeeRate)
        mortgageId = try container.decodeIfPresent(UUID.self, forKey: .mortgageId)
        rentalTransactions = try container.decode([RentalTransaction].self, forKey: .rentalTransactions)

        let locationValue = try container.decode(Banking_PropertyLocation.self, forKey: .location)
        self.location = locationValue

        // Set default values for properties we couldn't decode
        self.name = "Property"
        self.propertyType = .singleFamily
        self.squareFootage = 1500
        self.bedrooms = 3
        self.bathrooms = 2
        self.monthlyExpenses = 0

        // Set default values for mortgage properties
        self.mortgageTerm = 30
        self.mortgageYearsRemaining = 30
        self.equityPercentage = 0.0
        self.hasActiveMortgage = mortgageId != nil
        self.propertyAge = 0
    }

    // Encode to encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(collateralId, forKey: .collateralId)
        try container.encode(purchasePrice, forKey: .purchasePrice)
        try container.encode(currentValue, forKey: .currentValue)
        try container.encode(purchaseYear, forKey: .purchaseYear)
        try container.encode(isRental, forKey: .isRental)
        try container.encode(monthlyRent, forKey: .monthlyRent)
        try container.encode(occupancyRate, forKey: .occupancyRate)
        try container.encode(propertyTaxRate, forKey: .propertyTaxRate)
        try container.encode(maintenanceCostRate, forKey: .maintenanceCostRate)
        try container.encode(insuranceCostRate, forKey: .insuranceCostRate)
        try container.encode(propertyManagerFeeRate, forKey: .propertyManagerFeeRate)
        try container.encodeIfPresent(mortgageId, forKey: .mortgageId)
        try container.encode(rentalTransactions, forKey: .rentalTransactions)
        try container.encode(location, forKey: .location)
        try container.encode(mortgageTerm, forKey: .mortgageTerm)
        try container.encode(mortgageYearsRemaining, forKey: .mortgageYearsRemaining)
        try container.encode(equityPercentage, forKey: .equityPercentage)
        try container.encode(hasActiveMortgage, forKey: .hasActiveMortgage)
        try container.encode(propertyAge, forKey: .propertyAge)
    }

    // Set up as a rental property
    mutating func setupAsRental(monthlyRent: Double, occupancyRate: Double = 0.95) {
        self.isRental = true
        self.monthlyRent = monthlyRent
        self.occupancyRate = occupancyRate
    }

    // Calculate annual rental income (before expenses)
    func calculateAnnualRentalIncome() -> Double {
        // Apply the rent cap to ensure we're not exceeding the maximum allowed rent
        let cappedMonthlyRent = min(monthlyRent, calculateMaximumAllowedRent())
        return cappedMonthlyRent * 12 * occupancyRate
    }

    // Calculate the maximum allowed rent based on property value and type
    // This prevents infinite money exploits
    func calculateMaximumAllowedRent() -> Double {
        // Base maximum is 0.8% of property value per month
        // This is a realistic cap based on real estate investment standards
        var maxRentPercentage: Double = 0.008 // 0.8% of property value

        // Adjust based on property type
        switch propertyType {
        case .singleFamily:
            maxRentPercentage = 0.008 // 0.8% for single family homes
        case .multifamily:
            maxRentPercentage = 0.009 // 0.9% for multi-family properties
        case .condo:
            maxRentPercentage = 0.007 // 0.7% for condos
        case .commercial:
            maxRentPercentage = 0.01  // 1.0% for commercial properties
        case .land:
            maxRentPercentage = 0.005 // 0.5% for land (very low as land typically doesn't generate much rental income)
        }

        // Calculate maximum monthly rent
        let maxRent = currentValue * maxRentPercentage

        // Add an absolute cap to prevent exploits with extremely expensive properties
        let absoluteMaxRent = 10000.0 // $10,000 per month absolute maximum

        return min(maxRent, absoluteMaxRent)
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

    // Calculate annual net rental income (after ALL expenses, including mortgage)
    func calculateAnnualNetRentalIncomeAfterMortgage(bankManager: any BankManagerProtocol, currentYear: Int) -> Double {
        if !isRental {
            return 0
        }

        let netBeforeMortgage = calculateAnnualNetRentalIncome()

        // Get annual mortgage payment
        let annualMortgagePayment = calculateAnnualMortgagePayment(bankManager: bankManager, currentYear: currentYear)

        return netBeforeMortgage - annualMortgagePayment
    }

    // Calculate annual mortgage payment
    func calculateAnnualMortgagePayment(bankManager: any BankManagerProtocol, currentYear: Int) -> Double {
        guard let mortgageId = mortgageId,
              let mortgage = bankManager.getAccount(id: mortgageId) else {
            return 0
        }

        // Calculate monthly payment
        let principal = abs(mortgage.balance)
        let monthlyInterestRate = mortgage.interestRate / 12
        let remainingMonths = mortgage.term * 12 - (currentYear - mortgage.creationYear) * 12

        if remainingMonths <= 0 {
            return 0
        }

        // Standard mortgage payment formula
        let rate = monthlyInterestRate
        let rateFactorNumerator = rate * pow(1 + rate, Double(remainingMonths))
        let rateFactorDenominator = pow(1 + rate, Double(remainingMonths)) - 1

        let monthlyPayment = principal * (rateFactorNumerator / rateFactorDenominator)
        return monthlyPayment * 12
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
    mutating func updateValue(currentYear: Int, marketCondition: Banking_MarketCondition) -> Double {
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
        case .normal:
            appreciationRate = 0.03 // Normal market conditions
        case .boom:
            appreciationRate = 0.08 // Rapid growth during boom
        }

        // Apply appreciation for the current year
        let previousValue = currentValue
        currentValue *= (1.0 + appreciationRate)

        return currentValue - previousValue
    }

    // Additional methods omitted for brevity - see complete file for all methods
}
