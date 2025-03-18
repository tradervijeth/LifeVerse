//
//  Career.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//

import Foundation

struct Career: Codable, Identifiable {
    var id = UUID()
    var title: String
    var company: String
    var salary: Double
    var performanceRating: Int = 50 // 0-100
    var yearsAtJob: Int = 0
}

