//
//  USRelationshipEvents.swift
//  LifeVerse
//
//  Created to fix missing USRelationshipEvents class
//

import Foundation

/// Class that generates US-specific relationship events for the game
class USRelationshipEvents {

    /// Generate a marriage proposal event with US cultural norms
    static func generateMarriageProposalEvent(for character: Character, relationship: Relationship) -> LifeEvent? {
        // Only for romantic relationships
        guard relationship.type == .romantic else {
            return nil
        }

        // Check if already engaged
        let isEngaged = character.getMetadataValue(key: "engaged_to_\(relationship.id.uuidString)") as? Bool ?? false
        if isEngaged {
            return nil
        }

        // Check relationship length and closeness
        guard relationship.years >= 2 && relationship.closeness >= 80 else {
            return nil
        }

        // Only 10% chance per year
        guard Double.random(in: 0...1) < 0.1 else {
            return nil
        }

        // Create proposal event
        return LifeEvent(
            title: "Marriage Proposal",
            description: "You're considering proposing to \(relationship.name).",
            type: .relationship,
            year: character.birthYear + character.age,
            choices: [
                EventChoice(
                    text: "Propose marriage",
                    outcome: "You proposed, and \(relationship.name) said yes!",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: 15),
                        EventChoice.CharacterEffect(attribute: "engaged_to_\(relationship.id.uuidString)", change: 1)
                    ]
                ),
                EventChoice(
                    text: "Wait longer",
                    outcome: "You decided to wait a bit longer before proposing.",
                    effects: []
                )
            ]
        )
    }

    /// Generate a wedding planning event with US options
    static func generateWeddingPlanningEvent(for character: Character, relationship: Relationship) -> LifeEvent? {
        // Check if engaged
        let isEngaged = character.getMetadataValue(key: "engaged_to_\(relationship.id.uuidString)") as? Bool ?? false
        if !isEngaged {
            return nil
        }

        // Only 50% chance once engaged
        guard Double.random(in: 0...1) < 0.5 else {
            return nil
        }

        // Create wedding planning event
        return LifeEvent(
            title: "Wedding Planning",
            description: "You need to decide on the type of wedding with \(relationship.name).",
            type: .relationship,
            year: character.birthYear + character.age,
            choices: [
                EventChoice(
                    text: "Large traditional wedding",
                    outcome: "You planned a large traditional wedding with all your family and friends.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "money", change: -20000),
                        EventChoice.CharacterEffect(attribute: "happiness", change: 10)
                    ]
                ),
                EventChoice(
                    text: "Small intimate ceremony",
                    outcome: "You opted for a small, intimate ceremony with close family and friends.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "money", change: -5000),
                        EventChoice.CharacterEffect(attribute: "happiness", change: 8)
                    ]
                ),
                EventChoice(
                    text: "Courthouse wedding",
                    outcome: "You decided on a simple courthouse wedding to save money.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "money", change: -500),
                        EventChoice.CharacterEffect(attribute: "happiness", change: 5)
                    ]
                )
            ]
        )
    }

    /// Generate a prenuptial agreement event (US legal concept)
    static func generatePrenuptialAgreementEvent(for character: Character, relationship: Relationship) -> LifeEvent? {
        // Check if engaged
        let isEngaged = character.getMetadataValue(key: "engaged_to_\(relationship.id.uuidString)") as? Bool ?? false
        if !isEngaged {
            return nil
        }

        // Only consider if character has significant assets
        let hasSignificantAssets = character.money > 100000
        if !hasSignificantAssets {
            return nil
        }

        // Only 30% chance once engaged with assets
        guard Double.random(in: 0...1) < 0.3 else {
            return nil
        }

        // Create prenup event
        return LifeEvent(
            title: "Prenuptial Agreement",
            description: "You're considering a prenuptial agreement before marrying \(relationship.name).",
            type: .relationship,
            year: character.birthYear + character.age,
            choices: [
                EventChoice(
                    text: "Suggest a prenup",
                    outcome: "You suggested a prenup. After some discussion, \(relationship.name) agreed.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "prenup_\(relationship.id.uuidString)", change: 1),
                        EventChoice.CharacterEffect(attribute: "money", change: -2000) // Legal fees
                    ]
                ),
                EventChoice(
                    text: "Skip the prenup",
                    outcome: "You decided not to have a prenuptial agreement.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: 3)
                    ]
                )
            ]
        )
    }

    /// Generate a divorce event with US legal framework
    static func generateDivorceEvent(for character: Character, relationship: Relationship) -> LifeEvent? {
        // Only for spouse relationships
        guard relationship.type == .spouse else {
            return nil
        }

        // Check for serious relationship issues
        let hasSerousIssues = relationship.issues.count >= 2 && relationship.closeness < 40
        if !hasSerousIssues {
            return nil
        }

        // 20% chance per year if there are serious issues
        guard Double.random(in: 0...1) < 0.2 else {
            return nil
        }

        // Check if they have a prenup
        let hasPrenup = character.getMetadataValue(key: "prenup_\(relationship.id.uuidString)") as? Bool ?? false

        // Create divorce event
        return LifeEvent(
            title: "Considering Divorce",
            description: "Your marriage with \(relationship.name) has serious problems. You're considering divorce.",
            type: .relationship,
            year: character.birthYear + character.age,
            choices: [
                EventChoice(
                    text: "File for divorce",
                    outcome: hasPrenup ?
                        "You filed for divorce. The prenuptial agreement made the process smoother." :
                        "You filed for divorce. The process was emotionally and financially draining.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: -15),
                        EventChoice.CharacterEffect(attribute: "money", change: hasPrenup ? -5000 : -20000),
                        EventChoice.CharacterEffect(attribute: "divorce_\(relationship.id.uuidString)", change: 1)
                    ]
                ),
                EventChoice(
                    text: "Try marriage counseling",
                    outcome: "You decided to try marriage counseling to work on your relationship.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "money", change: -2000),
                        EventChoice.CharacterEffect(attribute: "counseling_\(relationship.id.uuidString)", change: 1)
                    ]
                ),
                EventChoice(
                    text: "Stay in the marriage",
                    outcome: "You decided to stay in the marriage despite the problems.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: -10)
                    ]
                )
            ]
        )
    }
}
