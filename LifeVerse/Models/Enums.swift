//
//  Enums.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case nonBinary = "Non-binary"
}

enum Education: String, Codable, CaseIterable {
    case none = "None"
    case elementarySchool = "Elementary School"
    case middleSchool = "Middle School"
    case highSchool = "High School"
    case associatesDegree = "Associate's Degree"
    case bachelorsDegree = "Bachelor's Degree"
    case mastersDegree = "Master's Degree"
    case doctoralDegree = "Doctoral Degree"
}

enum Residence: String, Codable {
    case parentsHome = "Parent's Home"
    case apartment = "Apartment"
    case house = "House"
    case mansion = "Mansion"
    case homeless = "Homeless"
}

// Models/Career.swift

import Foundation

struct Career: Codable, Identifiable {
    var id = UUID()
    var title: String
    var company: String
    var salary: Double
    var performanceRating: Int = 50 // 0-100
    var yearsAtJob: Int = 0
}
