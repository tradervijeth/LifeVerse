//
//  RelationshipEvents.swift
//  LifeVerse
//
//  Created to fix missing RelationshipEvents class
//

import Foundation

/// Class that generates relationship events for the game
class RelationshipEvents {

    /// Generate a relationship milestone event
    static func generateRelationshipMilestoneEvent(for character: Character, relationship: Relationship) -> LifeEvent? {
        // Only generate for romantic relationships
        guard relationship.type == .romantic || relationship.type == .spouse else {
            return nil
        }

        // Check if relationship has reached a milestone year
        let milestoneYears = [1, 5, 10, 25, 50]
        guard milestoneYears.contains(relationship.years) else {
            return nil
        }

        // Create milestone event
        let title = "Relationship Anniversary"
        let description = "You and \(relationship.name) celebrated \(relationship.years) year\(relationship.years > 1 ? "s" : "") together."

        return LifeEvent(
            title: title,
            description: description,
            type: .relationship,
            year: character.birthYear + character.age,
            outcome: "Your relationship grew stronger.",
            effects: [
                EventChoice.CharacterEffect(attribute: "happiness", change: 10)
            ]
        )
    }

    /// Generate a wedding event for engaged couples
    static func generateWeddingEvent(for character: Character, relationship: Relationship) -> LifeEvent? {
        // Check if this is a romantic relationship with engagement status
        guard relationship.type == .romantic else {
            return nil
        }

        // Check if they're engaged (stored in metadata)
        let isEngaged = character.getMetadataValue(key: "engaged_to_\(relationship.id.uuidString)") as? Bool ?? false

        // Only 25% chance per year of having the wedding
        guard isEngaged && Double.random(in: 0...1) < 0.25 else {
            return nil
        }

        // Create wedding event
        let weddingEvent = LifeEvent(
            title: "Wedding Day",
            description: "You married \(relationship.name) in a beautiful ceremony.",
            type: .relationship,
            year: character.birthYear + character.age,
            outcome: "You are now married!",
            effects: [
                EventChoice.CharacterEffect(attribute: "happiness", change: 20)
            ]
        )

        return weddingEvent
    }

    /// Generate a new relationship event
    static func generateNewRelationshipEvent(for character: Character) -> LifeEvent? {
        // Don't generate too many relationships
        if character.relationships.count >= 10 {
            return nil
        }

        // Different types of relationships based on age
        let possibleTypes: [Relationship.RelationshipType]

        if character.age < 12 {
            possibleTypes = [.friend]
        } else if character.age < 16 {
            possibleTypes = [.friend, .friend, .friend, .romantic]
        } else {
            possibleTypes = [.friend, .friend, .romantic, .coworker]
        }

        // Select a random type
        let relationshipType = possibleTypes.randomElement()!

        // Create appropriate event
        let title: String
        let description: String

        switch relationshipType {
        case .friend:
            title = "New Friend"
            description = "You met someone new who could become a friend."
        case .romantic:
            title = "Romantic Interest"
            description = "You met someone who seems interested in you romantically."
        case .coworker:
            title = "New Colleague"
            description = "You met a new colleague at work who seems friendly."
        default:
            return nil
        }

        // Create the event with choices
        return LifeEvent(
            title: title,
            description: description,
            type: .relationship,
            year: character.birthYear + character.age,
            choices: [
                EventChoice(
                    text: "Pursue the relationship",
                    outcome: "You decided to pursue a new relationship.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: 5),
                        EventChoice.CharacterEffect(attribute: "new_relationship", change: 1)
                    ]
                ),
                EventChoice(
                    text: "Keep your distance",
                    outcome: "You decided not to pursue a new relationship right now.",
                    effects: []
                )
            ]
        )
    }

    /// Generate a relationship issue event
    static func generateRelationshipIssueEvent(for character: Character, relationship: Relationship) -> LifeEvent? {
        // Don't generate issues for new relationships
        if relationship.years < 1 {
            return nil
        }

        // Don't generate too many issues
        if relationship.issues.count >= 3 {
            return nil
        }

        // Possible issue types
        let possibleIssueTypes = Relationship.RelationshipIssue.IssueType.allCases

        // Select a random issue type that doesn't already exist
        let existingIssueTypes = relationship.issues.map { $0.type }
        let availableIssueTypes = possibleIssueTypes.filter { !existingIssueTypes.contains($0) }

        guard let selectedIssueType = availableIssueTypes.randomElement() else {
            return nil
        }

        // Create the issue event
        let title = "Relationship Issue"
        let description = "You and \(relationship.name) are having issues with \(selectedIssueType.description)."

        return LifeEvent(
            title: title,
            description: description,
            type: .relationship,
            year: character.birthYear + character.age,
            choices: [
                EventChoice(
                    text: "Work on the issue",
                    outcome: "You decided to address the issue in your relationship.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "relationship_issue_\(relationship.id.uuidString)", change: 1)
                    ]
                ),
                EventChoice(
                    text: "Ignore it for now",
                    outcome: "You decided to ignore the issue for now.",
                    effects: [
                        EventChoice.CharacterEffect(attribute: "happiness", change: -5)
                    ]
                )
            ]
        )
    }
}
