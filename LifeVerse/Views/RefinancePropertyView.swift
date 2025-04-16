//
//  RefinancePropertyView.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import SwiftUI

struct RefinancePropertyView: View {
    @ObservedObject var bankManager: BankManager
    let property: PropertyInvestment
    let currentYear: Int
    @Binding var isPresented: Bool

    @State private var newTerm: Int = 30
    @State private var cashOutAmount: String = "0"
    @State private var errorMessage: String = ""
    @State private var successMessage: String = ""
    @State private var showingNegativeEquityWarning: Bool = false

    private var cashOutDouble: Double {
        return Double(cashOutAmount) ?? 0
    }

    private var maxCashOut: Double {
        return bankManager.calculateMaxCashOut(propertyId: property.id)
    }

    private var currentMortgage: BankAccount? {
        guard let mortgageId = property.mortgageId else { return nil }
        return bankManager.getAccount(id: mortgageId)
    }

    private var currentLTV: Double? {
        return bankManager.calculatePropertyLTV(propertyId: property.id)
    }

    private var isInNegativeEquity: Bool {
        return bankManager.isPropertyInNegativeEquity(propertyId: property.id)
    }

    private var eligibility: (eligible: Bool, reason: String) {
        return bankManager.canRefinanceProperty(propertyId: property.id)
    }

    var body: some View {
        NavigationView {
            Form {
                // Property information section
                Section(header: Text("Property Information")) {
                    HStack {
                        Text("Current Value")
                        Spacer()
                        Text("$\(Int(property.currentValue).formattedWithSeparator())")
                            .fontWeight(.semibold)
                    }

                    if let mortgage = currentMortgage {
                        HStack {
                            Text("Current Mortgage Balance")
                            Spacer()
                            Text("$\(Int(abs(mortgage.balance)).formattedWithSeparator())")
                                .fontWeight(.semibold)
                        }

                        HStack {
                            Text("Current Interest Rate")
                            Spacer()
                            Text("\(String(format: "%.2f", mortgage.interestRate * 100))%")
                                .fontWeight(.semibold)
                        }
                    }

                    if let ltv = currentLTV {
                        HStack {
                            Text("Loan-to-Value Ratio")
                            Spacer()
                            Text("\(String(format: "%.1f", ltv * 100))%")
                                .fontWeight(.semibold)
                                .foregroundColor(ltvColor(ltv))
                        }
                    }
                }

                // Negative equity warning
                if isInNegativeEquity {
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚠️ Negative Equity Alert")
                                .font(.headline)
                                .foregroundColor(.red)

                            Text("This property is underwater - the mortgage balance exceeds the property value. Refinancing is not possible, and there may be serious financial consequences.")
                                .font(.subheadline)

                            Button("View Consequences") {
                                showingNegativeEquityWarning = true
                            }
                            .foregroundColor(.red)
                            .padding(.top, 4)
                        }
                    }
                    .listRowBackground(Color.red.opacity(0.1))
                }

                // Refinance options section (only if eligible)
                if eligibility.eligible && !isInNegativeEquity {
                    Section(header: Text("Refinance Options")) {
                        // New loan term picker
                        Picker("New Loan Term", selection: $newTerm) {
                            Text("15 Years").tag(15)
                            Text("20 Years").tag(20)
                            Text("30 Years").tag(30)
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        // Cash-out amount
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Cash-Out Amount")

                            TextField("$0", text: $cashOutAmount)
                                .keyboardType(.decimalPad)

                            Text("Maximum available: $\(Int(maxCashOut).formattedWithSeparator())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        if cashOutDouble > maxCashOut {
                            Text("Cash-out amount exceeds maximum available")
                                .font(.caption)
                                .foregroundColor(.red)
                        }

                        // New payment estimate
                        if let mortgage = currentMortgage {
                            let newBalance = abs(mortgage.balance) + cashOutDouble
                            let newRate = BankAccountType.mortgage.defaultInterestRate() +
                                          bankManager.marketCondition.interestRateEffect() +
                                          (property.isRental ? 0.005 : 0.0)

                            let monthlyPayment = calculateMortgagePayment(
                                principal: newBalance,
                                monthlyInterestRate: newRate / 12,
                                numberOfPayments: newTerm * 12
                            )

                            VStack(alignment: .leading, spacing: 4) {
                                Text("Estimated New Payment")
                                Text("$\(Int(monthlyPayment).formattedWithSeparator()) per month")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                } else if !isInNegativeEquity {
                    // Show why refinancing is not available
                    Section {
                        Text(eligibility.reason)
                            .foregroundColor(.orange)
                    }
                }

                // Error/success messages
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }

                if !successMessage.isEmpty {
                    Section {
                        Text(successMessage)
                            .foregroundColor(.green)
                    }
                }
            }
            .navigationTitle("Refinance Property")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refinance") {
                        refinanceProperty()
                    }
                    .disabled(!eligibility.eligible || isInNegativeEquity || cashOutDouble > maxCashOut)
                }
            }
            .alert(isPresented: $showingNegativeEquityWarning) {
                let consequences = bankManager.handleUnderwaterMortgage(propertyId: property.id, currentYear: currentYear)

                return Alert(
                    title: Text("Negative Equity Consequences"),
                    message: Text(consequences.joined(separator: "\n\n")),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // Refinance the property
    private func refinanceProperty() {
        // Validate inputs
        if cashOutDouble > maxCashOut {
            errorMessage = "Cash-out amount exceeds maximum available"
            return
        }

        // Attempt to refinance
        let result = bankManager.refinanceProperty(
            propertyId: property.id,
            newTerm: newTerm,
            cashOut: cashOutDouble,
            currentYear: currentYear
        )

        if result.success {
            successMessage = "Successfully refinanced property"
            errorMessage = ""

            // Close the sheet after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isPresented = false
            }
        } else {
            errorMessage = result.message
            successMessage = ""
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

    // Helper to determine color based on LTV
    private func ltvColor(_ ltv: Double) -> Color {
        if ltv > 1.0 { return .red }
        if ltv > 0.9 { return .orange }
        if ltv > 0.8 { return .yellow }
        return .green
    }
}