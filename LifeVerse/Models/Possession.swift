//
//  Possession.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct Possession: Codable, Identifiable {
    var id = UUID()
    var name: String
    var value: Double
    var condition: Int // 0-100
    var yearAcquired: Int
}

