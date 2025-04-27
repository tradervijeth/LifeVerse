//
//  Character.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

struct Character: Codable, Identifiable {
    var id = UUID()
    var name: String
    var age: Int = 0
    var birthYear: Int
    var gender: Gender
    var isAlive: Bool = true

    // Core attributes (0-100 scale)
    var health: Int = 100
    var happiness: Int = 50
    var intelligence: Int = 50
    var looks: Int = 50
    var athleticism: Int = 50

    // Dynamic life stats
    var money: Double = 0
    var education: Education = .none
    var career: Career?
    var relationships: [Relationship] = []
    var lifeEvents: [LifeEvent] = []

    // Life choices & status
    var residence: Residence = .parentsHome
    var possessions: [Possession] = []

    // Additional metadata for character properties
    private var _metadata = CodableMetadata()
    var isMarried: Bool = false
    var spouseRelationshipId: UUID? = nil
    var degreeField: UnifiedDegreeField? = nil

    // Initialize with birth settings
    init(name: String, birthYear: Int, gender: Gender) {
        self.name = name
        self.birthYear = birthYear
        self.gender = gender

        // Randomize starting attributes
        self.health = Int.random(in: 70...100)
        self.happiness = Int.random(in: 40...60)
        self.intelligence = Int.random(in: 30...70)
        self.looks = Int.random(in: 30...70)
        self.athleticism = Int.random(in: 30...70)
    }

    // Age up the character by one year
    mutating func ageUp() -> [LifeEvent] {
        guard isAlive else { return [] }

        self.age += 1
        var yearEvents: [LifeEvent] = []

        // Chance of natural health decline with age
        if age > 50 {
            let healthDecline = Int.random(in: 0...3)
            health = max(0, health - healthDecline)
        }

        // Check for death conditions
        if health <= 0 || age > 120 || shouldDieRandomly() {
            isAlive = false
            let deathEvent = LifeEvent(
                title: "Death",
                description: "You died at the age of \(age).",
                type: .death,
                year: birthYear + age
            )
            yearEvents.append(deathEvent)
            return yearEvents
        }

        // Generate random and scripted events based on age
        let randomEvents = EventGenerator.generateRandomEvents(for: self)
        yearEvents.append(contentsOf: randomEvents)

        // Generate education events
        if age >= 5 && age <= 22 {
            let educationEvents = EventGenerator.generateEducationEvents(for: self)
            yearEvents.append(contentsOf: educationEvents)
        }

        // Generate career events for adults
        if age >= 18 {
            let careerEvents = EventGenerator.generateCareerEvents(for: self)
            yearEvents.append(contentsOf: careerEvents)
        }

        // Generate relationship events
        let relationshipEvents = EventGenerator.generateRelationshipEvents(for: self)
        yearEvents.append(contentsOf: relationshipEvents)

        // Add all events to character history
        self.lifeEvents.append(contentsOf: yearEvents)

        return yearEvents
    }

    private func shouldDieRandomly() -> Bool {
        // Calculate death probability based on age and health
        let baseDeathChance: Double

        switch age {
        case 0...30: baseDeathChance = 0.001
        case 31...50: baseDeathChance = 0.005
        case 51...70: baseDeathChance = 0.01
        case 71...85: baseDeathChance = 0.03
        case 86...100: baseDeathChance = 0.08
        default: baseDeathChance = 0.15
        }

        // Health factor (lower health increases death chance)
        let healthFactor = Double(100 - health) / 100.0
        let adjustedDeathChance = baseDeathChance * (1 + healthFactor)

        return Double.random(in: 0...1) < adjustedDeathChance
    }

    // Metadata management methods
    mutating func setMetadataValue(_ value: Any, forKey key: String) {
        var metadata = _metadata
        metadata.setValue(value, forKey: key)
        _metadata = metadata
    }

    mutating func setMetadataValue(key: String, value: Any) {
        setMetadataValue(value, forKey: key)
    }

    func getMetadataValue(key: String) -> Any? {
        return _metadata.getValue(forKey: key)
    }

    // Get all metadata as a dictionary
    func getMetadataDictionary() -> [String: Any] {
        return _metadata.toDictionary()
    }

    // Codable implementation for metadata
    enum CodingKeys: String, CodingKey {
        case id, name, age, birthYear, gender, isAlive
        case health, happiness, intelligence, looks, athleticism
        case money, education, career, relationships, lifeEvents
        case residence, possessions
        case isMarried, spouseRelationshipId, degreeField
        case metadata = "metadataStrings"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        age = try container.decode(Int.self, forKey: .age)
        birthYear = try container.decode(Int.self, forKey: .birthYear)
        gender = try container.decode(Gender.self, forKey: .gender)
        isAlive = try container.decode(Bool.self, forKey: .isAlive)

        health = try container.decode(Int.self, forKey: .health)
        happiness = try container.decode(Int.self, forKey: .happiness)
        intelligence = try container.decode(Int.self, forKey: .intelligence)
        looks = try container.decode(Int.self, forKey: .looks)
        athleticism = try container.decode(Int.self, forKey: .athleticism)

        money = try container.decode(Double.self, forKey: .money)
        education = try container.decode(Education.self, forKey: .education)
        career = try container.decodeIfPresent(Career.self, forKey: .career)
        relationships = try container.decode([Relationship].self, forKey: .relationships)
        lifeEvents = try container.decode([LifeEvent].self, forKey: .lifeEvents)

        residence = try container.decode(Residence.self, forKey: .residence)
        possessions = try container.decode([Possession].self, forKey: .possessions)

        isMarried = try container.decodeIfPresent(Bool.self, forKey: .isMarried) ?? false
        spouseRelationshipId = try container.decodeIfPresent(UUID.self, forKey: .spouseRelationshipId)
        degreeField = try container.decodeIfPresent(UnifiedDegreeField.self, forKey: .degreeField)

        // Decode metadata
        _metadata = try container.decodeIfPresent(CodableMetadata.self, forKey: .metadata) ?? CodableMetadata()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(age, forKey: .age)
        try container.encode(birthYear, forKey: .birthYear)
        try container.encode(gender, forKey: .gender)
        try container.encode(isAlive, forKey: .isAlive)

        try container.encode(health, forKey: .health)
        try container.encode(happiness, forKey: .happiness)
        try container.encode(intelligence, forKey: .intelligence)
        try container.encode(looks, forKey: .looks)
        try container.encode(athleticism, forKey: .athleticism)

        try container.encode(money, forKey: .money)
        try container.encode(education, forKey: .education)
        try container.encodeIfPresent(career, forKey: .career)
        try container.encode(relationships, forKey: .relationships)
        try container.encode(lifeEvents, forKey: .lifeEvents)

        try container.encode(residence, forKey: .residence)
        try container.encode(possessions, forKey: .possessions)

        try container.encode(isMarried, forKey: .isMarried)
        try container.encodeIfPresent(spouseRelationshipId, forKey: .spouseRelationshipId)
        try container.encodeIfPresent(degreeField, forKey: .degreeField)

        // Encode metadata
        try container.encode(_metadata, forKey: .metadata)
    }
}
