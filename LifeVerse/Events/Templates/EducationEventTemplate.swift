//
//  EducationEventTemplate.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct EducationEventTemplate: Codable, Identifiable {
    var id = UUID()
    var level: Education
    var title: String
    var description: String
    var minAge: Int
    var requirements: [String: String]? // e.g., "intelligence": ">60"
    var choices: [EventChoiceTemplate]?
}
