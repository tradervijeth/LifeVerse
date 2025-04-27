//
//  EmploymentRecord.swift
//  LifeVerse
//
//  Created by Claude on 26/04/2025.
//

import Foundation

/// Represents a character's employment history record
struct EmploymentRecord: Codable, Identifiable {
    var id = UUID()
    var employer: String
    var jobTitle: String
    var startYear: Int
    var endYear: Int?
    var salary: Double
    var isFullTime: Bool
    var reasonForLeaving: String?
    var performanceRatings: [YearlyPerformance]
    
    struct YearlyPerformance: Codable, Identifiable {
        var id = UUID()
        var year: Int
        var rating: Int // 0-100 scale
        var bonusAmount: Double?
        var notes: String?
    }
    
    var isCurrentJob: Bool {
        return endYear == nil
    }
    
    var yearsAtJob: Int {
        let end = endYear ?? Calendar.current.component(.year, from: Date())
        return end - startYear
    }
    
    init(employer: String, jobTitle: String, startYear: Int, endYear: Int? = nil, 
         salary: Double, isFullTime: Bool = true, reasonForLeaving: String? = nil) {
        self.id = UUID()
        self.employer = employer
        self.jobTitle = jobTitle
        self.startYear = startYear
        self.endYear = endYear
        self.salary = salary
        self.isFullTime = isFullTime
        self.reasonForLeaving = reasonForLeaving
        self.performanceRatings = []
    }
}