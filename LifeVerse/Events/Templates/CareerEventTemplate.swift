//
//  CareerEventTemplate.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct CareerPathTemplate: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var educationRequirement: Education
    var salaryRange: ClosedRange<Double>
    var events: [CareerEventTemplate]
    
    // For Codable conformance due to ClosedRange
    enum CodingKeys: CodingKey {
        case id, title, description, educationRequirement, salaryMin, salaryMax, events
    }
    
    init(title: String, description: String, educationRequirement: Education, salaryRange: ClosedRange<Double>, events: [CareerEventTemplate]) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.educationRequirement = educationRequirement
        self.salaryRange = salaryRange
        self.events = events
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        educationRequirement = try container.decode(Education.self, forKey: .educationRequirement)
        let min = try container.decode(Double.self, forKey: .salaryMin)
        let max = try container.decode(Double.self, forKey: .salaryMax)
        salaryRange = min...max
        events = try container.decode([CareerEventTemplate].self, forKey: .events)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(educationRequirement, forKey: .educationRequirement)
        try container.encode(salaryRange.lowerBound, forKey: .salaryMin)
        try container.encode(salaryRange.upperBound, forKey: .salaryMax)
        try container.encode(events, forKey: .events)
    }
}

struct CareerEventTemplate: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var probability: Double
    var choices: [EventChoiceTemplate]?
    var yearsAtJobRequired: Int?
}

// Events/Templates/EventChoiceTemplate.swift

import Foundation

struct EventChoiceTemplate: Codable, Identifiable {
    var id = UUID()
    var text: String
    var outcomes: [EventOutcomeTemplate]
    var probability: [Double] // Probability distribution for outcomes
}

struct EventOutcomeTemplate: Codable, Identifiable {
    var id = UUID()
    var description: String
    var effects: [String: Int] // e.g., "health": -10
}
