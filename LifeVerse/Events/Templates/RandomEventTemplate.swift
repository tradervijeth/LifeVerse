//
//  RandomEventTemplate.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct RandomEventTemplate: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var type: LifeEvent.EventType
    var minAge: Int
    var maxAge: Int
    var probability: Double // 0.0-1.0
    var choices: [EventChoiceTemplate]?
    var requirements: [String: Any]? // e.g., "intelligence": ">60"
    
    // CodingKeys to handle requirements (which contains Any)
    enum CodingKeys: String, CodingKey {
        case id, title, description, type, minAge, maxAge, probability, choices
        // requirements is handled separately
    }
}
