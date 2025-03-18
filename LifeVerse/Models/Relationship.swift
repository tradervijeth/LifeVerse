//
//  Relationship.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct Relationship: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: RelationshipType
    var closeness: Int // 0-100
    var years: Int = 0
    
    enum RelationshipType: String, Codable {
        case parent
        case sibling
        case child
        case friend
        case significantOther
        case spouse
        case exSpouse
        case coworker
    }
}

