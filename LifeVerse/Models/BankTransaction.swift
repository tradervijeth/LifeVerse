//
//  BankTransaction.swift
//  LifeVerse
//
//  Created by AI Assistant on 18/03/2025.
//
import Foundation

struct BankTransaction: Codable, Identifiable {
    var id = UUID()
    var type: BankTransactionType
    var amount: Double
    var description: String
    var date: Date
    var year: Int
    var processed: Bool = true
    var category: TransactionCategory = .uncategorized
    
    // Initialize a new transaction
    init(type: BankTransactionType, amount: Double, description: String, date: Date, year: Int) {
        self.type = type
        self.amount = amount
        self.description = description
        self.date = date
        self.year = year
        self.category = Self.categorizeTransaction(type: type, description: description)
    }
    
    // Categorize transaction based on type and description
    private static func categorizeTransaction(type: BankTransactionType, description: String) -> TransactionCategory {
        let lowercaseDescription = description.lowercased()
        
        // First check transaction type
        switch type {
        case .fee:
            return .fees
        case .interest:
            return .interest
        case .loan:
            return .loans
        case .investmentReturn:
            return .investments
        default:
            break
        }
        
        // Then check description keywords
        if lowercaseDescription.contains("rent") || lowercaseDescription.contains("mortgage") {
            return .housing
        } else if lowercaseDescription.contains("grocery") || lowercaseDescription.contains("restaurant") || 
                  lowercaseDescription.contains("food") {
            return .food
        } else if lowercaseDescription.contains("gas") || lowercaseDescription.contains("transport") || 
                  lowercaseDescription.contains("uber") || lowercaseDescription.contains("lyft") {
            return .transportation
        } else if lowercaseDescription.contains("doctor") || lowercaseDescription.contains("medical") || 
                  lowercaseDescription.contains("health") || lowercaseDescription.contains("pharmacy") {
            return .healthcare
        } else if lowercaseDescription.contains("salary") || lowercaseDescription.contains("payroll") || 
                  lowercaseDescription.contains("income") {
            return .income
        } else if lowercaseDescription.contains("entertainment") || lowercaseDescription.contains("movie") || 
                  lowercaseDescription.contains("subscription") {
            return .entertainment
        } else if lowercaseDescription.contains("education") || lowercaseDescription.contains("tuition") || 
                  lowercaseDescription.contains("book") || lowercaseDescription.contains("school") {
            return .education
        } else if lowercaseDescription.contains("utility") || lowercaseDescription.contains("electric") || 
                  lowercaseDescription.contains("water") || lowercaseDescription.contains("gas bill") || 
                  lowercaseDescription.contains("internet") || lowercaseDescription.contains("phone") {
            return .utilities
        } else if lowercaseDescription.contains("insurance") {
            return .insurance
        } else if lowercaseDescription.contains("charity") || lowercaseDescription.contains("donation") {
            return .charity
        }
        
        return .uncategorized
    }
    
    // Format amount as currency string
    func formattedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
    
    // Format date as string
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Categories for transactions to help with budgeting and reporting
enum TransactionCategory: String, Codable, CaseIterable {
    case housing = "Housing"
    case food = "Food & Dining"
    case transportation = "Transportation"
    case healthcare = "Healthcare"
    case entertainment = "Entertainment"
    case education = "Education"
    case shopping = "Shopping"
    case utilities = "Utilities"
    case insurance = "Insurance"
    case income = "Income"
    case investments = "Investments"
    case loans = "Loans"
    case fees = "Fees"
    case interest = "Interest"
    case charity = "Charity"
    case travel = "Travel"
    case uncategorized = "Uncategorized"
    
    // Get icon name for this category (for UI purposes)
    func iconName() -> String {
        switch self {
        case .housing: return "house"
        case .food: return "fork.knife"
        case .transportation: return "car"
        case .healthcare: return "heart"
        case .entertainment: return "tv"
        case .education: return "book"
        case .shopping: return "bag"
        case .utilities: return "bolt"
        case .insurance: return "shield"
        case .income: return "dollarsign"
        case .investments: return "chart.line.uptrend.xyaxis"
        case .loans: return "banknote"
        case .fees: return "exclamationmark.circle"
        case .interest: return "percent"
        case .charity: return "hand.raised"
        case .travel: return "airplane"
        case .uncategorized: return "questionmark"
        }
    }
    
    // Get color for this category (for UI purposes)
    func color() -> String {
        switch self {
        case .housing: return "blue"
        case .food: return "orange"
        case .transportation: return "green"
        case .healthcare: return "red"
        case .entertainment: return "purple"
        case .education: return "brown"
        case .shopping: return "pink"
        case .utilities: return "yellow"
        case .insurance: return "mint"
        case .income: return "green"
        case .investments: return "cyan"
        case .loans: return "indigo"
        case .fees: return "gray"
        case .interest: return "teal"
        case .charity: return "purple"
        case .travel: return "blue"
        case .uncategorized: return "gray"
        }
    }
}