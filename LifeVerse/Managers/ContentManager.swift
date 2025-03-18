//
//  ContentManager.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

class ContentManager {
    // This would load JSON files containing events, career paths, etc.
    private var careerPaths: [CareerPathTemplate] = []
    private var randomEvents: [RandomEventTemplate] = []
    private var educationEvents: [EducationEventTemplate] = []
    private var relationshipEvents: [RelationshipEventTemplate] = []
    
    init() {
        loadCareerPaths()
        loadRandomEvents()
        loadEducationEvents()
        loadRelationshipEvents()
    }
    
    private func loadCareerPaths() {
        // In a real app, load from JSON
        // For now, create some sample career paths
        careerPaths = [
            CareerPathTemplate(
                title: "Software Developer",
                description: "Write code and develop applications",
                educationRequirement: .bachelorsDegree,
                salaryRange: 60000...150000,
                events: []
            ),
            CareerPathTemplate(
                title: "Doctor",
                description: "Treat patients and save lives",
                educationRequirement: .doctoralDegree,
                salaryRange: 120000...300000,
                events: []
            ),
            CareerPathTemplate(
                title: "Teacher",
                description: "Educate the next generation",
                educationRequirement: .bachelorsDegree,
                salaryRange: 35000...75000,
                events: []
            )
        ]
    }
    
    private func loadRandomEvents() {
        // In a real app, load from JSON
        // For now, create some sample random events
        randomEvents = [
            RandomEventTemplate(
                title: "Found Money",
                description: "You found $20 on the sidewalk!",
                type: .financial,
                minAge: 5,
                maxAge: 100,
                probability: 0.1,
                choices: nil,
                requirements: nil
            ),
            RandomEventTemplate(
                title: "Caught a Cold",
                description: "You caught a nasty cold.",
                type: .health,
                minAge: 0,
                maxAge: 100,
                probability: 0.2,
                choices: nil,
                requirements: nil
            )
        ]
    }
    
    private func loadEducationEvents() {
        // Load education events (would be from JSON in a real app)
    }
    
    private func loadRelationshipEvents() {
        // Load relationship events (would be from JSON in a real app)
    }
    
    // Methods to access content
    func getCareerPaths() -> [CareerPathTemplate] {
        return careerPaths
    }
    
    func getRandomEvents() -> [RandomEventTemplate] {
        return randomEvents
    }
}

