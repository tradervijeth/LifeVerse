//
//  RelationshipEventTemplate.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct RelationshipEventTemplate: Codable, Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var relationshipType: Relationship.RelationshipType
    var minCloseness: Int?
    var maxCloseness: Int?
    var probability: Double
    var choices: [EventChoiceTemplate]?
}
