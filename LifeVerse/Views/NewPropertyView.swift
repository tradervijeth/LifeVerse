//
//  NewPropertyView.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//

import SwiftUI

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
                    
                    Toggle("Rental Property", isOn: $isRental)
                    
                    if isRental {
                        TextField("Monthly Rent", text: $monthlyRent)
                            .keyboardType(.decimalPad)
                    }
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button("Create Property") {
                        createProperty()
                    }
                    .disabled(propertyValueDouble <= 0 || downPaymentDouble < minimumDownPayment)
                    
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
            .navigationTitle("New Property")
        }
    }
    
    private func createProperty() {
        // Validate inputs
        guard propertyValueDouble > 0 else {
            errorMessage = "Please enter a valid property value"
            return
        }
        
        guard downPaymentDouble >= minimumDownPayment else {
            errorMessage = "Down payment must be at least $\(Int(minimumDownPayment))"
            return
        }
        
        if isRental && monthlyRentDouble <= 0 {
            errorMessage = "Please enter a valid monthly rent amount"
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
            isPresented = false
        } else {
            errorMessage = "Failed to create property investment"
        }
    }
}
