//
//  ConvertToRentalView.swift
//  LifeVerse
//
import SwiftUI

struct ConvertToRentalView: View {
    @ObservedObject var bankManager: BankManager
    let currentYear: Int
    @Binding var isPresented: Bool

    @State private var selectedPropertyId: UUID? = nil
    @State private var monthlyRent: String = ""
    @State private var occupancyRate: Double = 0.95
    @State private var errorMessage: String = ""

    private var monthlyRentDouble: Double {
        return Double(monthlyRent) ?? 0
    }

    // Get non-rental properties - break up complex expression to help compiler
    private var availableProperties: [PropertyInvestment] {
        let allProperties = bankManager.getPropertyInvestments()
        return allProperties.filter { property in
            return !property.isRental
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Group {
                    if availableProperties.isEmpty {
                        Section {
                            Text("You don't have any personal properties to convert to rentals.")
                                .foregroundColor(.secondary)
                        }
                    } else {
                        // Property selection section
                        Section(header: Text("Select Property")) {
                            Picker("Property", selection: $selectedPropertyId) {
                                Text("Select a property").tag(nil as UUID?)

                                ForEach(availableProperties) { property in
                                    Text("\(property.name) - $\(Int(property.currentValue).formattedWithSeparator())").tag(property.id as UUID?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }

                        // Only show property details if a property is selected
                        if let selectedPropertyId = selectedPropertyId,
                           let property = bankManager.getPropertyInvestment(id: selectedPropertyId) {
                            propertyDetailsSection(property)
                            mortgageInfoSection(property)
                        }

                        // Error message section
                        if !errorMessage.isEmpty {
                            Section {
                                Text(errorMessage)
                                    .foregroundColor(.red)
                            }
                        }

                        // Button section
                        Section {
                            Button(action: convertToRental) {
                                Text("Convert to Rental Property")
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(canConvert ? Color.blue : Color.gray)
                                    .cornerRadius(10)
                            }
                            .disabled(!canConvert)
                        }
                    }
                }
            }
            .navigationTitle("Convert to Rental")
            .navigationBarItems(trailing: Button("Cancel") {
                isPresented = false
            })
        }
    }

    private var canConvert: Bool {
        return selectedPropertyId != nil && monthlyRentDouble > 0
    }

    private func convertToRental() {
        guard let propertyId = selectedPropertyId, monthlyRentDouble > 0 else {
            errorMessage = "Please select a property and enter a valid monthly rent."
            return
        }

        // Get the property to check rent cap
        guard let property = bankManager.getPropertyInvestment(id: propertyId) else {
            errorMessage = "Property not found."
            return
        }

        // Calculate maximum allowed rent
        let maxRent = min(property.currentValue * 0.008, 10000.0)

        // Check if rent exceeds maximum
        if monthlyRentDouble > maxRent {
            errorMessage = "Monthly rent cannot exceed $\(Int(maxRent).formattedWithSeparator()) for this property."
            return
        }

        let success = bankManager.convertPropertyToRental(propertyId: propertyId, monthlyRent: monthlyRentDouble, occupancyRate: occupancyRate)

        if success {
            isPresented = false
        } else {
            errorMessage = "Failed to convert property to rental. Please try again."
        }
    }

    // Helper method to calculate mortgage payment
    private func calculateMortgagePayment(principal: Double, monthlyInterestRate: Double, numberOfPayments: Int) -> Double {
        // Handle edge cases
        if monthlyInterestRate <= 0 || numberOfPayments <= 0 {
            return principal / Double(numberOfPayments)
        }

        // Formula: P * (r(1+r)^n) / ((1+r)^n - 1)
        let rateFactorNumerator = monthlyInterestRate * pow(1 + monthlyInterestRate, Double(numberOfPayments))
        let rateFactorDenominator = pow(1 + monthlyInterestRate, Double(numberOfPayments)) - 1

        return principal * (rateFactorNumerator / rateFactorDenominator)
    }

    // Extracted function to display property details section
    private func propertyDetailsSection(_ property: PropertyInvestment) -> some View {
        Section(header: Text("Rental Details")) {
            TextField("Monthly Rent", text: $monthlyRent)
                .keyboardType(.decimalPad)

            // Suggested rent (0.6% to 0.8% of property value per month)
            let suggestedRentLow = property.currentValue * 0.006
            let suggestedRentHigh = property.currentValue * 0.008

            // Calculate maximum allowed rent
            let maxRent = min(property.currentValue * 0.008, 10000.0)

            VStack(alignment: .leading, spacing: 4) {
                Text("Suggested rent: $\(Int(suggestedRentLow).formattedWithSeparator()) - $\(Int(suggestedRentHigh).formattedWithSeparator()) per month")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("Maximum allowed rent: $\(Int(maxRent).formattedWithSeparator()) per month")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .bold()
            }

            VStack(alignment: .leading, spacing: 5) {
                Text("Occupancy Rate: \(Int(occupancyRate * 100))%")
                Slider(value: $occupancyRate, in: 0.7...1.0, step: 0.05)
            }

            // Show estimated annual income
            if monthlyRentDouble > 0 {
                estimatedIncomeView(property)
            }
        }
    }

    // Extracted view for estimated income
    private func estimatedIncomeView(_ property: PropertyInvestment) -> some View {
        // Calculate annual rental income
        let annualGrossIncome = monthlyRentDouble * 12 * occupancyRate

        // Calculate annual expenses
        let annualPropertyTax = property.currentValue * property.propertyTaxRate
        let maintenanceRate = 0.01 // 1% of property value for maintenance
        let insuranceRate = 0.005 // 0.5% of property value for insurance
        let propertyManagerRate = 0.1 // 10% of rental income for property management
        
        let annualMaintenance = property.currentValue * maintenanceRate
        let annualInsurance = property.currentValue * insuranceRate
        let annualManagementFee = annualGrossIncome * propertyManagerRate

        // Calculate total expenses and net income
        let expenses = annualPropertyTax + annualMaintenance + annualInsurance + annualManagementFee
        let annualNetIncome = annualGrossIncome - expenses

        return VStack(alignment: .leading, spacing: 5) {
            Text("Estimated Annual Income")
                .font(.subheadline)
                .fontWeight(.medium)

            HStack {
                Text("Gross Income:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(Int(annualGrossIncome).formattedWithSeparator())")
            }

            HStack {
                Text("Expenses:")
                    .foregroundColor(.secondary)
                Spacer()
                Text("$\(Int(expenses).formattedWithSeparator())")
                    .foregroundColor(.red)
            }

            HStack {
                Text("Net Income:")
                    .fontWeight(.medium)
                Spacer()
                Text("$\(Int(annualNetIncome).formattedWithSeparator())")
                    .foregroundColor(annualNetIncome > 0 ? .green : .red)
            }
        }
        .padding(.vertical, 5)
    }

    // Extracted function to display mortgage information
    private func mortgageInfoSection(_ property: PropertyInvestment) -> some View {
        Group {
            if let mortgageId = property.mortgageAccountId,
               let mortgage = bankManager.getAccount(id: mortgageId) {

                Section(header: Text("Mortgage Information")) {
                    // Break down calculations into separate variables
                    let principal = abs(mortgage.balance)
                    let monthlyInterestRate = mortgage.interestRate / 12
                    let yearsElapsed = currentYear - mortgage.creationYear
                    let monthsElapsed = yearsElapsed * 12
                    let totalMonths = mortgage.term * 12
                    let remainingMonths = max(1, totalMonths - monthsElapsed)

                    // Calculate mortgage payment
                    let monthlyPayment = calculateMortgagePayment(
                        principal: principal,
                        monthlyInterestRate: monthlyInterestRate,
                        numberOfPayments: Int(remainingMonths)
                    )

                    // Display payment info
                    mortgagePaymentView(monthlyPayment: monthlyPayment)

                    // Cash flow after mortgage
                    if monthlyRentDouble > 0 {
                        mortgageCashFlowView(property, monthlyPayment)
                    }
                }
            }
        }
    }

    // Extracted view for mortgage payment display
    private func mortgagePaymentView(monthlyPayment: Double) -> some View {
        HStack {
            Text("Monthly Mortgage:")
                .foregroundColor(.secondary)
            Spacer()
            Text("$\(Int(monthlyPayment).formattedWithSeparator())")
        }
    }

    // Extracted view for mortgage cash flow
    private func mortgageCashFlowView(_ property: PropertyInvestment, _ monthlyPayment: Double) -> some View {
        // Break down the calculation into simpler steps
        let monthlyRentalIncome = monthlyRentDouble * occupancyRate

        // Calculate monthly expenses
        let annualPropertyTax = property.currentValue * property.propertyTaxRate
        let maintenanceRate = 0.01 // 1% of property value for maintenance
        let insuranceRate = 0.005 // 0.5% of property value for insurance
        let propertyManagerRate = 0.1 // 10% of rental income for property management
        
        let annualMaintenance = property.currentValue * maintenanceRate
        let annualInsurance = property.currentValue * insuranceRate
        let monthlyFixedExpenses = (annualPropertyTax + annualMaintenance + annualInsurance) / 12

        // Management fee based on collected rent
        let monthlyManagementFee = monthlyRentalIncome * propertyManagerRate

        // Calculate final cash flow
        let monthlyCashFlow = monthlyRentalIncome - monthlyFixedExpenses - monthlyManagementFee - monthlyPayment

        return HStack {
            Text("Monthly Cash Flow:")
                .fontWeight(.medium)
            Spacer()
            Text("$\(Int(monthlyCashFlow).formattedWithSeparator())")
                .foregroundColor(monthlyCashFlow > 0 ? .green : .red)
        }
    }
}