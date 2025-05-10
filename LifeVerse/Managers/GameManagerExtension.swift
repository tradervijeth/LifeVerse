//
//  GameManagerExtension.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 26/04/2025.
//

import Foundation

// Extension to add bank and relationship management to GameManager
extension GameManager {
    // MARK: - Banking Properties
    
    // Initialize bank manager with character's money if needed
    func setupBankManager() {
        // Initialize bank manager with character's money if needed
        if let character = character {
            bankManager.characterMoney = character.money
            bankManager.characterBirthYear = character.birthYear
        }
    }
    
    // Calculate total property equity
    func calculateTotalPropertyEquity() -> Double {
        return bankManager.propertyInvestments.reduce(0.0) { total, property in
            // Calculate outstanding mortgage if any
            var mortgageBalance: Double = 0
            if let mortgageId = property.mortgageAccountId,
               let mortgage = bankManager.getAccount(id: mortgageId) {
                mortgageBalance = abs(min(0, mortgage.balance))
            }
            
            // Property equity is property value minus mortgage
            return total + (property.currentValue - mortgageBalance)
        }
    }
    
    // MARK: - Relationship Methods
    
    // Create a new life event
    func createLifeEvent(title: String, description: String, type: LifeEvent.EventType) {
        guard let character = character else { return }
        
        let event = LifeEvent(
            title: title,
            description: description,
            type: type,
            year: currentYear
        )
        
        // Add event to current events list
        currentEvents.append(event)
        
        // Add to character's life events
        if var updatedCharacter = character as Character? {
            updatedCharacter.lifeEvents.append(event)
            self.character = updatedCharacter
        }
    }
    
    // Handle relationship interactions without redeclaring existing methods
    func handleRelationshipInteraction(at index: Int, interaction: RelationshipInteraction) {
        guard var character = character else { return }
        guard index >= 0 && index < character.relationships.count else { return }
        
        var relationship = character.relationships[index]
        var closenessChange = 0
        var happinessChange = 0
        var title = ""
        var description = ""
        
        // Apply interaction effects
        switch interaction {
        case .spendTime:
            closenessChange = 5
            happinessChange = 3
            title = "Quality Time"
            description = "You spent quality time with \(relationship.name)."
            
        case .gift:
            closenessChange = 10
            happinessChange = 5
            // Deduct some money for the gift
            let giftAmount = min(character.money * 0.05, 100.0)
            character.money -= giftAmount
            title = "Gift Giving"
            description = "You gave a gift to \(relationship.name)."
            
        case .deepTalk:
            closenessChange = 15
            happinessChange = 3
            title = "Deep Conversation"
            description = "You had a meaningful conversation with \(relationship.name)."
            
        case .romance:
            if relationship.type == .significantOther || relationship.type == .spouse {
                closenessChange = 20
                happinessChange = 10
                title = "Romantic Date"
                description = "You had a romantic date with \(relationship.name)."
            }
            
        case .argue:
            closenessChange = -15
            happinessChange = -10
            title = "Argument"
            description = "You had an argument with \(relationship.name)."
            
        case .resolveIssue:
            closenessChange = 10
            happinessChange = 5
            title = "Conflict Resolution"
            description = "You resolved an issue with \(relationship.name)."
            
        case .moveIn:
            closenessChange = 25
            happinessChange = 15
            title = "Moving In Together"
            description = "You moved in with \(relationship.name)."
            
        case .propose:
            closenessChange = 30
            happinessChange = 20
            title = "Proposal"
            description = "You proposed to \(relationship.name)."
            
        case .planWedding:
            closenessChange = 20
            happinessChange = 15
            title = "Wedding Planning"
            description = "You planned a wedding with \(relationship.name)."
            
        case .breakUp:
            closenessChange = -50
            happinessChange = -25
            title = "Break Up"
            description = "You broke up with \(relationship.name)."
        }
        
        // Update relationship closeness
        relationship.closeness = max(0, min(100, relationship.closeness + closenessChange))
        character.relationships[index] = relationship
        
        // Update character happiness
        character.happiness = max(0, min(100, character.happiness + happinessChange))
        
        // Create a life event for the interaction
        let event = LifeEvent(
            title: title,
            description: description,
            type: .relationship,
            year: currentYear,
            outcome: closenessChange >= 0 ? 
                "Your relationship grew stronger." : 
                "Your relationship was strained.",
            effects: [
                EventChoice.CharacterEffect(attribute: "happiness", change: happinessChange)
            ]
        )
        
        // Add event to current events
        currentEvents.append(event)
        character.lifeEvents.append(event)
        
        // Update character
        self.character = character
    }
    
    // Spend time with all relationships
    func spendTimeWithAllRelationships() {
        guard var character = character else { return }
        
        // Skip if no relationships
        if character.relationships.isEmpty {
            return
        }
        
        // Update all relationships and create a group event
        for i in 0..<character.relationships.count {
            var relationship = character.relationships[i]
            // Small improvement for each relationship
            relationship.closeness = min(100, relationship.closeness + 2)
            character.relationships[i] = relationship
        }
        
        // Add happiness
        character.happiness = min(100, character.happiness + 5)
        
        // Create a group event
        let event = LifeEvent(
            title: "Group Gathering",
            description: "You spent time with all your friends and family.",
            type: .relationship,
            year: currentYear,
            outcome: "Everyone had a good time together.",
            effects: [
                EventChoice.CharacterEffect(attribute: "happiness", change: 5)
            ]
        )
        
        // Add event to current events
        currentEvents.append(event)
        character.lifeEvents.append(event)
        
        // Update character
        self.character = character
    }
}
