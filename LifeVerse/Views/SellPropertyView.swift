//
//  SellPropertyView.swift
//  LifeVerse
//

import SwiftUI

struct SellPropertyView: View {
    @ObservedObject var gameManager: GameManager
    let property: PropertyInvestment
    @Binding var isPresented: Bool

    // State variables
    @State private var sellingPrice: String = ""
    @State private var errorMessage: String = ""
    @State private var showConfirmation: Bool = false

    // Computed properties
    private var bankManager: BankManager {
        gameManager.bankManager
    }

    private var currentYear: Int {
        gameManager.currentYear
    }

    private var sellingPriceDouble: Double {
        return Double(sellingPrice) ?? 0
    }

    private var estimatedPriceRange: (min: Double, average: Double, max: Double)? {
        return bankManager.getEstimatedSellingPrice(propertyId: property.id, currentYear: currentYear)
    }

    private var mortgageBalance: Double {
        if let mortgageId = property.mortgageId, let mortgage = bankManager.getAccount(id: mortgageId) {
            return abs(mortgage.balance)
        }
        return 0
    }

    private var equity: Double {
        return property.currentValue - mortgageBalance
    }

    private var canSell: Bool {
        return sellingPriceDouble > 0 && sellingPriceDouble >= mortgageBalance
    }

    private var estimatedProceeds: Double {
        if sellingPriceDouble <= 0 {
            return 0
        }

        var proceeds = sellingPriceDouble

        // Deduct mortgage balance
        proceeds -= mortgageBalance

        // Calculate capital gains tax
        let capitalGain = sellingPriceDouble - property.purchasePrice
        if capitalGain > 0 {
            let holdingYears = currentYear - property.purchaseYear
            let taxRate = holdingYears >= 1 ? 0.15 : 0.25 // 15% for long-term, 25% for short-term
            let capitalGainsTax = capitalGain * taxRate
            proceeds -= capitalGainsTax
        }

        return proceeds
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
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Purchase Price")
                        Spacer()
                        Text("$\(Int(property.purchasePrice).formattedWithSeparator())")
                            .foregroundColor(.secondary)
                    }

                    HStack {
                        Text("Mortgage Balance")
                        Spacer()
                        Text("$\(Int(mortgageBalance).formattedWithSeparator())")
                            .foregroundColor(mortgageBalance > 0 ? .red : .secondary)
                    }

                    HStack {
                        Text("Current Equity")
                        Spacer()
                        Text("$\(Int(equity).formattedWithSeparator())")
                            .foregroundColor(.green)
                    }

                    HStack {
                        Text("Years Owned")
                        Spacer()
                        Text("\(currentYear - property.purchaseYear)")
                            .foregroundColor(.secondary)
                    }
                }

                // Market value estimate section
                if let priceRange = estimatedPriceRange {
                    Section(header: Text("Market Value Estimate")) {
                        HStack {
                            Text("Low")
                            Spacer()
                            Text("$\(Int(priceRange.min).formattedWithSeparator())")
                                .foregroundColor(.orange)
                        }

                        HStack {
                            Text("Average")
                            Spacer()
                            Text("$\(Int(priceRange.average).formattedWithSeparator())")
                                .foregroundColor(.green)
                                .fontWeight(.bold)
                        }

                        HStack {
                            Text("High")
                            Spacer()
                            Text("$\(Int(priceRange.max).formattedWithSeparator())")
                                .foregroundColor(.blue)
                        }
                    }
                }

                // Selling price input section
                Section(header: Text("Selling Price")) {
                    TextField("Enter selling price", text: $sellingPrice)
                        .keyboardType(.numberPad)
                        .onChange(of: sellingPrice) { oldValue, newValue in
                            // Clear error message when user changes the input
                            errorMessage = ""
                        }

                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }

                    if mortgageBalance > 0 {
                        Text("Note: Selling price must cover the mortgage balance of $\(Int(mortgageBalance).formattedWithSeparator())")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                // Estimated proceeds section
                Section(header: Text("Estimated Proceeds")) {
                    if sellingPriceDouble > 0 {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Selling Price")
                                Spacer()
                                Text("$\(Int(sellingPriceDouble).formattedWithSeparator())")
                            }

                            if mortgageBalance > 0 {
                                HStack {
                                    Text("Mortgage Payoff")
                                    Spacer()
                                    Text("-$\(Int(mortgageBalance).formattedWithSeparator())")
                                        .foregroundColor(.red)
                                }
                            }

                            // Calculate capital gains tax
                            let capitalGain = sellingPriceDouble - property.purchasePrice
                            if capitalGain > 0 {
                                let holdingYears = currentYear - property.purchaseYear
                                let taxRate = holdingYears >= 1 ? 0.15 : 0.25
                                let capitalGainsTax = capitalGain * taxRate

                                HStack {
                                    Text("Capital Gains Tax (\(Int(taxRate * 100))%)")
                                    Spacer()
                                    Text("-$\(Int(capitalGainsTax).formattedWithSeparator())")
                                        .foregroundColor(.red)
                                }
                            }

                            Divider()

                            HStack {
                                Text("Net Proceeds")
                                    .fontWeight(.bold)
                                Spacer()
                                Text("$\(Int(estimatedProceeds).formattedWithSeparator())")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                        }
                    } else {
                        Text("Enter a selling price to see estimated proceeds")
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }

                // Sell button
                Section {
                    Button(action: {
                        validateAndConfirm()
                    }) {
                        Text("Sell Property")
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSell ? Color.blue : Color.gray)
                    .cornerRadius(10)
                    .disabled(!canSell)
                }
            }
            .navigationTitle("Sell Property")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
            )
            .alert(isPresented: $showConfirmation) {
                Alert(
                    title: Text("Confirm Sale"),
                    message: Text("Are you sure you want to sell this property for $\(Int(sellingPriceDouble).formattedWithSeparator())? You will receive approximately $\(Int(estimatedProceeds).formattedWithSeparator()) after all costs."),
                    primaryButton: .destructive(Text("Sell")) {
                        sellProperty()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    // Validate input and show confirmation
    private func validateAndConfirm() {
        // Check if selling price is valid
        guard sellingPriceDouble > 0 else {
            errorMessage = "Please enter a valid selling price"
            return
        }

        // Check if selling price covers mortgage
        guard sellingPriceDouble >= mortgageBalance else {
            errorMessage = "Selling price must cover the mortgage balance"
            return
        }

        // Show confirmation dialog
        showConfirmation = true
    }

    // Sell the property
    private func sellProperty() {
        let result = gameManager.sellProperty(propertyId: property.id, sellingPrice: sellingPriceDouble)

        if result.success {
            // Close the view
            isPresented = false
        } else {
            // Show error message
            errorMessage = result.message
        }
    }
}

// Preview provider
struct SellPropertyView_Previews: PreviewProvider {
    static var previews: some View {
        // This is just a placeholder for preview
        SellPropertyView(
            gameManager: GameManager(),
            property: PropertyInvestment(
                name: "Sample Property",
                collateralId: UUID(),
                purchasePrice: 300000,
                purchaseYear: 2020,
                isRental: true,
                monthlyRent: 2000,
                propertyType: .singleFamily,
                location: .suburban
            ),
            isPresented: .constant(true)
        )
    }
}
