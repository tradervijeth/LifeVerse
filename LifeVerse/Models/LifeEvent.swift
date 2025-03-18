//
//  LifeEvent.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct LifeEvent: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var type: EventType
    var year: Int
    var choices: [EventChoice]? = nil
    var outcome: String? = nil
    
    enum EventType: String, Codable {
        case birth
        case school
        case graduation
        case career
        case relationship
        case health
        case financial
        case random
        case death
    }
}

struct EventChoice: Codable, Identifiable {
    var id = UUID()
    var text: String
    var outcome: String
    var effects: [CharacterEffect]
    
    struct CharacterEffect: Codable {
        var attribute: String // e.g., "health", "happiness", "money"
        var change: Int // Can be positive or negative
    }
}
