//
//  GameManager.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var character: Character?
    @Published var currentYear: Int = Calendar.current.component(.year, from: Date())
    @Published var gameStarted: Bool = false
    @Published var gameEnded: Bool = false
    @Published var currentEvents: [LifeEvent] = []
    
    private let contentManager = ContentManager()
    
    func startNewGame(name: String, birthYear: Int, gender: Gender) {
        character = Character(name: name, birthYear: birthYear, gender: gender)
        currentYear = birthYear
        gameStarted = true
        gameEnded = false
        
        // Add birth event
        let birthEvent = LifeEvent(
            title: "Birth",
            description: "You were born in \(birthYear).",
            type: .birth,
            year: birthYear
        )
        
        character?.lifeEvents.append(birthEvent)
        currentEvents = [birthEvent]
    }
    
    func advanceYear() {
        guard var character = character, character.isAlive else {
            gameEnded = true
            return
        }
        
        // Handle yearly income if character has a job
        if let career = character.career, character.age >= 18 {
            // Add yearly salary to character's money
            character.money += career.salary
            
            // Increment years at job
            character.career?.yearsAtJob += 1
            
            // Randomly update performance
            let performanceChange = Int.random(in: -5...10)
            character.career?.performanceRating = max(0, min(100, career.performanceRating + performanceChange))
        }
        
        // Age-related expenses (only for adults)
        if character.age >= 18 {
            // Basic living expenses based on residence type
            var livingExpenses: Double = 0
            switch character.residence {
            case .parentsHome:
                livingExpenses = 1000 // Small contribution to parents
            case .apartment:
                livingExpenses = 12000 // $1000/month rent
            case .house:
                livingExpenses = 18000 // $1500/month mortgage + utilities
            case .mansion:
                livingExpenses = 36000 // $3000/month expensive lifestyle
            case .homeless:
                livingExpenses = 2400 // $200/month minimal expenses
            }
            
            // Deduct living expenses
            character.money -= livingExpenses
            
            // Create living expense event
            let expenseEvent = LifeEvent(
                title: "Living Expenses",
                description: "You paid $\(Int(livingExpenses)) for your living expenses this year.",
                type: .financial,
                year: currentYear,
                outcome: "Your account was debited.",
                effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(livingExpenses))]
            )
            character.lifeEvents.append(expenseEvent)
            
            // Car expenses for those who own cars (only if 18+)
            if let carIndex = character.possessions.firstIndex(where: { $0.name.lowercased().contains("car") }) {
                let car = character.possessions[carIndex]
                
                // Car maintenance and insurance costs (roughly 10% of car value per year)
                let carExpenses = car.value * 0.1
                character.money -= carExpenses
                
                // Decrease car condition
                let newCondition = max(0, car.condition - Int.random(in: 5...15))
                character.possessions[carIndex].condition = newCondition
                
                // Create car expense event
                let carEvent = LifeEvent(
                    title: "Car Expenses",
                    description: "You paid $\(Int(carExpenses)) for car maintenance and insurance.",
                    type: .financial,
                    year: currentYear,
                    outcome: "Your car's condition is now \(newCondition)%.",
                    effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(carExpenses))]
                )
                character.lifeEvents.append(carEvent)
            }
        }
        
        currentYear += 1
        let newEvents = character.ageUp()
        
        // Process automatic events
        for event in newEvents {
            if event.choices == nil && event.effects != nil {
                applyEventEffects(event.effects!, to: &character)
            }
        }
        
        // Child-specific restrictions
        if character.age < 18 {
            // Enforce that minors can't have certain possessions
            character.possessions.removeAll { possession in
                let name = possession.name.lowercased()
                return name.contains("car") || name.contains("house") || name.contains("apartment")
            }
            
            // Enforce appropriate residence
            character.residence = .parentsHome
        }
        
        // Check for bankruptcy
        if character.money < -10000 {
            // Create bankruptcy event
            let bankruptcyEvent = LifeEvent(
                title: "Financial Trouble",
                description: "You're deeply in debt with $\(Int(character.money)).",
                type: .financial,
                year: currentYear,
                choices: [
                    EventChoice(
                        text: "Declare Bankruptcy",
                        outcome: "You declared bankruptcy. Your debts were cleared but your credit is ruined.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "money", change: Int(-character.money)),
                            EventChoice.CharacterEffect(attribute: "happiness", change: -20)
                        ]
                    ),
                    EventChoice(
                        text: "Try to manage the debt",
                        outcome: "You're trying to manage your debt situation.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: -10)
                        ]
                    )
                ]
            )
            currentEvents.append(bankruptcyEvent)
            character.lifeEvents.append(bankruptcyEvent)
        }
        
        self.character = character
        
        // Add the new events to the current events list
        // (We'll prepend the automatic events we generated for expenses)
        let autoEvents = character.lifeEvents.filter { event in 
            return event.year == currentYear && 
                   !newEvents.contains { $0.id == event.id }
        }
        currentEvents = autoEvents + newEvents
        
        if !character.isAlive {
            gameEnded = true
        }
        
        // Auto-save the game after each year
        _ = SaveSystem.saveGame(gameManager: self)
    }
    
    private func applyEventEffects(_ effects: [EventChoice.CharacterEffect], to character: inout Character) {
        for effect in effects {
            switch effect.attribute {
            case "health":
                character.health = max(0, min(100, character.health + effect.change))
            case "happiness":
                character.happiness = max(0, min(100, character.happiness + effect.change))
            case "intelligence":
                character.intelligence = max(0, min(100, character.intelligence + effect.change))
            case "looks":
                character.looks = max(0, min(100, character.looks + effect.change))
            case "athleticism":
                character.athleticism = max(0, min(100, character.athleticism + effect.change))
            case "money":
                character.money += Double(effect.change)
            default:
                break
            }
        }
    }
    
    func makeChoice(for event: LifeEvent, choice: EventChoice) {
        // Apply effects of the choice to the character
        guard var character = self.character else { return }
        
        for effect in choice.effects {
            switch effect.attribute {
            case "health":
                character.health = max(0, min(100, character.health + effect.change))
            case "happiness":
                character.happiness = max(0, min(100, character.happiness + effect.change))
            case "intelligence":
                character.intelligence = max(0, min(100, character.intelligence + effect.change))
            case "looks":
                character.looks = max(0, min(100, character.looks + effect.change))
            case "athleticism":
                character.athleticism = max(0, min(100, character.athleticism + effect.change))
            case "money":
                character.money += Double(effect.change)
            default:
                break
            }
        }
        
        // Update the event with the chosen outcome
        if let index = character.lifeEvents.firstIndex(where: { $0.id == event.id }) {
            character.lifeEvents[index].outcome = choice.outcome
        }
        
        // Update the current events list
        if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
            currentEvents[index].outcome = choice.outcome
        }
        
        self.character = character
    }
    
    // Add new methods for gameplay actions
    
    func buyPossession(name: String, value: Double, condition: Int = 100) -> Bool {
        guard var character = self.character else { return false }
        
        // Age restrictions
        if character.age < 18 && (
            name.lowercased().contains("car") || 
            name.lowercased().contains("house") ||
            name.lowercased().contains("apartment")
        ) {
            // Create age restriction event
            let restrictionEvent = LifeEvent(
                title: "Age Restriction",
                description: "You're too young to purchase a \(name).",
                type: .random,
                year: currentYear,
                outcome: "You need to be at least 18 years old.",
                effects: []
            )
            currentEvents.append(restrictionEvent)
            character.lifeEvents.append(restrictionEvent)
            self.character = character
            return false
        }
        
        // Check if they can afford it
        if character.money < value {
            // Create can't afford event
            let affordEvent = LifeEvent(
                title: "Can't Afford",
                description: "You can't afford to purchase a \(name) for $\(Int(value)).",
                type: .financial,
                year: currentYear,
                outcome: "You need $\(Int(value - character.money)) more.",
                effects: []
            )
            currentEvents.append(affordEvent)
            character.lifeEvents.append(affordEvent)
            self.character = character
            return false
        }
        
        // Purchase the possession
        let newPossession = Possession(
            name: name,
            value: value,
            condition: condition,
            yearAcquired: currentYear
        )
        
        character.possessions.append(newPossession)
        character.money -= value
        
        // Create purchase event
        let purchaseEvent = LifeEvent(
            title: "New Purchase",
            description: "You purchased a \(name) for $\(Int(value)).",
            type: .financial,
            year: currentYear,
            outcome: "It's now part of your assets.",
            effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(value))]
        )
        currentEvents.append(purchaseEvent)
        character.lifeEvents.append(purchaseEvent)
        
        self.character = character
        return true
    }
    
    func sellPossession(possessionId: UUID) -> Bool {
        guard var character = self.character,
              let index = character.possessions.firstIndex(where: { $0.id == possessionId }) else {
            return false
        }
        
        let possession = character.possessions[index]
        
        // Calculate sell value (based on condition)
        let conditionFactor = Double(possession.condition) / 100.0
        let sellValue = possession.value * conditionFactor * 0.7 // 70% of condition-adjusted value
        
        character.money += sellValue
        character.possessions.remove(at: index)
        
        // Create sell event
        let sellEvent = LifeEvent(
            title: "Sold Possession",
            description: "You sold your \(possession.name) for $\(Int(sellValue)).",
            type: .financial,
            year: currentYear,
            outcome: "The money has been added to your account.",
            effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(sellValue))]
        )
        currentEvents.append(sellEvent)
        character.lifeEvents.append(sellEvent)
        
        self.character = character
        return true
    }
    
    func lookForJob() -> [Career] {
        guard let character = self.character else { return [] }
        
        // Age check
        if character.age < 18 {
            // Create too young event
            let tooYoungEvent = LifeEvent(
                title: "Too Young to Work",
                description: "You need to be at least 18 to get a full-time job.",
                type: .career,
                year: currentYear,
                outcome: "Wait until you're older.",
                effects: []
            )
            currentEvents.append(tooYoungEvent)
            
            // For teens, could offer part-time jobs here if we wanted
            return []
        }
        
        // Education-based job offerings
        var possibleCareers: [Career] = []
        
        // Get salary range based on education
        let (minSalary, maxSalary) = salaryRangeForEducation(character.education)
        
        // Generate 1-3 random job offerings
        let jobCount = Int.random(in: 1...3)
        
        let companies = ["TechCorp", "GlobalEnterprises", "InnovateInc", "NextGen Systems", 
                        "Apex Industries", "Horizon Group", "FutureWorks", "OmniCorp", 
                        "Stellar Solutions", "PrimeSoft"]
        
        for _ in 0..<jobCount {
            let company = companies.randomElement() ?? "Company"
            let salary = Double.random(in: minSalary...maxSalary)
            
            // Job title based on education
            let title: String
            switch character.education {
            case .none, .elementarySchool, .middleSchool, .highSchool:
                let titles = ["Retail Assistant", "Server", "Cashier", "Warehouse Worker", "Delivery Driver"]
                title = titles.randomElement() ?? "Entry Level Worker"
            case .associatesDegree:
                let titles = ["Administrative Assistant", "Technical Support", "Sales Associate", "Junior Developer"]
                title = titles.randomElement() ?? "Associate"
            case .bachelorsDegree:
                let titles = ["Software Developer", "Marketing Specialist", "Accountant", "HR Coordinator"]
                title = titles.randomElement() ?? "Professional"
            case .mastersDegree:
                let titles = ["Senior Developer", "Project Manager", "Financial Analyst", "Research Specialist"]
                title = titles.randomElement() ?? "Senior Professional"
            case .doctoralDegree:
                let titles = ["Research Scientist", "Director", "Principal Engineer", "Department Head"]
                title = titles.randomElement() ?? "Expert"
            }
            
            let career = Career(
                title: title,
                company: company,
                salary: salary,
                performanceRating: Int.random(in: 40...70), // Starting performance
                yearsAtJob: 0
            )
            
            possibleCareers.append(career)
        }
        
        return possibleCareers
    }
    
    func acceptJob(career: Career) {
        guard var character = self.character else { return }
        
        // If they already have a job, create a job transition event
        if character.career != nil {
            let oldCareer = character.career!
            let jobChangeEvent = LifeEvent(
                title: "Changed Jobs",
                description: "You left your position as \(oldCareer.title) at \(oldCareer.company).",
                type: .career,
                year: currentYear,
                outcome: "You now work as \(career.title) at \(career.company).",
                effects: []
            )
            currentEvents.append(jobChangeEvent)
            character.lifeEvents.append(jobChangeEvent)
        } else {
            // First job event
            let newJobEvent = LifeEvent(
                title: "New Job",
                description: "You got a job as \(career.title) at \(career.company).",
                type: .career,
                year: currentYear,
                outcome: "Your salary is $\(Int(career.salary))/year.",
                effects: [EventChoice.CharacterEffect(attribute: "happiness", change: 10)]
            )
            currentEvents.append(newJobEvent)
            character.lifeEvents.append(newJobEvent)
        }
        
        character.career = career
        self.character = character
    }
    
    func quitJob() {
        guard var character = self.character, character.career != nil else { return }
        
        let oldCareer = character.career!
        let quitEvent = LifeEvent(
            title: "Quit Job",
            description: "You quit your job as \(oldCareer.title) at \(oldCareer.company).",
            type: .career,
            year: currentYear,
            outcome: "You are now unemployed.",
            effects: [EventChoice.CharacterEffect(attribute: "happiness", change: 5)]
        )
        currentEvents.append(quitEvent)
        character.lifeEvents.append(quitEvent)
        
        character.career = nil
        self.character = character
    }
    
    // Helper to determine salary range based on education
    private func salaryRangeForEducation(_ education: Education) -> (Double, Double) {
        switch education {
        case .none, .elementarySchool, .middleSchool:
            return (20000, 30000)
        case .highSchool:
            return (25000, 45000)
        case .associatesDegree:
            return (35000, 60000)
        case .bachelorsDegree:
            return (50000, 90000)
        case .mastersDegree:
            return (70000, 120000)
        case .doctoralDegree:
            return (90000, 180000)
        }
    }
}