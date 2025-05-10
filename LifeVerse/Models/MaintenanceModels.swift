//
//  MaintenanceModels.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

// Maintenance frequency enum
enum MaintenanceFrequency: String, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case biannual = "Biannual"
    case annual = "Annual"
    case asNeeded = "As Needed"
}

// Maintenance priority enum
enum MaintenancePriority: String, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    case critical = "Critical"
}

// Maintenance item for property
struct MaintenanceItem: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var frequency: MaintenanceFrequency
    var estimatedCost: Double
    var isRecurring: Bool
    var priority: MaintenancePriority
    var lastPerformedDate: Date?
    var nextDueDate: Date?
    
    // Initialize a maintenance item
    init(name: String, description: String, frequency: MaintenanceFrequency, estimatedCost: Double, isRecurring: Bool, priority: MaintenancePriority) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.frequency = frequency
        self.estimatedCost = estimatedCost
        self.isRecurring = isRecurring
        self.priority = priority
    }
}

// Renovation project for property improvements
struct RenovationProject: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var estimatedCost: Double
    var actualCost: Double?
    var startDate: Date?
    var completionDate: Date?
    var isCompleted: Bool = false
    var valueAddedEstimate: Double
    
    init(name: String, description: String, estimatedCost: Double, valueAddedEstimate: Double) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.estimatedCost = estimatedCost
        self.valueAddedEstimate = valueAddedEstimate
    }
}

// Development project for property development
struct DevelopmentProject: Codable, Identifiable {
    var id = UUID()
    var name: String
    var description: String
    var estimatedCost: Double
    var actualCost: Double?
    var startDate: Date?
    var completionDate: Date?
    var isCompleted: Bool = false
    var valueAddedEstimate: Double
    var permitRequired: Bool
    var permitObtained: Bool = false
    
    init(name: String, description: String, estimatedCost: Double, valueAddedEstimate: Double, permitRequired: Bool) {
        self.id = UUID()
        self.name = name
        self.description = description
        self.estimatedCost = estimatedCost
        self.valueAddedEstimate = valueAddedEstimate
        self.permitRequired = permitRequired
    }
}

// Tenant information for rental properties
struct Tenant: Codable, Identifiable {
    var id = UUID()
    var name: String
    var leaseStartDate: Date
    var leaseEndDate: Date
    var monthlyRent: Double
    var securityDeposit: Double
    var paymentHistory: [RentalPayment] = []
    var isActive: Bool = true
    
    init(name: String, leaseStartDate: Date, leaseEndDate: Date, monthlyRent: Double, securityDeposit: Double) {
        self.id = UUID()
        self.name = name
        self.leaseStartDate = leaseStartDate
        self.leaseEndDate = leaseEndDate
        self.monthlyRent = monthlyRent
        self.securityDeposit = securityDeposit
    }
}

// Rental payment record
struct RentalPayment: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var amount: Double
    var isLate: Bool
    var lateFeePaid: Double?
    
    init(date: Date, amount: Double, isLate: Bool, lateFeePaid: Double? = nil) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.isLate = isLate
        self.lateFeePaid = lateFeePaid
    }
}

// Rental transaction record
struct RentalTransaction: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var amount: Double
    var description: String
    var type: RentalTransactionType
    var tenantId: UUID?
    
    init(date: Date, amount: Double, description: String, type: RentalTransactionType, tenantId: UUID? = nil) {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.description = description
        self.type = type
        self.tenantId = tenantId
    }
}

// Rental transaction types
enum RentalTransactionType: String, Codable {
    case rent = "Rent"
    case deposit = "Security Deposit"
    case maintenance = "Maintenance"
    case repairs = "Repairs"
    case utilities = "Utilities"
    case propertyTax = "Property Tax"
    case insurance = "Insurance"
    case management = "Property Management"
    case other = "Other"
}
