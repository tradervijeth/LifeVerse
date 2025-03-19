//
//  EventGenerator.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

class EventGenerator {
    // MARK: - Main Event Generation Methods
    
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
            
        case 11:
            // Starting middle school
            let event = LifeEvent(
                title: "Middle School",
                description: "You're starting middle school.",
                type: .school,
                year: character.birthYear + character.age,
                choices: [
                    EventChoice(
                        text: "Join a sports team",
                        outcome: "You joined the school's sports team.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "athleticism", change: 10),
                            EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                        ]
                    ),
                    EventChoice(
                        text: "Focus on academics",
                        outcome: "You focused on your studies.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "intelligence", change: 10)
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
            
        case 18:
            // College decision
            if character.intelligence > 70 {
                let event = LifeEvent(
                    title: "College Decision",
                    description: "You've graduated high school. What's next?",
                    type: .school,
                    year: character.birthYear + character.age,
                    choices: [
                        EventChoice(
                            text: "Attend university",
                            outcome: "You enrolled in a university program.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "intelligence", change: 10),
                                EventChoice.CharacterEffect(attribute: "money", change: -20000)
                            ]
                        ),
                        EventChoice(
                            text: "Get a job",
                            outcome: "You decided to start working right away.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "money", change: 25000)
                            ]
                        ),
                        EventChoice(
                            text: "Take a gap year",
                            outcome: "You decided to take a year off to explore your options.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "happiness", change: 15)
                            ]
                        )
                    ]
                )
                events.append(event)
            } else {
                let event = LifeEvent(
                    title: "After High School",
                    description: "You've graduated high school. What's next?",
                    type: .school,
                    year: character.birthYear + character.age,
                    choices: [
                        EventChoice(
                            text: "Attend community college",
                            outcome: "You enrolled in a community college program.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "intelligence", change: 8),
                                EventChoice.CharacterEffect(attribute: "money", change: -5000)
                            ]
                        ),
                        EventChoice(
                            text: "Get a job",
                            outcome: "You decided to start working right away.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "money", change: 25000)
                            ]
                        )
                    ]
                )
                events.append(event)
            }
            
        case 22:
            // College graduation (if applicable)
            if character.education == .bachelorsDegree {
                let event = LifeEvent(
                    title: "College Graduation",
                    description: "You've completed your bachelor's degree!",
                    type: .graduation,
                    year: character.birthYear + character.age,
                    outcome: "You now have a bachelor's degree.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "intelligence", change: 5),
                        EventChoice.CharacterEffect(attribute: "happiness", change: 10)
                    ]
                )
                events.append(event)
            }
            
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
        
        // Job promotion opportunities
        if let career = character.career, career.yearsAtJob >= 3 && career.performanceRating > 70 {
            let promotionTitle = "Senior " + career.title
            let currentSalary = career.salary
            let newSalary = currentSalary * 1.2 // 20% increase
            
            let event = LifeEvent(
                title: "Promotion Opportunity",
                description: "Your hard work has paid off! You've been offered a promotion to \(promotionTitle).",
                type: .career,
                year: character.birthYear + character.age,
                choices: [
                    EventChoice(
                        text: "Accept the promotion",
                        outcome: "You've been promoted to \(promotionTitle) with a nice salary increase.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "money", change: Int(newSalary - currentSalary)),
                            EventChoice.CharacterEffect(attribute: "happiness", change: 10)
                        ]
                    ),
                    EventChoice(
                        text: "Decline and maintain work-life balance",
                        outcome: "You decided to stay in your current role to maintain better work-life balance.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 5)
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
        
        // New relationship opportunity
        if character.age >= 18 && !character.relationships.contains(where: { $0.type == .significantOther }) {
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
        
        // Friend making opportunity
        if character.relationships.filter({ $0.type == .friend }).count < 3 && Int.random(in: 1...100) < 30 {
            let settings = ["at work", "through a hobby", "at a social event", "through mutual friends", "in your neighborhood"]
            let setting = settings.randomElement()!
            
            let event = LifeEvent(
                title: "Potential Friendship",
                description: "You've met someone interesting \(setting).",
                type: .relationship,
                year: character.birthYear + character.age,
                choices: [
                    EventChoice(
                        text: "Make friends",
                        outcome: "You've made a new friend.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 8)
                        ]
                    ),
                    EventChoice(
                        text: "Keep it casual",
                        outcome: "You decided to keep things casual rather than develop a friendship.",
                        effects: []
                    )
                ]
            )
            events.append(event)
        }
        
        return events
    }
    
    // MARK: - Helper Methods for Event Generation
    
    // Generate a financial event
    private static func generateFinancialEvent(for character: Character) -> LifeEvent {
        let eventType = Int.random(in: 0...1)
        
        switch eventType {
        case 0: // Found money
            let amounts = [20, 50, 100, 200, 500]
            let amount = amounts.randomElement() ?? 20
            
            let sources = [
                "on the sidewalk",
                "in an old coat pocket",
                "in a parking lot",
                "as a small gift from a relative"
            ]
            let source = sources.randomElement()!
            
            return LifeEvent(
                title: "Found Money",
                description: "You found $\(amount) \(source)!",
                type: .financial,
                year: character.birthYear + character.age,
                outcome: "You're $\(amount) richer.",
                effects: [EventChoice.CharacterEffect(attribute: "money", change: amount)]
            )
            
        default: // Unexpected expense
            let items = ["phone", "laptop", "car", "appliance", "clothing"]
            let item = items.randomElement()!
            
            let amounts = [50, 100, 200, 300]
            let amount = amounts.randomElement() ?? 100
            
            return LifeEvent(
                title: "Unexpected Expense",
                description: "Your \(item) needs repair or replacement.",
                type: .financial,
                year: character.birthYear + character.age,
                outcome: "You spent $\(amount) to fix the issue.",
                effects: [EventChoice.CharacterEffect(attribute: "money", change: -amount)]
            )
        }
    }
    
    // Generate a health event
    private static func generateHealthEvent(for character: Character) -> LifeEvent {
        // Health events vary by age
        let eventType = Int.random(in: 0...2)
        
        if character.age < 18 {
            switch eventType {
            case 0:
                return LifeEvent(
                    title: "Caught a Cold",
                    description: "You caught a cold.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "You were sick for a few days.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: -3),
                        EventChoice.CharacterEffect(attribute: "happiness", change: -2)
                    ]
                )
            case 1:
                return LifeEvent(
                    title: "Sports Injury",
                    description: "You got injured playing sports.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "You had to rest for a week.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: -5),
                        EventChoice.CharacterEffect(attribute: "happiness", change: -3)
                    ]
                )
            default:
                return LifeEvent(
                    title: "Regular Checkup",
                    description: "You had your regular doctor's checkup.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "Everything looks good!",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: 2)
                    ]
                )
            }
        } else if character.age < 40 {
            switch eventType {
            case 0:
                return LifeEvent(
                    title: "Flu Season",
                    description: "It's flu season and you're feeling under the weather.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "You were sick with the flu for a week.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: -8),
                        EventChoice.CharacterEffect(attribute: "happiness", change: -5)
                    ]
                )
            case 1:
                return LifeEvent(
                    title: "Started Working Out",
                    description: "You decided to start a new exercise routine.",
                    type: .health,
                    year: character.birthYear + character.age,
                    choices: [
                        EventChoice(
                            text: "Stick with it",
                            outcome: "You maintained your exercise routine and feel healthier.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "health", change: 10),
                                EventChoice.CharacterEffect(attribute: "happiness", change: 5),
                                EventChoice.CharacterEffect(attribute: "athleticism", change: 15)
                            ]
                        ),
                        EventChoice(
                            text: "Give up after a week",
                            outcome: "You quit your exercise routine quickly.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "happiness", change: -3)
                            ]
                        )
                    ]
                )
            default:
                return LifeEvent(
                    title: "Minor Injury",
                    description: "You injured yourself during everyday activities.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "You recovered after taking it easy for a while.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: -5),
                        EventChoice.CharacterEffect(attribute: "happiness", change: -3)
                    ]
                )
            }
        } else {
            // Older adult health events
            let severityFactor = (character.age - 40) / 20 // 0 for age 40, 1 for age 60, etc.
            let baseHealthImpact = -5 - Int(Double(severityFactor) * 5)
            
            switch eventType {
            case 0:
                return LifeEvent(
                    title: "Health Checkup",
                    description: "You went for a regular health checkup.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "The doctor gave you some advice on maintaining your health.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: 3)
                    ]
                )
            case 1:
                return LifeEvent(
                    title: "Minor Health Issue",
                    description: "You've been experiencing some minor health problems.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "You're managing it with medication and lifestyle changes.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: baseHealthImpact),
                        EventChoice.CharacterEffect(attribute: "happiness", change: -3)
                    ]
                )
            default:
                return LifeEvent(
                    title: "Back Pain",
                    description: "You've been experiencing back pain.",
                    type: .health,
                    year: character.birthYear + character.age,
                    outcome: "With some physical therapy, you're feeling better.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "health", change: baseHealthImpact - 2),
                        EventChoice.CharacterEffect(attribute: "happiness", change: -4)
                    ]
                )
            }
        }
    }
    
    // Generate a misc event
    private static func generateMiscEvent(for character: Character) -> LifeEvent {
        let eventType = Int.random(in: 0...4)
        
        switch eventType {
        case 0:
            return LifeEvent(
                title: "Found a Hobby",
                description: "You discovered a new hobby that interests you.",
                type: .random,
                year: character.birthYear + character.age,
                outcome: "You're enjoying your new pastime.",
                effects: [
                    EventChoice.CharacterEffect(attribute: "happiness", change: 8),
                    EventChoice.CharacterEffect(attribute: "intelligence", change: 3)
                ]
            )
        case 1:
            return LifeEvent(
                title: "Rainy Day",
                description: "It rained all day, keeping you indoors.",
                type: .random,
                year: character.birthYear + character.age,
                outcome: "You spent the day relaxing inside.",
                effects: [
                    EventChoice.CharacterEffect(attribute: "happiness", change: character.happiness < 50 ? 2 : -2)
                ]
            )
        case 2:
            return LifeEvent(
                title: "Power Outage",
                description: "There was a power outage in your area.",
                type: .random,
                year: character.birthYear + character.age,
                outcome: "You managed without electricity for a while.",
                effects: [
                    EventChoice.CharacterEffect(attribute: "happiness", change: -3)
                ]
            )
        case 3:
            return LifeEvent(
                title: "Birthday Party",
                description: "Your friends threw you a surprise birthday party!",
                type: .random,
                year: character.birthYear + character.age,
                outcome: "It was a great time.",
                effects: [
                    EventChoice.CharacterEffect(attribute: "happiness", change: 15)
                ]
            )
        default:
            return LifeEvent(
                title: "Interesting Book",
                description: "You read a book that really made you think.",
                type: .random,
                year: character.birthYear + character.age,
                outcome: "The ideas stayed with you for a while.",
                effects: [
                    EventChoice.CharacterEffect(attribute: "intelligence", change: 5),
                    EventChoice.CharacterEffect(attribute: "happiness", change: 2)
                ]
            )
        }
    }
    
    // Choose the type of event to generate
    private static func generateEvent(category: String, for character: Character) -> LifeEvent? {
        switch category {
        case "financial":
            return generateFinancialEvent(for: character)
        case "health":
            return generateHealthEvent(for: character)
        case "relationship":
            if let relationshipEvent = generateRandomRelationshipEvent(for: character) {
                return relationshipEvent
            } else {
                return generateMiscEvent(for: character)
            }
        default:
            return generateMiscEvent(for: character)
        }
    }
    
    // Helper method to generate a random relationship event
    private static func generateRandomRelationshipEvent(for character: Character) -> LifeEvent? {
        // Only generate for characters with at least one relationship
        if character.relationships.isEmpty {
            return nil
        }
        
        // Get a random relationship
        if let relationship = character.relationships.randomElement() {
            let eventType = Int.random(in: 0...2)
            
            switch eventType {
            case 0:
                return LifeEvent(
                    title: "Quality Time",
                    description: "You spent quality time with \(relationship.name).",
                    type: .relationship,
                    year: character.birthYear + character.age,
                    outcome: "Your relationship grew stronger.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                    ]
                )
            case 1:
                return LifeEvent(
                    title: "Minor Disagreement",
                    description: "You and \(relationship.name) had a minor disagreement.",
                    type: .relationship,
                    year: character.birthYear + character.age,
                    outcome: "You worked through it and moved on.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: -2)
                    ]
                )
            default:
                return LifeEvent(
                    title: "Birthday Celebration",
                    description: "It's \(relationship.name)'s birthday!",
                    type: .relationship,
                    year: character.birthYear + character.age,
                    outcome: "You celebrated together and had a great time.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: 3)
                    ]
                )
            }
        }
        
        return nil
    }
    
    // Helper method to generate a specific random event (original version)
    private static func generateRandomEvent(for character: Character) -> LifeEvent? {
        // Choose event category based on character age and circumstances
        let categories = ["financial", "health", "relationship", "random"]
        var weights = [0.25, 0.25, 0.25, 0.25] // Default weights
        
        // Adjust weights based on character age and circumstances
        if character.age > 50 {
            weights[1] = 0.4 // Health becomes more important
            weights[0] = 0.2 // Financial less
            weights[2] = 0.2 // Relationship less
            weights[3] = 0.2 // Random less
        } else if character.age < 18 {
            weights[2] = 0.1 // Relationship less important
            weights[3] = 0.4 // More random events for kids
        }
        
        // If character has low money, more financial events
        if character.money < 1000 {
            weights[0] = 0.4
        }
        
        // Choose category based on weights
        let totalWeight = weights.reduce(0, +)
        var randomValue = Double.random(in: 0..<totalWeight)
        var selectedCategory = "random" // Default
        
        for i in 0..<categories.count {
            if randomValue < weights[i] {
                selectedCategory = categories[i]
                break
            }
            randomValue -= weights[i]
        }
        
        return generateEvent(category: selectedCategory, for: character)
    }
    
    // Helper function for weighted randomness
    private static func weightedRandom(min: Int, max: Int, weight: Double) -> Int {
        let random = Double.random(in: 0...1)
        let weighted = pow(random, weight)
        return min + Int(weighted * Double(max - min))
    }
}
