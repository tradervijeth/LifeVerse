//
//  GameManager.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation
import SwiftUI
import Combine

class GameManager: ObservableObject {
    @Published var character: Character?
    @Published var currentYear: Int = Calendar.current.component(.year, from: Date())
    @Published var gameStarted: Bool = false
    @Published var gameEnded: Bool = false
    @Published var currentEvents: [LifeEvent] = []
    @Published var bankManager: BankManager = BankManager()
    @Published var bankingSystem: BankingSystem? = nil
    @Published var bankingIntegration: BankingSystemIntegration? = nil
    @Published var showingRelationshipDetailView: Bool = false
    @Published var selectedRelationshipId: UUID? = nil
    @Published var showBankingView: Bool = false
    @Published var showPropertyInvestmentView: Bool = false

    private let contentManager = ContentManager()
    private var bankingSubscriptions = Set<AnyCancellable>()

    init() {
        // Set up notification observer for property purchases
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePropertyPurchase),
            name: NSNotification.Name("PropertyPurchaseCompleted"),
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func handlePropertyPurchase(notification: Notification) {
        guard var character = self.character,
              let userInfo = notification.userInfo,
              let propertyValue = userInfo["propertyValue"] as? Double,
              let downPayment = userInfo["downPayment"] as? Double,
              let isRental = userInfo["isRental"] as? Bool,
              let year = userInfo["year"] as? Int else {
            return
        }

        // Sync character's money with BankManager
        character.money = bankManager.getCharacterMoney()

        // Create property purchase event
        let eventTitle = isRental ? "Investment Property Purchase" : "Home Purchase"
        let description = isRental ?
            "You purchased an investment property for $\(Int(propertyValue).formattedWithSeparator())." :
            "You purchased a home for $\(Int(propertyValue).formattedWithSeparator())."

        let details = "You made a down payment of $\(Int(downPayment).formattedWithSeparator())."

        let purchaseEvent = LifeEvent(
            title: eventTitle,
            description: description,
            type: .financial,
            year: year,
            outcome: details,
            effects: [
                EventChoice.CharacterEffect(attribute: "money", change: -Int(downPayment))
            ]
        )

        currentEvents.append(purchaseEvent)
        character.lifeEvents.append(purchaseEvent)

        // If this is a home purchase (not rental), update character's residence
        if !isRental {
            character.residence = .house
        }

        self.character = character
    }

    func startNewGame(name: String, birthYear: Int, gender: Gender) {
        character = Character(name: name, birthYear: birthYear, gender: gender)
        currentYear = birthYear
        gameStarted = true
        gameEnded = false

        // Initialize bank manager
        bankManager = BankManager()
        bankManager.characterBirthYear = birthYear
        if let character = character {
            bankManager.setCharacterMoney(character.money)
            print("DEBUG: Setting character money in BankManager: \(character.money)")
        }
        MarketCondition.setCurrentYear(currentYear)
        print("DEBUG: Bank manager initialized, has \(bankManager.getPropertyInvestments().count) properties")

        // Initialize banking system and integration
        initializeBankingSystem()

        // Add birth event
        let birthEvent = LifeEvent(
            title: "Birth",
            description: "You were born in \(birthYear).",
            type: .birth,
            year: birthYear
        )

        // Generate family and backstory
        generateFamilyAndBackstory()

        character?.lifeEvents.append(birthEvent)
        currentEvents = [birthEvent]
    }

    // Initialize the banking system and integration
    private func initializeBankingSystem() {
        // Create central bank and banking system
        let centralBank = CentralBank()
        bankingSystem = BankingSystem(centralBank: centralBank, bankManager: bankManager)

        // Create the banking integration
        bankingIntegration = BankingSystemIntegration(gameManager: self)

        // Subscribe to banking notifications
        bankingIntegration?.notificationPublisher
            .sink { [weak self] notification in
                // Create a notification event
                let event = LifeEvent(
                    title: "Financial Update",
                    description: notification,
                    type: .financial,
                    year: self?.currentYear ?? Calendar.current.component(.year, from: Date()),
                    outcome: nil
                )

                // Add event to current events
                self?.currentEvents.append(event)

                // Also add to character's life events
                if var character = self?.character {
                    character.lifeEvents.append(event)
                    self?.character = character
                }
            }
            .store(in: &bankingSubscriptions)
    }

    // Generates family relationships and backstory for the character
    private func generateFamilyAndBackstory() {
        guard var character = self.character else { return }

        // Parent names (diverse list)
        let femaleNames = ["Maria", "Sarah", "Jennifer", "Michelle", "Aisha", "Priya", "Kim", "Fatima", "Chen", "Lakshmi"]
        let maleNames = ["James", "David", "Mohammad", "Carlos", "Wei", "Jamal", "Raj", "Mikhail", "Juan", "Michael"]

        // Create mother
        let motherName = femaleNames.randomElement() ?? "Anne"
        let motherAge = Int.random(in: 25...40)
        let motherBirthYear = character.birthYear - motherAge
        let mother = Relationship(
            name: motherName,
            type: .parent,
            closeness: Int.random(in: 50...95),
            years: character.age
        )

        // Create father
        let fatherName = maleNames.randomElement() ?? "John"
        let fatherAge = Int.random(in: 25...45)
        let fatherBirthYear = character.birthYear - fatherAge
        let father = Relationship(
            name: fatherName,
            type: .parent,
            closeness: Int.random(in: 40...95),
            years: character.age
        )

        // Add parents to relationships
        character.relationships.append(mother)
        character.relationships.append(father)

        // Add siblings (30% chance of having 1-3 siblings)
        if Int.random(in: 1...100) <= 30 {
            let siblingCount = Int.random(in: 1...3)
            for _ in 0..<siblingCount {
                let isBrother = Bool.random()
                let siblingName = isBrother ? maleNames.randomElement()! : femaleNames.randomElement()!

                // Age difference (-5 to +5 years from character)
                let ageDifference = Int.random(in: -5...5)
                let siblingBirthYear = character.birthYear + ageDifference

                // Only add if the sibling would be born after the parents
                if siblingBirthYear > motherBirthYear + 16 && siblingBirthYear > fatherBirthYear + 16 {
                    let sibling = Relationship(
                        name: siblingName,
                        type: .sibling,
                        closeness: Int.random(in: 40...90),
                        years: min(character.age, currentYear - siblingBirthYear)
                    )
                    character.relationships.append(sibling)
                }
            }
        }

        // Initialize metadata
        character.metadata = character.metadata ?? [:]

        // Add family background event - appears at birth
        let familyStructures = [
            "Your family struggled financially, but was always rich in love and support.",
            "Your parents were immigrants who worked tirelessly to build a new life.",
            "You were born into a traditional household with strong cultural values.",
            "You were born into a loving home with both parents who supported all your interests.",
            "Your parents divorced when you were young, but both remained active in your life.",
            "You were raised primarily by your mother, who worked hard to provide for you.",
            "Your father's job meant the family moved frequently, exposing you to different places.",
            "You were born into a large extended family with grandparents living in the same house.",
            "Your parents were strict but fair, emphasizing education and hard work.",
            "You come from a creative family where arts and self-expression were encouraged."
        ]

        let familyBackstory = familyStructures.randomElement() ?? familyStructures[0]
        let backstoryEvent = LifeEvent(
            title: "Family Background",
            description: familyBackstory,
            type: .relationship,
            year: character.birthYear,
            outcome: "Your family relationships helped shape your early development.",
            effects: [
                EventChoice.CharacterEffect(attribute: "happiness", change: Int.random(in: -5...10))
            ]
        )

        // Only add the birth and family background at start
        character.lifeEvents.append(backstoryEvent)

        // Store future events in metadata

        // Store personality trait info for age 4-6
        let personalityTraits = [
            "As a child, you were naturally curious, always exploring and asking questions.",
            "You showed remarkable creativity from an early age, making art and telling stories.",
            "You were cautious and thoughtful, carefully considering your actions.",
            "You had a bold, adventurous spirit, always ready to try new things.",
            "You were sensitive and empathetic, deeply caring about others' feelings.",
            "Your natural leadership qualities emerged early, organizing games with other children.",
            "You were introverted but observant, taking in everything around you.",
            "You had a strong sense of justice and fairness from a young age.",
            "You were a natural performer who loved being the center of attention.",
            "Your analytical mind made you question everything and seek logical explanations."
        ]

        let personalityAge = Int.random(in: 4...6)
        let personalityTrait = personalityTraits.randomElement() ?? personalityTraits[0]

        character.setMetadataValue(personalityAge, forKey: "personalityAge")
        character.setMetadataValue(personalityTrait, forKey: "personalityTrait")
        character.setMetadataValue(false, forKey: "personalityAdded")

        // Store formative experience info for age 7-12
        let earlyExperiences = [
            "Your early interest in reading opened up worlds of imagination for you.",
            "A childhood illness made you resilient and gave you a unique perspective on life.",
            "Moving to a new city at age 7 taught you to adapt to change and make new friends.",
            "Learning to play an instrument gave you discipline and creative expression.",
            "Being part of a youth sports team taught you about teamwork and perseverance.",
            "Time spent with a grandparent gave you wisdom beyond your years.",
            "Caring for a pet showed you the meaning of responsibility and unconditional love.",
            "A memorable teacher recognized your potential and encouraged your growth.",
            "Travel experiences broadened your horizons and sparked curiosity about the world.",
            "Overcoming a challenge boosted your confidence and taught you self-reliance."
        ]

        let formativeAge = Int.random(in: 7...12)
        let formativeExperience = earlyExperiences.randomElement() ?? earlyExperiences[0]

        character.setMetadataValue(formativeAge, forKey: "formativeAge")
        character.setMetadataValue(formativeExperience, forKey: "formativeExperience")
        character.setMetadataValue(false, forKey: "formativeAdded")

        // Store childhood choice event for age 8-12
        let pivotalAge = Int.random(in: 8...12)
        character.setMetadataValue(pivotalAge, forKey: "pivotalAge")
        character.setMetadataValue(false, forKey: "pivotalEventAdded")

        self.character = character
    }

    // Generates event choices for the character's youth
    private func generateEarlyChildhoodChoices() {
        guard let character = self.character else { return }

        // Choose a random pivotal childhood event for the current age
        let events = [
            // Academic aptitude event
            LifeEvent(
                title: "School Project",
                description: "Your class is working on an important project. How do you approach it?",
                type: .school,
                year: currentYear,
                choices: [
                    EventChoice(
                        text: "Work extra hard to make it exceptional",
                        outcome: "Your dedication paid off. The teacher was impressed and you discovered your academic potential.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "intelligence", change: 15),
                            EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                        ]
                    ),
                    EventChoice(
                        text: "Do enough to get by, focus on having fun",
                        outcome: "You enjoyed your childhood, focusing on play rather than academics.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 10)
                        ]
                    )
                ]
            ),

            // Athletic ability event
            LifeEvent(
                title: "Sports Tryout",
                description: "Your school is forming a sports team and holding tryouts. Do you participate?",
                type: .random,
                year: currentYear,
                choices: [
                    EventChoice(
                        text: "Train hard and give it your all",
                        outcome: "Your determination helped you develop athletic skills and make the team.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "athleticism", change: 15),
                            EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                        ]
                    ),
                    EventChoice(
                        text: "Skip it and focus on other interests",
                        outcome: "You pursued different talents, finding your strengths elsewhere.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "intelligence", change: 8),
                            EventChoice.CharacterEffect(attribute: "happiness", change: 3)
                        ]
                    )
                ]
            ),

            // Social skills event
            LifeEvent(
                title: "New Kid in School",
                description: "A new student joins your class and seems lonely. What do you do?",
                type: .relationship,
                year: currentYear,
                choices: [
                    EventChoice(
                        text: "Make an effort to befriend them",
                        outcome: "You became good friends and developed your social skills and empathy.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 10),
                            EventChoice.CharacterEffect(attribute: "looks", change: 5) // Representing social confidence
                        ]
                    ),
                    EventChoice(
                        text: "Focus on your existing friend group",
                        outcome: "You strengthened your current friendships but missed an opportunity to expand your circle.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                        ]
                    )
                ]
            ),

            // Personal challenge event
            LifeEvent(
                title: "Family Challenge",
                description: "Your family faces a difficult situation requiring everyone to adapt. How do you respond?",
                type: .relationship,
                year: currentYear,
                choices: [
                    EventChoice(
                        text: "Step up and take on responsibilities",
                        outcome: "You developed maturity and resilience by helping your family through the tough time.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "intelligence", change: 8),
                            EventChoice.CharacterEffect(attribute: "happiness", change: -5),
                            EventChoice.CharacterEffect(attribute: "health", change: 10) // Mental resilience
                        ]
                    ),
                    EventChoice(
                        text: "Rely on your parents to handle it",
                        outcome: "Your parents shielded you from the challenges, allowing you to maintain your childhood innocence.",
                        effects: [
                            EventChoice.CharacterEffect(attribute: "happiness", change: 5),
                            EventChoice.CharacterEffect(attribute: "health", change: 5)
                        ]
                    )
                ]
            )
        ]

        // Add a random event to current events so player can make choices
        let randomEvent = events.randomElement()!
        currentEvents.append(randomEvent)

        self.character = character
    }

    func advanceYear() {
        guard var character = character, character.isAlive else {
            gameEnded = true
            return
        }

        // Clear previous year's events to avoid duplication
        currentEvents = []

        currentYear += 1
        MarketCondition.setCurrentYear(currentYear)

        // Process banking updates using the new banking system
        if let bankingIntegration = bankingIntegration {
            let bankingNotifications = bankingIntegration.processYearlyUpdate(newYear: currentYear)

            // Create events from banking notifications
            for notification in bankingNotifications {
                let event = LifeEvent(
                    title: "Banking Update",
                    description: notification,
                    type: .financial,
                    year: currentYear
                )
                currentEvents.append(event)
                character.lifeEvents.append(event)
            }
        } else {
            // Fallback to legacy bank manager if integration unavailable
            let bankingEvents = bankManager.processYearlyUpdate(currentYear: currentYear)

            // Add banking events to current events
            for event in bankingEvents {
                currentEvents.append(event)
                character.lifeEvents.append(event)
            }
        }

        // Process automatic events
        let newEvents = character.ageUp()

        for event in newEvents {
            if event.choices == nil && event.effects != nil {
                applyEventEffects(event.effects!, to: &character)
            }
        }

        // Check for age-specific events now that we've aged up
        checkAndAddAgeSpecificEvents()

        // Process annual salary for employed characters
        if let career = character.career {
            // Add annual salary to money
            character.money += career.salary

            // Create transaction for salary - only create one transaction now to avoid duplicates
            let salaryTransaction = Banking_Transaction(
                date: Date(),
                type: .directDeposit,
                amount: career.salary,
                description: "Annual salary from \(career.company) as \(career.title)",
                year: currentYear
            )

            // Check for existing salary transaction this year to avoid duplicates
            let duplicateTransaction = bankManager.transactionHistory.first {
                $0.year == currentYear &&
                $0.type == .directDeposit &&
                $0.description.contains(career.company) &&
                $0.description.contains(career.title)
            }

            if duplicateTransaction == nil {
                bankManager.transactionHistory.append(salaryTransaction)
            }

            // Create salary income event
            let salaryEvent = LifeEvent(
                title: "Annual Income",
                description: "You earned your annual salary as \(career.title) at \(career.company).",
                type: .financial,
                year: currentYear,
                outcome: "You received $\(Int(career.salary).formattedWithSeparator()) in income.",
                effects: [EventChoice.CharacterEffect(attribute: "money", change: Int(career.salary))]
            )

            currentEvents.append(salaryEvent)
            character.lifeEvents.append(salaryEvent)

            // Increment years at job
            var updatedCareer = career
            updatedCareer.yearsAtJob += 1
            character.career = updatedCareer

            // For adults (18+), automatically deposit earnings into a bank account
            if character.age >= 18 {
                autoDepositEarnings(amount: career.salary)
            }
        }

        // Age up existing relationships with improved mechanics
        var relationshipsToRemove: [UUID] = []

        for i in 0..<character.relationships.count {
            // Initialize traits if they don't exist yet
            if character.relationships[i].traits.isEmpty {
                character.relationships[i].generateRandomTraits(characterIntelligence: character.intelligence)
            }

            // Age up the relationship and check if it should continue
            let relationshipSurvived = character.relationships[i].ageUp(
                currentYear: currentYear,
                characterLuck: Int.random(in: 0...100), // Random luck factor
                characterHappiness: character.happiness
            )

            // If relationship didn't survive, mark for removal
            if !relationshipSurvived {
                relationshipsToRemove.append(character.relationships[i].id)

                // Create a relationship ending event
                let name = character.relationships[i].name
                let type = character.relationships[i].type
                let endingEvent = LifeEvent(
                    title: type == .significantOther || type == .spouse ? "Breakup" : "Relationship Ended",
                    description: "Your relationship with \(name) came to an end.",
                    type: .relationship,
                    year: currentYear,
                    outcome: "You've grown apart and decided to part ways.",
                    effects: [EventChoice.CharacterEffect(attribute: "happiness", change: -10)]
                )
                currentEvents.append(endingEvent)
                character.lifeEvents.append(endingEvent)

                // If it was a spouse, update marital status
                if type == .spouse {
                    character.isMarried = false
                    character.spouseRelationshipId = nil
                }
            }
        }

        // Remove failed relationships
        character.relationships.removeAll { relationshipsToRemove.contains($0.id) }

        // Check for relationship milestone events
        for relationship in character.relationships where relationship.type == .significantOther || relationship.type == .spouse {
            if let milestoneEvent = RelationshipEvents.generateRelationshipMilestoneEvent(for: character, relationship: relationship) {
                currentEvents.append(milestoneEvent)
                character.lifeEvents.append(milestoneEvent)
            }

            // Check for wedding event if engaged
            if let weddingEvent = RelationshipEvents.generateWeddingEvent(for: character, relationship: relationship) {
                currentEvents.append(weddingEvent)
                character.lifeEvents.append(weddingEvent)
            }
        }

        // Check for potential new relationships
        if character.age >= 5 && Int.random(in: 1...100) <= (30 - min(20, character.relationships.count * 3)) {
            if let newRelationshipEvent = RelationshipEvents.generateNewRelationshipEvent(for: character) {
                currentEvents.append(newRelationshipEvent)
                character.lifeEvents.append(newRelationshipEvent)
            }
        }

        // Check for relationship issues
        for relationship in character.relationships where relationship.years >= 1 {
            if Int.random(in: 1...100) <= 15 { // 15% chance per relationship per year
                if let issueEvent = RelationshipEvents.generateRelationshipIssueEvent(for: character, relationship: relationship) {
                    currentEvents.append(issueEvent)
                    character.lifeEvents.append(issueEvent)
                }
            }
        }

        // Update bank manager with character's current money
        bankManager.setCharacterMoney(character.money)

        // Check for potential job promotion
        checkForPromotion()

        // Check for retirement
        if character.age >= 65 {
            let retirementEvent = LifeEvent(
                title: "Retirement",
                description: "You retired at age \(character.age).",
                type: .retirement,
                year: currentYear,
                outcome: "You're enjoying your retirement.",
                effects: [EventChoice.CharacterEffect(attribute: "happiness", change: 10)]
            )
            currentEvents.append(retirementEvent)
            character.lifeEvents.append(retirementEvent)
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

        // Process mortgage payments for properties and create mortgage payment events
        let mortgageEvents = processMortgagePayments()
        for event in mortgageEvents {
            currentEvents.append(event)
            character.lifeEvents.append(event)
        }

        self.character = character

        // Add the new events to the current events list, avoiding duplicates
        // First get any automatic events (like expenses) we generated
        let autoEvents = character.lifeEvents.filter { event in
            return event.year == currentYear &&
                   !newEvents.contains { $0.id == event.id }
        }

        // Merge the events and filter out any duplicates by comparing titles and types
        let combinedEvents = autoEvents + newEvents
        currentEvents = []

        // Track already added event types to prevent duplicates
        var addedEventIdentifiers = Set<String>()

        for event in combinedEvents {
            // Create a unique identifier for this type of event
            let eventIdentifier = "\(event.title)_\(event.type.rawValue)"

            // Only add if we haven't seen this type of event yet
            if !addedEventIdentifiers.contains(eventIdentifier) {
                currentEvents.append(event)
                addedEventIdentifiers.insert(eventIdentifier)
            }
        }

        if !character.isAlive {
            gameEnded = true
        }

        // Auto-save the game after each year
        _ = SaveSystem.saveGame(gameManager: self)
    }

    // Process mortgage payments for all properties
    private func processMortgagePayments() -> [LifeEvent] {
        var events: [LifeEvent] = []
        guard var character = character else { return events }

        let propertyInvestments = bankManager.getPropertyInvestments()
        var totalMortgagePayments: Double = 0

        for var property in propertyInvestments {
            // Skip properties without mortgages
            guard let mortgageId = property.mortgageId,
                  let _ = bankManager.getAccount(id: mortgageId) else { continue }

            // Update property mortgage remaining years
            let yearsPassed = currentYear - property.purchaseYear
            let originalTerm = property.mortgageTerm
            property.mortgageYearsRemaining = max(0, originalTerm - yearsPassed)

            // Update equity percentage based on elapsed time
            let percentPaid = min(1.0, Double(yearsPassed) / Double(originalTerm))
            property.equityPercentage = percentPaid

            // Calculate annual mortgage payment
            let annualPayment = property.calculateAnnualMortgagePayment(bankManager: bankManager, currentYear: currentYear)

            if annualPayment > 0 {
                // For non-rental properties, the character has to pay from their cash
                if !property.isRental {
                    // Deduct payment from character's money
                    character.money -= annualPayment
                    totalMortgagePayments += annualPayment

                    // Create a mortgage payment event
                    let paymentEvent = LifeEvent(
                        title: "Mortgage Payment",
                        description: "Annual mortgage payment for your property.",
                        type: .financial,
                        year: currentYear,
                        outcome: "You paid $\(Int(annualPayment).formattedWithSeparator()) for your mortgage this year. \(property.mortgageYearsRemaining) years remaining.",
                        effects: [EventChoice.CharacterEffect(attribute: "money", change: -Int(annualPayment))]
                    )
                    events.append(paymentEvent)
                }
            }

            // Update the property in the bank manager
            if let index = bankManager.propertyInvestments.firstIndex(where: { $0.id == property.id }) {
                bankManager.propertyInvestments[index] = property
            }
        }

        // Update character with payment deductions
        self.character = character

        return events
    }

    // Checks and adds age-specific events when character reaches the appropriate age
    private func checkAndAddAgeSpecificEvents() {
        guard var character = self.character else { return }

        // Check for personality trait event (age 4-6)
        if let personalityAge = character.getMetadataValue(forKey: "personalityAge") as? Int,
           let personalityAdded = character.getMetadataValue(forKey: "personalityAdded") as? Bool,
           !personalityAdded,
           character.age == personalityAge,
           let personalityTrait = character.getMetadataValue(forKey: "personalityTrait") as? String {

            // Create and add the personality event
            let personalityEvent = LifeEvent(
                title: "Childhood Personality",
                description: personalityTrait,
                type: .random,
                year: currentYear,
                outcome: "These tendencies influenced your development.",
                effects: [
                    EventChoice.CharacterEffect(attribute: "intelligence", change: Int.random(in: 0...5)),
                    EventChoice.CharacterEffect(attribute: "happiness", change: Int.random(in: 0...5))
                ]
            )

            character.lifeEvents.append(personalityEvent)
            currentEvents.append(personalityEvent)

            // Apply the effects
            if let effects = personalityEvent.effects {
                for effect in effects {
                    applyEffectToCharacter(effect: effect, to: &character)
                }
            }

            // Mark as added
            character.setMetadataValue(true, forKey: "personalityAdded")
            self.character = character
        }

        // Check for formative experience event (age 7-12)
        if let formativeAge = character.getMetadataValue(forKey: "formativeAge") as? Int,
           let formativeAdded = character.getMetadataValue(forKey: "formativeAdded") as? Bool,
           !formativeAdded,
           character.age == formativeAge,
           let formativeExperience = character.getMetadataValue(forKey: "formativeExperience") as? String {

            // Create and add the formative experience event
            let experienceEvent = LifeEvent(
                title: "Formative Experience",
                description: formativeExperience,
                type: .random,
                year: currentYear,
                outcome: "This experience had a lasting impact on your life.",
                effects: [
                    EventChoice.CharacterEffect(attribute: "intelligence", change: Int.random(in: 0...5)),
                    EventChoice.CharacterEffect(attribute: "happiness", change: Int.random(in: 0...5))
                ]
            )

            character.lifeEvents.append(experienceEvent)
            currentEvents.append(experienceEvent)

            // Apply the effects
            if let effects = experienceEvent.effects {
                for effect in effects {
                    applyEffectToCharacter(effect: effect, to: &character)
                }
            }

            // Mark as added
            character.setMetadataValue(true, forKey: "formativeAdded")
            self.character = character
        }

        // Check for pivotal choice event (age 8-12)
        if let pivotalAge = character.getMetadataValue(forKey: "pivotalAge") as? Int,
           let pivotalEventAdded = character.getMetadataValue(forKey: "pivotalEventAdded") as? Bool,
           !pivotalEventAdded,
           character.age == pivotalAge {

            // Add the pivotal choice event
            generateEarlyChildhoodChoices()

            // Mark as added
            character.setMetadataValue(true, forKey: "pivotalEventAdded")
            self.character = character
        }
    }

    // Helper function to apply a single effect to a character
    private func applyEffectToCharacter(effect: EventChoice.CharacterEffect, to character: inout Character) {
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
        case "education_level":
            // Convert numerical level to Education enum
            if effect.change == 1 {
                character.education = .elementarySchool
            } else if effect.change == 2 {
                character.education = .middleSchool
            } else if effect.change == 3 {
                character.education = .highSchool
            } else if effect.change == 4 {
                character.education = .associatesDegree
            } else if effect.change == 5 {
                character.education = .bachelorsDegree
            } else if effect.change == 6 {
                character.education = .mastersDegree
            } else if effect.change == 7 {
                character.education = .doctoralDegree
            }
        // Handle degree fields
        case "degree_field_cs":
            character.degreeField = .computerScience
        case "degree_field_eng":
            character.degreeField = .engineering
        case "degree_field_bio":
            character.degreeField = .biology
        case "degree_field_nursing":
            character.degreeField = .nursing
        case "degree_field_business":
            character.degreeField = .business
        case "degree_field_arts":
            character.degreeField = .fineArts
        case "degree_field_psych":
            character.degreeField = .psychology
        case "degree_field_edu":
            character.degreeField = .education
        case "degree_field_undeclared":
            character.degreeField = .undeclared
        default:
            break
        }
    }

    private func applyEventEffects(_ effects: [EventChoice.CharacterEffect], to character: inout Character) {
        var moneyEarned: Double = 0

        for effect in effects {
            applyEffectToCharacter(effect: effect, to: &character)

            // Track money earnings for auto-deposit
            if effect.attribute == "money" && effect.change > 0 && character.age >= 18 {
                moneyEarned += Double(effect.change)
            }
        }

        // Auto-deposit any earned money for adults
        if moneyEarned > 0 && character.age >= 18 {
            // Save the character state before auto-depositing
            self.character = character
            autoDepositEarnings(amount: moneyEarned)
            // Restore the character state after auto-deposit updates it
            character = self.character ?? character
        }
    }

    func makeChoice(for event: LifeEvent, choice: EventChoice) {
        // Apply effects of the choice to the character
        guard var character = self.character else { return }

        var moneyEarned: Double = 0

        for effect in choice.effects {
            // Apply the effect using our helper method
            applyEffectToCharacter(effect: effect, to: &character)

            // Track money earnings for auto-deposit
            if effect.attribute == "money" && effect.change > 0 && character.age >= 18 {
                moneyEarned += Double(effect.change)
            }

            // Process relationship effects
            if effect.attribute.starts(with: "relationship_") ||
               effect.attribute.starts(with: "new_") {
                processRelationshipEventEffect(effect: effect)
            }
        }

        // Update the event with the chosen outcome in the character's life history
        if let index = character.lifeEvents.firstIndex(where: { $0.id == event.id }) {
            character.lifeEvents[index].outcome = choice.outcome
        } else {
            // If event isn't in character's life events yet, add it with the outcome
            var eventWithOutcome = event
            eventWithOutcome.outcome = choice.outcome
            character.lifeEvents.append(eventWithOutcome)
        }

        // REMOVE THE EVENT FROM CURRENT EVENTS - this is the key fix
        if let index = currentEvents.firstIndex(where: { $0.id == event.id }) {
            // Remove the event from current events so it doesn't show up again
            currentEvents.remove(at: index)
        }

        // Handle event chaining
        if let linkedEventId = choice.leadsTo,
           let _ = currentEvents.first(where: { $0.eventIdentifier == linkedEventId }) {
            // Move the linked event to the start of currentEvents to ensure it's shown next
            if let index = currentEvents.firstIndex(where: { $0.eventIdentifier == linkedEventId }) {
                let eventToMove = currentEvents.remove(at: index)
                currentEvents.insert(eventToMove, at: 0)
            }
        }

        // Handle relationship events
        if event.type == .relationship {
            if event.title == "New Relationship" && choice.text.contains("Start dating") {
                // Create a romantic relationship
                let names = ["Alex", "Jordan", "Taylor", "Morgan", "Riley", "Avery", "Casey", "Quinn"]
                let randomName = names.randomElement() ?? "Sam"
                let newRelationship = Relationship(
                    name: randomName,
                    type: .significantOther,
                    closeness: 60,
                    years: 0
                )
                character.relationships.append(newRelationship)
            } else if event.title == "Potential Friendship" && choice.text.contains("Make friends") {
                // Create a friendship
                let names = ["Jamie", "Pat", "Chris", "Reese", "Drew", "Skyler", "Blake", "Frankie"]
                let randomName = names.randomElement() ?? "Robin"
                let newRelationship = Relationship(
                    name: randomName,
                    type: .friend,
                    closeness: 50,
                    years: 0
                )
                character.relationships.append(newRelationship)
            }
        }

        // Auto-deposit any earned money for adults
        if moneyEarned > 0 && character.age >= 18 {
            self.character = character
            autoDepositEarnings(amount: moneyEarned)
            // Update character var with potentially modified state from autoDepositEarnings
            if let updatedChar = self.character {
                character = updatedChar
            }
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
                        "Stellar Solutions", "PrimeSoft", "MedicaHealth", "EduLearn",
                        "FinanceFirst", "Legal Eagles", "Construct Pro"]

        // Determine career level based on experience and education
        let level: CareerLevel
        if character.career == nil {
            level = .entry
        } else if character.career!.yearsAtJob >= 5 {
            level = .mid
        } else if character.career!.yearsAtJob >= 2 {
            level = .junior
        } else {
            level = .entry
        }

        // Create industry-specific job pools based on degree field
        var preferredIndustries: [Industry] = []
        var preferredFields: [DegreeField?] = [nil] // Always include null for fields without specific requirements

        if let degreeField = character.degreeField {
            // Add the character's field
            preferredFields.append(degreeField)

            // Determine industries based on degree field
            switch degreeField {
            case .computerScience, .engineering:
                preferredIndustries.append(.technology)
            case .medicine, .nursing, .pharmacy, .biology, .publicHealth:
                preferredIndustries.append(.healthcare)
            case .business, .accounting, .finance, .marketing, .economics:
                preferredIndustries.append(.finance)
                preferredIndustries.append(.retail)
            case .education:
                preferredIndustries.append(.education)
            case .law, .criminalJustice:
                preferredIndustries.append(.legal)
                preferredIndustries.append(.government)
            case .fineArts, .literature:
                preferredIndustries.append(.entertainment)
            default:
                // For other fields, add some generic industries
                preferredIndustries.append(.retail)
                preferredIndustries.append(.hospitality)
            }
        } else {
            // If no degree field, add general industries
            preferredIndustries = [.retail, .hospitality, .manufacturing]
        }

        // If no preferred industries were set, include all industries
        if preferredIndustries.isEmpty {
            preferredIndustries = Industry.allCases.shuffled()
        }

        // Generate job offers
        for _ in 0..<jobCount {
            // Choose random company and industry (weighted toward preferred)
            let company = companies.randomElement() ?? "Company"
            let usePreferredIndustry = Double.random(in: 0...1) < 0.7 // 70% chance to use preferred
            let industry = usePreferredIndustry ?
                preferredIndustries.randomElement() ?? Industry.allCases.randomElement()! :
                Industry.allCases.randomElement()!

            // Calculate salary
            let baseSalary = Double.random(in: minSalary...maxSalary)
            let salary: Double

            // Adjust salary based on career level
            switch level {
            case .entry:
                salary = baseSalary * 1.0
            case .junior:
                salary = baseSalary * 1.2
            case .mid:
                salary = baseSalary * 1.5
            case .senior:
                salary = baseSalary * 2.0
            case .lead:
                salary = baseSalary * 2.5
            case .manager:
                salary = baseSalary * 3.0
            case .director:
                salary = baseSalary * 4.0
            case .executive:
                salary = baseSalary * 5.0
            case .cLevel:
                salary = baseSalary * 7.0
            }

            // Determine job title and specialization requirements
            let (title, fieldRequirement, specializationRequirement) = generateJobDetails(
                industry: industry,
                level: level,
                degreeField: character.degreeField,
                education: character.education
            )

            // Years required for promotion based on level
            let promotionYears: Int?
            switch level {
            case .entry:
                promotionYears = Int.random(in: 1...3)
            case .junior:
                promotionYears = Int.random(in: 2...4)
            case .mid:
                promotionYears = Int.random(in: 3...5)
            case .senior:
                promotionYears = Int.random(in: 3...6)
            case .lead, .manager:
                promotionYears = Int.random(in: 4...7)
            case .director:
                promotionYears = Int.random(in: 5...8)
            case .executive, .cLevel:
                promotionYears = nil // No promotion beyond these levels
            }

            // Create the career
            let career = Career(
                title: title,
                company: company,
                salary: salary,
                industry: industry,
                level: level,
                educationRequirement: character.education,
                performanceRating: Int.random(in: 40...70),
                yearsAtJob: 0,
                fieldRequirement: fieldRequirement,
                specializationRequirement: specializationRequirement,
                promotionYearsRequired: promotionYears,
                maxSalary: salary * 1.5
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

    // Creates and adds a new event
    func createEvent(title: String, description: String, type: LifeEvent.EventType, outcome: String? = nil, effects: [EventChoice.CharacterEffect] = []) {
        guard var character = self.character else { return }

        let newEvent = LifeEvent(
            title: title,
            description: description,
            type: type,
            year: currentYear,
            outcome: outcome,
            effects: effects.isEmpty ? nil : effects
        )

        currentEvents.append(newEvent)
        character.lifeEvents.append(newEvent)
        self.character = character
    }

    // Auto-deposit earnings into a bank account for characters 18+
    private func autoDepositEarnings(amount: Double) {
        guard var character = self.character, character.age >= 18 else { return }

        // Use banking integration if available
        if let bankingIntegration = bankingIntegration {
            let checkingAccounts = bankingIntegration.getActiveAccounts().filter {
                $0.accountType == .checking
            }

            // If no checking account, try to open one
            if checkingAccounts.isEmpty {
                // Keep a small amount in cash and deposit the rest
                let cashToKeep = min(1000.0, character.money * 0.1)
                let depositAmount = character.money - cashToKeep

                if depositAmount > 0 {
                    // Open a new checking account
                    let (account, _) = bankingIntegration.openAccount(
                        type: .checking,
                        initialDeposit: depositAmount
                    )

                    if account != nil {
                        // Deduct the deposited amount from character's cash
                        character.money = cashToKeep

                        // Create an account opening event
                        let accountEvent = LifeEvent(
                            title: "Opened Bank Account",
                            description: "You opened a checking account.",
                            type: .financial,
                            year: currentYear,
                            outcome: "You deposited $\(Int(depositAmount).formattedWithSeparator()) into your new account.",
                            effects: []
                        )
                        currentEvents.append(accountEvent)
                        character.lifeEvents.append(accountEvent)

                        self.character = character
                    }
                }
            } else {
                // Deposit earnings into existing checking account
                // Keep a small amount in cash (10%) and deposit the rest
                let earnings = amount
                let depositAmount = earnings * 0.9

                if depositAmount > 0 && checkingAccounts.first != nil {
                    if bankingIntegration.deposit(accountId: checkingAccounts.first!.id, amount: depositAmount) {
                        // Create a deposit event
                        let depositEvent = LifeEvent(
                            title: "Auto-Deposit",
                            description: "Your earnings were automatically deposited.",
                            type: .financial,
                            year: currentYear,
                            outcome: "You deposited $\(Int(depositAmount).formattedWithSeparator()) into your checking account.",
                            effects: []
                        )
                        currentEvents.append(depositEvent)
                        character.lifeEvents.append(depositEvent)

                        // Adjust character's cash
                        character.money -= depositAmount
                        self.character = character
                    }
                }
            }
        } else {
            // Fallback to using bank manager directly
            // First, check if the character has a checking account
            let checkingAccounts = bankManager.getActiveAccounts().filter {
                $0.accountType == .checking
            }

            // If no checking account, try to open one
            if checkingAccounts.isEmpty {
                // Keep a small amount in cash and deposit the rest
                let cashToKeep = min(1000.0, character.money * 0.1)
                let depositAmount = character.money - cashToKeep

                if depositAmount > 0 {
                    // Open a new checking account
                    if bankManager.openAccount(
                        type: .checking,
                        initialDeposit: depositAmount
                    ) != nil {
                        // Deduct the deposited amount from character's cash
                        character.money = cashToKeep

                        // Create an account opening event
                        let accountEvent = LifeEvent(
                            title: "Opened Bank Account",
                            description: "You opened a checking account.",
                            type: .financial,
                            year: currentYear,
                            outcome: "You deposited $\(Int(depositAmount).formattedWithSeparator()) into your new account.",
                            effects: []
                        )
                        currentEvents.append(accountEvent)
                        character.lifeEvents.append(accountEvent)

                        self.character = character
                    }
                }
            } else {
                // Deposit earnings into existing checking account
                // Keep a small amount in cash (10%) and deposit the rest
                let earnings = amount
                let depositAmount = earnings * 0.9

                if depositAmount > 0 && checkingAccounts.first != nil {
                    if bankManager.deposit(accountId: checkingAccounts.first!.id, amount: depositAmount) {
                        // Create a deposit event
                        let depositEvent = LifeEvent(
                            title: "Auto-Deposit",
                            description: "Your earnings were automatically deposited.",
                            type: .financial,
                            year: currentYear,
                            outcome: "You deposited $\(Int(depositAmount).formattedWithSeparator()) into your checking account.",
                            effects: []
                        )
                        currentEvents.append(depositEvent)
                        character.lifeEvents.append(depositEvent)

                        // Adjust character's cash
                        character.money -= depositAmount
                        self.character = character
                    }
                }
            }
        }
    }

    private func saveGame() {
        // Implementation of saveGame method
    }

    // Start a new game at a specific age (teen or adult)
    func startNewGameAtAge(name: String, birthYear: Int, gender: Gender, startingAge: Int) {
        // First create a new character
        character = Character(name: name, birthYear: birthYear, gender: gender)
        currentYear = birthYear + startingAge
        gameStarted = true
        gameEnded = false

        // Initialize bank manager
        bankManager = BankManager()
        bankManager.characterBirthYear = birthYear
        MarketCondition.setCurrentYear(currentYear)

        // Initialize banking system and integration
        initializeBankingSystem()

        // Update character's age to match starting age
        if var character = self.character {
            // Set the age
            character.age = startingAge

            // Generate family and backstory
            generateFamilyAndBackstory()

            // Add birth event
            let birthEvent = LifeEvent(
                title: "Birth",
                description: "You were born in \(birthYear).",
                type: .birth,
                year: birthYear
            )
            character.lifeEvents.append(birthEvent)

            // Generate early life events based on age
            generateAgeAppropriateHistory(for: &character)

            // Setup appropriate education level based on age
            if startingAge >= 16 {
                character.education = .highSchool

                // Add high school event
                let schoolEvent = LifeEvent(
                    title: "High School",
                    description: "You've been attending high school.",
                    type: .school,
                    year: birthYear + 14,
                    outcome: "You're currently in your junior year.",
                    effects: [EventChoice.CharacterEffect(attribute: "education_level", change: 3)]
                )
                character.lifeEvents.append(schoolEvent)

                // Add a modest starting amount of money for a teen
                character.money = 250.0

                // Create friends appropriate for a teen
                addAgeAppropriateRelationships(character: &character)
            }

            if startingAge >= 21 {
                // Add college/work history for adults
                character.education = .bachelorsDegree

                // Additional setup for adults
                character.money = 2500.0

                // Add college graduation
                let collegeEvent = LifeEvent(
                    title: "College Graduation",
                    description: "You graduated from college with a bachelor's degree.",
                    type: .graduation,
                    year: birthYear + 21,
                    outcome: "You're ready to start your career.",
                    effects: [EventChoice.CharacterEffect(attribute: "education_level", change: 5)]
                )
                character.lifeEvents.append(collegeEvent)

                // Random degree field
                let fields: [DegreeField] = [.business, .computerScience, .psychology, .education, .engineering]
                character.degreeField = fields.randomElement()
            }

            // Save the updated character
            self.character = character

            // Add current events for the player to interact with
            generateCurrentEventsForAge(startingAge)
        }
    }

    // Helper function to generate age-appropriate history
    private func generateAgeAppropriateHistory(for character: inout Character) {
        // Add childhood milestones
        if character.age >= 5 {
            // Elementary school
            let elementaryEvent = LifeEvent(
                title: "Elementary School",
                description: "You started elementary school.",
                type: .school,
                year: character.birthYear + 5,
                outcome: "You learned to read, write, and made your first friends.",
                effects: [EventChoice.CharacterEffect(attribute: "education_level", change: 1)]
            )
            character.lifeEvents.append(elementaryEvent)
        }

        if character.age >= 11 {
            // Middle school
            let middleSchoolEvent = LifeEvent(
                title: "Middle School",
                description: "You moved on to middle school.",
                type: .school,
                year: character.birthYear + 11,
                outcome: "You navigated the awkward pre-teen years.",
                effects: [EventChoice.CharacterEffect(attribute: "education_level", change: 2)]
            )
            character.lifeEvents.append(middleSchoolEvent)
        }

        // Add random childhood events
        let possibleEvents = [
            "You won a school competition",
            "You had your first crush",
            "You went on a memorable family vacation",
            "You learned to ride a bike",
            "You got your first video game console",
            "Your family moved to a new neighborhood",
            "You broke your arm climbing a tree",
            "You got a pet dog",
            "You performed in a school play",
            "You joined a sports team"
        ]

        // Add 3-5 random childhood events
        let eventCount = Int.random(in: 3...5)
        let shuffledEvents = possibleEvents.shuffled()

        for i in 0..<min(eventCount, shuffledEvents.count) {
            let eventAge = Int.random(in: 6...min(15, character.age))
            let event = LifeEvent(
                title: "Childhood Memory",
                description: shuffledEvents[i],
                type: .random,
                year: character.birthYear + eventAge,
                outcome: "This experience shaped your childhood.",
                effects: [
                    EventChoice.CharacterEffect(
                        attribute: ["happiness", "intelligence", "health", "athleticism"].randomElement()!,
                        change: Int.random(in: 3...8)
                    )
                ]
            )
            character.lifeEvents.append(event)
        }
    }

    // Add age-appropriate relationships
    private func addAgeAppropriateRelationships(character: inout Character) {
        // Add 1-3 friends for a teenager
        let friendCount = Int.random(in: 1...3)
        let friendNames = ["Alex", "Jordan", "Taylor", "Morgan", "Riley", "Avery", "Casey", "Quinn", "Jamie", "Pat"]

        for _ in 0..<friendCount {
            let name = friendNames.randomElement() ?? "Friend"
            var newFriend = Relationship(
                name: name,
                type: .friend,
                closeness: Int.random(in: 60...90),
                years: Int.random(in: 1...4)  // Known for 1-4 years
            )
            newFriend.generateRandomTraits(characterIntelligence: character.intelligence)
            character.relationships.append(newFriend)
        }

        // 30% chance of having a significant other for teens
        if Int.random(in: 1...100) <= 30 {
            let oppositeSex = character.gender == .male ? "female" : "male"
            let partnerName = oppositeSex == "female" ?
                ["Emma", "Sophia", "Olivia", "Isabella", "Mia"].randomElement()! :
                ["Noah", "Liam", "William", "Mason", "James"].randomElement()!

            var partner = Relationship(
                name: partnerName,
                type: .significantOther,
                closeness: Int.random(in: 70...90),
                years: Int.random(in: 0...1)  // Dating for up to 1 year
            )
            partner.generateRandomTraits(characterIntelligence: character.intelligence)
            character.relationships.append(partner)
        }
    }

    // Generate current events based on starting age
    private func generateCurrentEventsForAge(_ age: Int) {
        if age == 16 {
            // High school specific events
            let events = [
                LifeEvent(
                    title: "Driver's License",
                    description: "You're eligible to get your driver's license. Would you like to take the test?",
                    type: .random,
                    year: currentYear,
                    choices: [
                        EventChoice(
                            text: "Take the driving test",
                            outcome: "You passed your driving test and now have your license!",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "happiness", change: 10)
                            ]
                        ),
                        EventChoice(
                            text: "Wait until later",
                            outcome: "You decided to wait before getting your license.",
                            effects: []
                        )
                    ]
                ),
                LifeEvent(
                    title: "Part-time Job",
                    description: "The local mall is hiring teenagers for part-time work. Are you interested?",
                    type: .career,
                    year: currentYear,
                    choices: [
                        EventChoice(
                            text: "Apply for the job",
                            outcome: "You got hired for $12/hour working weekends.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "money", change: 200)
                            ]
                        ),
                        EventChoice(
                            text: "Focus on school instead",
                            outcome: "You decided to focus on your studies.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "intelligence", change: 5)
                            ]
                        )
                    ]
                ),
                LifeEvent(
                    title: "College Preparation",
                    description: "Your guidance counselor asks about your plans after high school.",
                    type: .school,
                    year: currentYear,
                    choices: [
                        EventChoice(
                            text: "Plan for college",
                            outcome: "You're focusing on college preparation and studying for entrance exams.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "intelligence", change: 8)
                            ]
                        ),
                        EventChoice(
                            text: "Consider trade school",
                            outcome: "You're exploring vocational training options.",
                            effects: [
                                EventChoice.CharacterEffect(attribute: "intelligence", change: 5),
                                EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                            ]
                        ),
                        EventChoice(
                            text: "Undecided",
                            outcome: "You're keeping your options open for now.",
                            effects: []
                        )
                    ]
                )
            ]

            // Add 1-2 random teen events to current events
            let randomCount = Int.random(in: 1...2)
            let shuffledEvents = events.shuffled()

            for i in 0..<min(randomCount, shuffledEvents.count) {
                currentEvents.append(shuffledEvents[i])

                // Also add to character history
                if var character = self.character {
                    character.lifeEvents.append(shuffledEvents[i])
                    self.character = character
                }
            }
        }
    }

    // Reset the game state to allow starting a new game
    func resetGame() {
        character = nil
        currentYear = Calendar.current.component(.year, from: Date())
        gameStarted = false
        gameEnded = false
        currentEvents = []
        bankManager = BankManager()

        // Clean up banking system
        bankingSystem = nil
        bankingIntegration = nil
        bankingSubscriptions.removeAll()
    }

    // Helper function to generate job details based on industry and education
    private func generateJobDetails(industry: Industry, level: CareerLevel, degreeField: DegreeField?, education: Education) -> (String, DegreeField?, CareerSpecialization?) {

        // Default values
        var title = "Employee"
        var fieldRequirement: DegreeField? = nil
        var specializationRequirement: CareerSpecialization? = nil

        // First determine title based on industry and level
        switch industry {
        case .technology:
            switch level {
            case .entry, .junior:
                title = "Junior Developer"
                fieldRequirement = .computerScience
            case .mid:
                title = "Software Developer"
                fieldRequirement = .computerScience
            case .senior:
                title = "Senior Developer"
                fieldRequirement = .computerScience
            case .lead:
                title = "Tech Lead"
                fieldRequirement = .computerScience
            case .manager:
                title = "Development Manager"
                fieldRequirement = .computerScience
            case .director:
                title = "Director of Engineering"
                fieldRequirement = .computerScience
            case .executive:
                title = "VP of Technology"
                fieldRequirement = .computerScience
            case .cLevel:
                title = "Chief Technology Officer"
                fieldRequirement = .computerScience
            }

            // Add specialization for higher levels
            if level.rawValue >= CareerLevel.mid.rawValue {
                let specializations: [CareerSpecialization] = [
                    .softwareDeveloper, .systemsArchitect, .dataScientist,
                    .cyberSecurityAnalyst, .aiSpecialist, .networkAdministrator
                ]
                specializationRequirement = specializations.randomElement()
            }

        case .healthcare:
            if education.rawValue >= Education.bachelorsDegree.rawValue {
                switch level {
                case .entry, .junior:
                    title = "Medical Resident"
                    fieldRequirement = .medicine
                case .mid, .senior:
                    title = "Physician"
                    fieldRequirement = .medicine
                case .lead, .manager:
                    title = "Senior Physician"
                    fieldRequirement = .medicine
                case .director:
                    title = "Chief of Medicine"
                    fieldRequirement = .medicine
                case .executive, .cLevel:
                    title = "Hospital Director"
                    fieldRequirement = .medicine
                }

                // Add specialization for doctors
                if level.rawValue >= CareerLevel.mid.rawValue && title.contains("Physician") {
                    let specializations: [CareerSpecialization] = [
                        .generalPractitioner, .surgeon, .pediatrician,
                        .psychiatrist, .cardiologist, .neurologist
                    ]
                    specializationRequirement = specializations.randomElement()
                }
            } else if education.rawValue >= Education.associatesDegree.rawValue {
                title = "Registered Nurse"
                fieldRequirement = .nursing
                if level.rawValue >= CareerLevel.senior.rawValue {
                    specializationRequirement = .nursepractitioner
                }
            } else {
                title = "Healthcare Assistant"
            }

        case .finance:
            switch level {
            case .entry, .junior:
                title = "Financial Analyst"
                fieldRequirement = .finance
            case .mid:
                title = "Senior Analyst"
                fieldRequirement = .finance
            case .senior:
                title = "Investment Manager"
                fieldRequirement = .finance
            case .lead, .manager:
                title = "Finance Manager"
                fieldRequirement = .finance
            case .director:
                title = "Finance Director"
                fieldRequirement = .finance
            case .executive, .cLevel:
                title = "Chief Financial Officer"
                fieldRequirement = .finance
            }

        case .education:
            if education.rawValue >= Education.bachelorsDegree.rawValue {
                title = "Teacher"
                fieldRequirement = .education

                if education.rawValue >= Education.mastersDegree.rawValue && level.rawValue >= CareerLevel.senior.rawValue {
                    title = "Professor"
                    if level.rawValue >= CareerLevel.director.rawValue {
                        title = "Department Chair"
                    }
                }

                if level.rawValue >= CareerLevel.mid.rawValue {
                    specializationRequirement = [.elementaryTeacher, .highSchoolTeacher,
                                               .professor, .specialEducation].randomElement()
                }
            } else {
                title = "Teaching Assistant"
            }

        case .retail:
            switch level {
            case .entry:
                title = "Retail Assistant"
            case .junior:
                title = "Sales Associate"
            case .mid:
                title = "Department Manager"
            case .senior, .lead:
                title = "Store Manager"
            case .manager, .director:
                title = "Regional Manager"
            case .executive, .cLevel:
                title = "Retail Operations Director"
            }

        case .legal:
            if education.rawValue >= Education.mastersDegree.rawValue || education.rawValue >= Education.bachelorsDegree.rawValue && fieldRequirement == .law {
                switch level {
                case .entry, .junior:
                    title = "Junior Associate"
                    fieldRequirement = .law
                case .mid:
                    title = "Associate"
                    fieldRequirement = .law
                case .senior:
                    title = "Senior Associate"
                    fieldRequirement = .law
                case .lead, .manager:
                    title = "Partner"
                    fieldRequirement = .law
                case .director, .executive, .cLevel:
                    title = "Managing Partner"
                    fieldRequirement = .law
                }

                // Add legal specialization
                if level.rawValue >= CareerLevel.mid.rawValue {
                    specializationRequirement = [.corporateLawyer, .criminalLawyer,
                                               .familyLawyer, .patentAttorney].randomElement()
                }
            } else {
                title = "Paralegal"
            }

        // Add more industries as needed
        default:
            // Generic titles for other industries
            switch level {
            case .entry:
                title = "Entry Level"
            case .junior:
                title = "Junior Staff"
            case .mid:
                title = "Staff"
            case .senior:
                title = "Senior Staff"
            case .lead:
                title = "Lead"
            case .manager:
                title = "Manager"
            case .director:
                title = "Director"
            case .executive:
                title = "Executive"
            case .cLevel:
                title = "Chief Officer"
            }
        }

        return (title, fieldRequirement, specializationRequirement)
    }

    // Add a method to check for and trigger job promotions when advancing years
    private func checkForPromotion() {
        guard var character = self.character else { return }

        if let career = character.career {
            // Check if the career is eligible for promotion
            if career.yearsAtJob >= (career.promotionYearsRequired ?? 3) {
                // Generate promotion event
                let promotionEvent = LifeEvent(
                    title: "Promoted",
                    description: "You were promoted to \(career.level.nextLevel.rawValue) at \(career.company).",
                    type: .career,
                    year: currentYear,
                    outcome: "You're now a \(career.level.nextLevel.rawValue) at \(career.company).",
                    effects: [EventChoice.CharacterEffect(attribute: "happiness", change: 10)]
                )
                currentEvents.append(promotionEvent)
                character.lifeEvents.append(promotionEvent)

                // Update career level
                var updatedCareer = career
                updatedCareer.level = career.level.nextLevel
                character.career = updatedCareer
            }
        }
    }

    // MARK: - Relationship Methods

    // Enum for relationship interaction types
    enum RelationshipInteraction {
        case spendTime, gift, romance, resolveIssue
    }

    // Interact with a relationship at a specific index
    func interactWithRelationship(at index: Int, interaction: RelationshipInteraction) {
        guard var character = self.character, index < character.relationships.count else { return }

        var relationship = character.relationships[index]
        var title = ""
        var description = ""
        var outcome = ""
        var closenessChange = 0
        var happinessChange = 0

        // Set values based on interaction type
        switch interaction {
        case .spendTime:
            title = "Quality Time"
            description = "You spent quality time with \(relationship.name)."

            let activities = ["went for coffee", "had lunch together", "went for a walk", "played games", "watched a movie"]
            let activity = activities.randomElement()!

            // Base values modified by mood and traits
            let baseCloseness = Int.random(in: 5...10)
            let baseHappiness = Int.random(in: 3...8)

            // Adjust for relationship mood
            let moodFactor = 1.0 + (Double(relationship.moodModifier) / 20.0)
            closenessChange = Int(Double(baseCloseness) * moodFactor)
            happinessChange = Int(Double(baseHappiness) * moodFactor)

            outcome = "You \(activity) and enjoyed each other's company. Your relationship grew closer."

        case .gift:
            title = "Gift Giving"
            description = "You gave a gift to \(relationship.name)."

            // Check if character can afford the gift
            let giftCost = Double.random(in: 20...100)

            if character.money >= giftCost {
                character.money -= giftCost

                let gifts = ["book", "clothing item", "electronic gadget", "homemade treat", "decorative item"]
                let gift = gifts.randomElement()!

                // Gifts have larger impact on closeness but depend on receiver traits
                let baseCloseness = Int.random(in: 8...15)
                let baseHappiness = Int.random(in: 5...10)

                // Adjust for traits
                var traitMultiplier = 1.0
                if relationship.traits.contains(where: { $0 == .generous || $0 == .materialistic }) {
                    traitMultiplier = 1.5 // Generous or materialistic people appreciate gifts more
                } else if relationship.traits.contains(where: { $0 == .spiritual || $0 == .minimalist }) {
                    traitMultiplier = 0.7 // Spiritual or minimalist people value gifts less
                }

                closenessChange = Int(Double(baseCloseness) * traitMultiplier)
                happinessChange = Int(Double(baseHappiness) * traitMultiplier)

                outcome = "You spent $\(Int(giftCost)) on a \(gift). \(relationship.name) really appreciated your thoughtfulness."
            } else {
                outcome = "You couldn't afford to buy a nice gift right now."
                closenessChange = 0
                happinessChange = -2
            }

        case .romance:
            title = "Date Night"
            description = "You planned a special evening with \(relationship.name)."

            // Romance only applies to significant others and spouses
            if relationship.type != .significantOther && relationship.type != .spouse {
                outcome = "This type of interaction isn't appropriate for your relationship with \(relationship.name)."
                closenessChange = -5
                happinessChange = -5
                break
            }

            // Check if character can afford the date
            let dateCost = Double.random(in: 50...200)

            if character.money >= dateCost {
                character.money -= dateCost

                let locations = ["fancy restaurant", "scenic viewpoint", "concert", "theater", "weekend getaway"]
                let location = locations.randomElement()!

                // Romance has biggest impact on closeness for romantic relationships
                closenessChange = Int.random(in: 10...20)
                happinessChange = Int.random(in: 8...15)

                outcome = "You spent $\(Int(dateCost)) on a romantic evening at a \(location). It was a night to remember."
            } else {
                outcome = "You couldn't afford a proper date night right now."
                closenessChange = -5
                happinessChange = -5
            }

        case .resolveIssue:
            title = "Working on Issues"
            description = "You tried to address some issues in your relationship with \(relationship.name)."

            // Find an unresolved issue if any exist
            if let issue = relationship.issues.first(where: { !$0.isResolved }) {
                // Success depends on intelligence and relationship compatibility
                let success = relationship.tryResolveIssue(
                    issueId: issue.id,
                    year: currentYear,
                    characterIntelligence: character.intelligence,
                    characterHappiness: character.happiness
                )

                if success {
                    outcome = "You successfully worked through the issue of \(issue.type.description.lowercased()). Your relationship is stronger now."
                    closenessChange = 15
                    happinessChange = 10
                } else {
                    outcome = "You tried to address the \(issue.type.description.lowercased()), but weren't able to resolve it completely."
                    closenessChange = 5
                    happinessChange = -5
                }
            } else {
                outcome = "There aren't any major issues to resolve in your relationship right now."
                closenessChange = 3
                happinessChange = 3
            }
        }

        // Update relationship and character
        relationship.closeness = min(100, relationship.closeness + closenessChange)
        relationship.lastInteraction = currentYear
        relationship.moodModifier = min(20, relationship.moodModifier + (closenessChange / 2))

        // Update the relationship in the character's array
        character.relationships[index] = relationship

        // Update character happiness and money
        character.happiness = min(100, character.happiness + happinessChange)

        // Create relationship event
        let relationshipEvent = LifeEvent(
            title: title,
            description: description,
            type: .relationship,
            year: currentYear,
            outcome: outcome,
            effects: [
                EventChoice.CharacterEffect(attribute: "happiness", change: happinessChange)
            ]
        )

        // Add the event
        currentEvents.append(relationshipEvent)
        character.lifeEvents.append(relationshipEvent)

        // Update the character
        self.character = character
    }

    // Resolve relationship issue given relationship index and issue ID
    func resolveRelationshipIssue(at index: Int, issueId: UUID) {
        guard var character = self.character, index < character.relationships.count else { return }

        // Find the specific issue
        if let issueIndex = character.relationships[index].issues.firstIndex(where: { $0.id == issueId && !$0.isResolved }) {
            // Create an event for working on the issue
            let issue = character.relationships[index].issues[issueIndex]
            let relationshipName = character.relationships[index].name

            // Try to resolve the issue
            let success = character.relationships[index].tryResolveIssue(
                issueId: issueId,
                year: currentYear,
                characterIntelligence: character.intelligence,
                characterHappiness: character.happiness
            )

            // Create appropriate event
            let title = "Relationship Work"
            let description = "You tried to address \(issue.type.description.lowercased()) in your relationship with \(relationshipName)."
            let outcome: String
            let happinessChange: Int

            if success {
                outcome = "You successfully resolved the issue. Your relationship is now stronger."
                happinessChange = 10
            } else {
                outcome = "You made some progress, but the issue isn't completely resolved yet."
                happinessChange = -5
            }

            // Create relationship event
            let relationshipEvent = LifeEvent(
                title: title,
                description: description,
                type: .relationship,
                year: currentYear,
                outcome: outcome,
                effects: [
                    EventChoice.CharacterEffect(attribute: "happiness", change: happinessChange)
                ]
            )

            // Add the event
            currentEvents.append(relationshipEvent)
            character.lifeEvents.append(relationshipEvent)

            // Update character happiness
            character.happiness = min(100, character.happiness + happinessChange)

            // Update the character
            self.character = character
        }
    }

    // Process specific effects from relationship events
    func processRelationshipEventEffect(effect: EventChoice.CharacterEffect) {
        guard var character = self.character else { return }

        // Process different relationship effects
        let attributeString = effect.attribute

        // New relationship creation
        if attributeString.starts(with: "new_friend_") {
            let name = attributeString.replacingOccurrences(of: "new_friend_", with: "")
            var newRelationship = Relationship(
                name: name,
                type: .friend,
                closeness: 50,
                years: 0
            )
            // Generate random traits for the new friend
            newRelationship.generateRandomTraits(characterIntelligence: character.intelligence)
            character.relationships.append(newRelationship)
        }
        else if attributeString.starts(with: "new_significant_other_") {
            let name = attributeString.replacingOccurrences(of: "new_significant_other_", with: "")
            var newRelationship = Relationship(
                name: name,
                type: .significantOther,
                closeness: 70,
                years: 0
            )
            // Generate random traits
            newRelationship.generateRandomTraits(characterIntelligence: character.intelligence)
            character.relationships.append(newRelationship)
        }
        else if attributeString.starts(with: "new_coworker_") {
            let name = attributeString.replacingOccurrences(of: "new_coworker_", with: "")
            var newRelationship = Relationship(
                name: name,
                type: .coworker,
                closeness: 40,
                years: 0
            )
            // Generate random traits
            newRelationship.generateRandomTraits(characterIntelligence: character.intelligence)
            character.relationships.append(newRelationship)
        }
        // Relationship status changes
        else if attributeString.starts(with: "relationship_closeness_") {
            let idString = attributeString.replacingOccurrences(of: "relationship_closeness_", with: "")
            if let uuid = UUID(uuidString: idString),
               let index = character.relationships.firstIndex(where: { $0.id == uuid }) {
                character.relationships[index].closeness = min(100, character.relationships[index].closeness + effect.change)
            }
        }
        else if attributeString.starts(with: "relationship_living_together_") {
            let idString = attributeString.replacingOccurrences(of: "relationship_living_together_", with: "")
            if let uuid = UUID(uuidString: idString),
               let _ = character.relationships.firstIndex(where: { $0.id == uuid }) {
                character.residence = .apartment // Moving in together changes residence
            }
        }
        else if attributeString.starts(with: "relationship_engaged_") {
            let idString = attributeString.replacingOccurrences(of: "relationship_engaged_", with: "")
            if let uuid = UUID(uuidString: idString),
               let _ = character.relationships.firstIndex(where: { $0.id == uuid }) {
                character.setMetadataValue(true, forKey: "relationship_engaged_\(uuid.uuidString)")
            }
        }
        else if attributeString.starts(with: "relationship_marry_") {
            let idString = attributeString.replacingOccurrences(of: "relationship_marry_", with: "")
            if let uuid = UUID(uuidString: idString),
               let index = character.relationships.firstIndex(where: { $0.id == uuid }) {
                // Change relationship type to spouse
                character.relationships[index].type = .spouse
                // Update character's marital status
                character.isMarried = true
                character.spouseRelationshipId = uuid
                // Remove engaged metadata flag - using empty string as a non-nil value to remove
                character.setMetadataValue("", forKey: "relationship_engaged_\(uuid.uuidString)")
            }
        }
        else if attributeString.starts(with: "relationship_end_") {
            let idString = attributeString.replacingOccurrences(of: "relationship_end_", with: "")
            if let uuid = UUID(uuidString: idString) {
                // Get the relationship details before removing
                let relationship = character.relationships.first(where: { $0.id == uuid })

                // Remove the relationship
                character.relationships.removeAll(where: { $0.id == uuid })

                // If it was spouse, update marital status
                if relationship?.type == .spouse {
                    character.isMarried = false
                    character.spouseRelationshipId = nil
                }

                // If it was significant other, clean up any engagement status
                if relationship?.type == .significantOther {
                    character.setMetadataValue("", forKey: "relationship_engaged_\(uuid.uuidString)")
                }
            }
        }
        // Issue handling
        else if attributeString.starts(with: "relationship_create_issue_") {
            let idString = attributeString.replacingOccurrences(of: "relationship_create_issue_", with: "")
            if let uuid = UUID(uuidString: idString),
               let index = character.relationships.firstIndex(where: { $0.id == uuid }) {
                character.relationships[index].createIssue(year: currentYear)
            }
        }
        else if attributeString.starts(with: "relationship_resolve_issue_") {
            let idString = attributeString.replacingOccurrences(of: "relationship_resolve_issue_", with: "")
            if let uuid = UUID(uuidString: idString),
               let relationshipIndex = character.relationships.firstIndex(where: {
                   $0.issues.contains(where: { $0.id == uuid })
               }) {
                _ = character.relationships[relationshipIndex].tryResolveIssue(
                    issueId: uuid,
                    year: currentYear,
                    characterIntelligence: character.intelligence,
                    characterHappiness: character.happiness
                )
            }
        }

        // Update the character
        self.character = character
    }
}