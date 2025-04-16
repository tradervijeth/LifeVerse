//
//  ConvertToRentalView.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import SwiftUI

struct ConvertToRentalView: View {
    @ObservedObject var bankManager: BankManager
    @Binding var isPresented: Bool
    
    @State private var selectedPropertyId: UUID? = nil
    @State private var monthlyRent: String = ""
    @State private var occupancyRate: Double = 0.95
    @State private var errorMessage: String = ""
    
    private var monthlyRentDouble: Double {
        return Double(monthlyRent) ?? 0
    }
    
    // Get non-rental properties
    private var availableProperties: [PropertyInvestment] {
        return bankManager.getPropertyInvestments().filter { !$0.isRental }
    }
    
    var body: some View {
        NavigationView {
            Form {
                if availableProperties.isEmpty {
                    Section {
                        Text("You don't have any personal properties to convert to rentals.")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Section(header: Text("Select Property")) {
                        Picker("Property", selection: $selectedPropertyId) {
                            Text("Select a property").tag(nil as UUID?)
                            
                            ForEach(availableProperties) { property in
                                if let collateral = bankManager.collateralAssets.first(where: { $0.id == property.collateralId }) {
                                    Text("\(collateral.description) - $\(Int(property.currentValue).formattedWithSeparator())").tag(property.id as UUID?)
                                }
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    if let selectedPropertyId = selectedPropertyId,
                       let property = bankManager.getPropertyInvestment(id: selectedPropertyId) {
                        
                        Section(header: Text("Rental Details")) {
                            TextField("Monthly Rent", text: $monthlyRent)
                                .keyboardType(.decimalPad)
                            
                            // Suggested rent (0.8% to 1.1% of property value per month)
                            let suggestedRentLow = property.currentValue * 0.008
                            let suggestedRentHigh = property.currentValue * 0.011
                            
                            Text("Suggested rent: $\(Int(suggestedRentLow).formattedWithSeparator()) - $\(Int(suggestedRentHigh).formattedWithSeparator()) per month")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Occupancy Rate: \(Int(occupancyRate * 100))%")
                                Slider(value: $occupancyRate, in: 0.7...1.0, step: 0.05)
                            }
                            
                            // Show estimated annual income
                            if monthlyRentDouble > 0 {
                                let annualGrossIncome = monthlyRentDouble * 12 * occupancyRate
                                let expenses = property.currentValue * (property.propertyTaxRate + property.maintenanceCostRate + property.insuranceCostRate) + (annualGrossIncome * property.propertyManagerFeeRate)
                                let annualNetIncome = annualGrossIncome - expenses
                                
                                VStack(alignment: .leading, spacing: 5) {
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
                        }
                        
                        // Show mortgage information if applicable
                        if let mortgageId = property.mortgageId,
                           let mortgage = bankManager.getAccount(id: mortgageId) {
                            
                            Section(header: Text("Mortgage Information")) {
                                let principal = abs(mortgage.balance)
                                let monthlyInterestRate = mortgage.interestRate / 12
                                let remainingMonths = mortgage.term * 12 - (bankManager.currentYear - mortgage.creationYear) * 12
                                
                                let monthlyPayment = calculateMortgagePayment(
                                    principal: principal,
                                    monthlyInterestRate: monthlyInterestRate,
                                    numberOfPayments: max(1, remainingMonths)
                                )
                                
                                HStack {
                                    Text("Monthly Mortgage:")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(Int(monthlyPayment).formattedWithSeparator())")
                                }
                                
                                // Cash flow after mortgage
                                if monthlyRentDouble > 0 {
                                    let monthlyCashFlow = (monthlyRentDouble * occupancyRate) - 
                                                         (property.currentValue * (property.propertyTaxRate + property.maintenanceCostRate + property.insuranceCostRate) / 12) - 
                                                         (monthlyRentDouble * occupancyRate * property.propertyManagerFeeRate) - 
                                                         monthlyPayment
                                    
                                    HStack {
                                        Text("Monthly Cash Flow:")
                                            .fontWeight(.medium)
                                        Spacer()
                                        Text("$\(Int(monthlyCashFlow).formattedWithSeparator())")
                                            .foregroundColor(monthlyCashFlow > 0 ? .green : .red)
                                    }
                                }
                            }
                        }
                    }
                    
                    if !errorMessage.isEmpty {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }
                    
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
        
        let success = bankManager.convertToRental(propertyId: propertyId, monthlyRent: monthlyRentDouble, occupancyRate: occupancyRate)
        
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
            return principal / numberOfPayments
        }
        
        // Standard mortgage payment formula: P * (r(1+r)^n) / ((1+r)^n - 1)
        let rate = monthlyInterestRate
        let rateFactorNumerator = rate * pow(1 + rate, Double(numberOfPayments))
        let rateFactorDenominator = pow(1 + rate, Double(numberOfPayments)) - 1
        
        return principal * (rateFactorNumerator / rateFactorDenominator)
    }
}