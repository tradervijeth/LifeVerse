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
        
        currentYear += 1
        let newEvents = character.ageUp()
        
        // Process automatic events
        for event in newEvents {
            if event.choices == nil && event.effects != nil {
                applyEventEffects(event.effects!, to: &character)
            }
        }
        
        self.character = character
        currentEvents = newEvents
        
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
}
