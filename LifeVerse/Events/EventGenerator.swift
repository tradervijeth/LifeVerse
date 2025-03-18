//
//  EventGenerator.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

class EventGenerator {
    static func generateRandomEvents(for character: Character) -> [LifeEvent] {
        var events: [LifeEvent] = []
        
        // Determine number of random events for this year (0-3)
        let eventCount = weightedRandom(min: 0, max: 3, weight: 0.7)
        
        for _ in 0..<eventCount {
            if let event = generateRandomEvent(for: character) {
                events.append(event)
            }
        }
        
        return events
    }
    
    static func generateEducationEvents(for character: Character) -> [LifeEvent] {
        var events: [LifeEvent] = []
        
        // Logic for education events based on age
        switch character.age {
        case 5:
            // Starting elementary school
            let event = LifeEvent(
                title: "First Day of School",
                description: "It's your first day of elementary school.",
                type: .school,
                year: character.birthYear + character.age,
                choices: [
                    EventChoice(
                        text: "Make friends",
                        outcome: "You made some new friends.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 10)
                        ]
                    ),
                    EventChoice(
                        text: "Focus on learning",
                        outcome: "You paid attention to the teacher.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "intelligence", change: 5)
                        ]
                    )
                ]
            )
            events.append(event)
        case 14:
            // Starting high school
            let event = LifeEvent(
                title: "High School",
                description: "You're starting high school.",
                type: .school,
                year: character.birthYear + character.age,
                choices: [
                    EventChoice(
                        text: "Join a sports team",
                        outcome: "You joined the school's sports team.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "athleticism", change: 15),
                            EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                        ]
                    ),
                    EventChoice(
                        text: "Focus on academics",
                        outcome: "You focused on your studies.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "intelligence", change: 15)
                        ]
                    ),
                    EventChoice(
                        text: "Join a club",
                        outcome: "You joined a school club.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 10),
                            EventChoice.CharacterEffect(attribute: "intelligence", change: 5)
                        ]
                    )
                ]
            )
            events.append(event)
        default:
            break
        }
        
        return events
    }
    
    static func generateCareerEvents(for character: Character) -> [LifeEvent] {
        var events: [LifeEvent] = []
        
        // Career events for first job
        if character.age == 22 && character.career == nil && character.education == .bachelorsDegree {
            let event = LifeEvent(
                title: "Job Opportunity",
                description: "You've been offered a job as a Junior Software Developer at TechCorp.",
                type: .career,
                year: character.birthYear + character.age,
                choices: [
                    EventChoice(
                        text: "Accept the job",
                        outcome: "You accepted the job offer and started your career.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "money", change: 60000)
                        ]
                    ),
                    EventChoice(
                        text: "Decline and look for something better",
                        outcome: "You decided to keep looking for better opportunities.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: -5)
                        ]
                    )
                ]
            )
            events.append(event)
        }
        
        return events
    }
    
    static func generateRelationshipEvents(for character: Character) -> [LifeEvent] {
        var events: [LifeEvent] = []
        
        // Relationship events
        if character.age == 18 && !character.relationships.contains(where: { $0.type == .significantOther }) {
            let event = LifeEvent(
                title: "New Relationship",
                description: "Someone seems interested in you romantically.",
                type: .relationship,
                year: character.birthYear + character.age,
                choices: [
                    EventChoice(
                        text: "Start dating them",
                        outcome: "You started a new relationship.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 15)
                        ]
                    ),
                    EventChoice(
                        text: "Reject them",
                        outcome: "You decided to stay single for now.",
                        effects: []
                    )
                ]
            )
            events.append(event)
        }
        
        return events
    }
    
    // Helper method to generate a specific random event
    private static func generateRandomEvent(for character: Character) -> LifeEvent? {
        // This would be a large system with hundreds of potential events
        // Example of a simple random event:
        
        let eventPool = [
            LifeEvent(
                title: "Found Money",
                description: "You found $20 on the sidewalk!",
                type: .financial,
                year: character.birthYear + character.age,
                outcome: "You're $20 richer."
            ),
            LifeEvent(
                title: "Caught a Cold",
                description: "You caught a nasty cold.",
                type: .health,
                year: character.birthYear + character.age,
                outcome: "You were sick for a week."
            ),
            LifeEvent(
                title: "Birthday Party",
                description: "Your friends threw you a surprise birthday party!",
                type: .random,
                year: character.birthYear + character.age,
                outcome: "It was a great time."
            )
        ]
        
        // Filter events based on character age, attributes, etc.
        // For now, just return a random one
        return eventPool.randomElement()
    }
    
    // Helper function for weighted randomness
    private static func weightedRandom(min: Int, max: Int, weight: Double) -> Int {
        let random = Double.random(in: 0...1)
        let weighted = pow(random, weight)
        return min + Int(weighted * Double(max - min))
    }
}
