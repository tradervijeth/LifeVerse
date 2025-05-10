//
//  Relationship.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct Relationship: Codable, Identifiable {
    var id = UUID()
    var name: String
    var type: RelationshipType
    var closeness: Int // 0-100
    var years: Int = 0
    var traits: [String] = []
    var moodModifier: Int = 0
    var lastInteraction: Date = Date()
    var issues: [RelationshipIssue] = []

    enum RelationshipType: String, Codable {
        case parent
        case sibling
        case child
        case friend
        case significantOther
        case spouse
        case exSpouse
        case coworker
        case romantic
    }

    struct RelationshipIssue: Codable, Identifiable {
        var id = UUID()
        var type: IssueType
        var severity: Int = 3 // 1-5 scale
        var yearStarted: Int = Calendar.current.component(.year, from: Date())
        var isResolved: Bool = false

        enum IssueType: String, Codable, CaseIterable {
            case trust
            case communication
            case jealousy
            case compatibility
            case distance
            case finances
            case commitment

            var description: String {
                switch self {
                case .trust: return "Trust Issues"
                case .communication: return "Communication Problems"
                case .jealousy: return "Jealousy"
                case .compatibility: return "Compatibility Issues"
                case .distance: return "Growing Apart"
                case .finances: return "Financial Disagreements"
                case .commitment: return "Commitment Issues"
                }
            }
        }
    }

    // Initialize enhanced properties like traits
    mutating func initializeEnhancedProperties(currentYear: Int? = nil) {
        if traits.isEmpty {
            generateRandomTraits()
        }

        // Initialize last interaction if needed
        if lastInteraction == Date(timeIntervalSince1970: 0) {
            lastInteraction = Date()
        }
    }

    // Generate random personality traits for the relationship
    mutating func generateRandomTraits(characterIntelligence: Int = 50) {
        let possibleTraits = [
            "caring", "supportive", "loyal", "honest", "fun", "serious",
            "distant", "protective", "competitive", "jealous", "critical",
            "understanding", "patient", "emotional", "logical", "adventurous"
        ]

        // Choose 2-4 random traits
        let count = Int.random(in: 2...4)
        var selectedTraits: [String] = []

        while selectedTraits.count < count {
            if let trait = possibleTraits.randomElement(), !selectedTraits.contains(trait) {
                selectedTraits.append(trait)
            }
        }

        self.traits = selectedTraits
    }

    // Age up the relationship by one year
    mutating func ageUp() -> Bool {
        years += 1

        // Random chance for relationship growth/decay based on type
        switch type {
        case .parent, .child, .sibling:
            // Family ties tend to be stable
            closeness = max(0, min(100, closeness + Int.random(in: -3...5)))
        case .friend, .coworker:
            // Friends can grow apart more easily
            closeness = max(0, min(100, closeness + Int.random(in: -5...5)))
        case .significantOther, .romantic:
            // Romantic relationships can change more dramatically
            closeness = max(0, min(100, closeness + Int.random(in: -10...10)))
        case .spouse:
            // Marriages tend to stabilize but can have issues
            closeness = max(0, min(100, closeness + Int.random(in: -5...5)))
        case .exSpouse:
            // Ex relationships tend to cool over time
            closeness = max(0, min(100, closeness - Int.random(in: 0...3)))
        }

        // Random chance to develop issues
        if Double.random(in: 0...1) < 0.2 { // 20% chance per year
            createIssue(year: Calendar.current.component(.year, from: Date()))
        }

        // Random chance to resolve issues
        if !issues.isEmpty && Double.random(in: 0...1) < 0.3 { // 30% chance per year
            _ = tryResolveIssue()
        }

        return closeness > 0 // Return false if relationship ended
    }

    // Create a new relationship issue
    mutating func createIssue(year: Int = Calendar.current.component(.year, from: Date())) {
        // Only add if we don't already have too many
        if issues.count < 3, let issueType = RelationshipIssue.IssueType.allCases.randomElement() {
            // Check if we already have this type of issue
            if !issues.contains(where: { $0.type == issueType && !$0.isResolved }) {
                let newIssue = RelationshipIssue(
                    type: issueType,
                    severity: Int.random(in: 1...5),
                    yearStarted: year
                )
                issues.append(newIssue)

                // Issues negatively impact closeness
                closeness = max(0, closeness - Int.random(in: 5...15))
            }
        }
    }

    // Try to resolve a relationship issue
    mutating func tryResolveIssue(issueId: UUID? = nil, year: Int = Calendar.current.component(.year, from: Date()), characterIntelligence: Int = 50, characterHappiness: Int = 50) -> Bool {
        // If no specific issue ID is provided, try to resolve a random unresolved issue
        if issueId == nil {
            let unresolvedIssues = issues.filter { !$0.isResolved }
            guard !unresolvedIssues.isEmpty else { return false }

            // Find a random unresolved issue
            if let randomIssue = unresolvedIssues.randomElement(),
               let index = issues.firstIndex(where: { $0.id == randomIssue.id }) {
                return tryResolveSpecificIssue(at: index, year: year, characterIntelligence: characterIntelligence, characterHappiness: characterHappiness)
            }
            return false
        } else {
            // Try to resolve the specific issue
            if let index = issues.firstIndex(where: { $0.id == issueId && !$0.isResolved }) {
                return tryResolveSpecificIssue(at: index, year: year, characterIntelligence: characterIntelligence, characterHappiness: characterHappiness)
            }
            return false
        }
    }

    // Helper method to try resolving a specific issue
    private mutating func tryResolveSpecificIssue(at index: Int, year: Int, characterIntelligence: Int, characterHappiness: Int) -> Bool {
        // Success chance based on relationship closeness, character intelligence, and happiness
        let closenessContribution = Double(closeness) / 100.0
        let intelligenceContribution = Double(characterIntelligence) / 200.0 // Less impact than closeness
        let happinessContribution = Double(characterHappiness) / 300.0 // Even less impact

        let successChance = closenessContribution + intelligenceContribution + happinessContribution
        let success = Double.random(in: 0...1) < successChance

        if success {
            // Mark the issue as resolved
            issues[index].isResolved = true

            // Resolving issues improves closeness
            closeness = min(100, closeness + Int.random(in: 10...20))
            return true
        }

        return false
    }
}

