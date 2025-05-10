//
//  GameplayView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct GameplayView: View {
    @ObservedObject var gameManager: GameManager
    @State private var showAgeUpSheet: Bool = false
    @State private var selectedTab: String = "Events"
    @State private var showActionSheet: Bool = false
    @State private var showJobOffers: Bool = false
    @State private var jobOffers: [Career] = []

    var tabs = ["Events", "Career", "Assets", "Relationships"]

    var body: some View {
        VStack(spacing: 0) {
            // Character info header
            if let character = gameManager.character {
                CharacterInfoHeader(character: character, currentYear: gameManager.currentYear, bankManager: gameManager.bankManager)
                    .padding(.top)
            }

            // Tab selector
            HStack {
                ForEach(tabs, id: \.self) { tab in
                    Button(action: {
                        selectedTab = tab
                    }) {
                        Text(tab)
                            .font(.subheadline)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .foregroundColor(selectedTab == tab ? .white : .primary)
                            .background(selectedTab == tab ? Color.blue : Color.clear)
                            .cornerRadius(20)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.tertiarySystemBackground))

            // Content based on selected tab
            ScrollView {
                VStack(spacing: 15) {
                    switch selectedTab {
                    case "Events":
                        eventsView
                    case "Career":
                        careerView
                    case "Assets":
                        assetsView
                    case "Relationships":
                        relationshipsView
                    default:
                        eventsView
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 80) // Space for button
            }

            // Footer with action buttons
            HStack(spacing: 20) {
                // Actions button
                Button(action: {
                    showActionSheet = true
                }) {
                    VStack {
                        Image(systemName: "person.fill.questionmark")
                            .font(.system(size: 24))
                        Text("Actions")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }

                Spacer()

                // Age up button
                Button(action: {
                    showAgeUpSheet = true
                }) {
                    VStack {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 36))
                        Text("Age Up")
                            .font(.caption)
                    }
                    .foregroundColor(.green)
                }

                Spacer()

                // Stats button
                Button(action: {
                    // Could show detailed stats here
                }) {
                    VStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 24))
                        Text("Stats")
                            .font(.caption)
                    }
                    .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
        }
        .sheet(isPresented: $showAgeUpSheet) {
            AgeUpView(gameManager: gameManager, isPresented: $showAgeUpSheet)
        }
        .sheet(isPresented: $showJobOffers) {
            if !jobOffers.isEmpty {
                JobOffersView(careers: jobOffers, onAccept: { career in
                    gameManager.acceptJob(career: career)
                    showJobOffers = false
                })
            }
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Life Actions"),
                message: Text("What would you like to do?"),
                buttons: [
                    .default(Text("Look for a Job")) {
                        jobOffers = gameManager.lookForJob()
                        if !jobOffers.isEmpty {
                            showJobOffers = true
                        }
                    },
                    .default(Text("Quit Job")) {
                        if let character = gameManager.character, character.career != nil {
                            gameManager.quitJob()
                        }
                    },
                    .default(Text("Buy a Car")) {
                        if let character = gameManager.character {
                            if character.age < 18 {
                                // Game manager will create the "too young" event
                                _ = gameManager.buyPossession(name: "Car", value: 10000)
                            } else {
                                // This is simplified - in a real implementation, you'd show a car selection UI
                                let carPrice = Double.random(in: 8000...35000)
                                _ = gameManager.buyPossession(name: "Car", value: carPrice)
                            }
                        }
                    },
                    .cancel()
                ]
            )
        }
    }

    // MARK: - Tab Views

    var eventsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if gameManager.currentEvents.isEmpty {
                Text("No recent events")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                Text("Recent Events")
                    .font(.headline)

                ForEach(gameManager.currentEvents, id: \.id) { event in
                    EventCard(event: event, makeChoice: { choice in
                        gameManager.makeChoice(for: event, choice: choice)
                    })
                }
            }

            Divider()

            Text("Life Timeline")
                .font(.headline)

            if let character = gameManager.character {
                ForEach(character.lifeEvents.prefix(10).reversed(), id: \.id) { event in
                    TimelineEventRow(event: event, birthYear: character.birthYear)
                }

                if character.lifeEvents.count > 10 {
                    Text("+ \(character.lifeEvents.count - 10) more events...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    var careerView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let character = gameManager.character, let career = character.career {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .font(.headline)
                        Text("Current Career")
                            .font(.headline)
                    }

                    HStack {
                        VStack(alignment: .leading) {
                            Text(career.title)
                                .font(.title3)
                                .fontWeight(.medium)
                            Text(career.company)
                                .font(.subheadline)
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("$\(Int(career.salary).formattedWithSeparator())/yr")
                                .font(.headline)
                            Text("\(career.yearsAtJob) years")
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)

                    HStack {
                        Text("Performance:")
                            .font(.subheadline)

                        PerformanceMeter(value: career.performanceRating)
                    }
                    .padding(.top, 5)
                }
            } else if let character = gameManager.character, character.age >= 18 {
                VStack(spacing: 10) {
                    Image(systemName: "briefcase")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("No current job")
                        .font(.headline)

                    Text("You're unemployed. Use the Actions button to look for job opportunities.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                VStack(spacing: 10) {
                    Image(systemName: "graduationcap")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)

                    Text("Too young to work")
                        .font(.headline)

                    Text("You need to be at least 18 years old to start a career.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
    }

    var assetsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let character = gameManager.character {
                HStack {
                    Image(systemName: "creditcard")
                        .font(.headline)
                    Text("Finances")
                        .font(.headline)
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Cash:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(Int(character.money).formattedWithSeparator())")
                            .fontWeight(.medium)
                    }

                    Divider()

                    HStack {
                        Text("Assets")
                            .font(.headline)
                        Spacer()
                        Text("Net Worth: $\(calculateNetWorth(character).formattedWithSeparator())")
                            .font(.subheadline)
                    }
                    .padding(.top, 5)

                    if character.possessions.isEmpty {
                        Text("No assets owned")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ForEach(character.possessions) { possession in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(possession.name)
                                        .fontWeight(.medium)
                                    Text("Acquired in \(possession.yearAcquired)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing) {
                                    Text("$\(Int(possession.value).formattedWithSeparator())")

                                    // Condition indicator
                                    HStack(spacing: 1) {
                                        ForEach(0..<5) { index in
                                            Image(systemName: "star.fill")
                                                .font(.system(size: 8))
                                                .foregroundColor(
                                                    index < possession.condition / 20 ?
                                                    .yellow : .gray.opacity(0.3)
                                                )
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 5)

                            // Fixed comparison to use id
                            if possession.id != character.possessions.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)

                if character.age < 18 {
                    Text("Note: You're under 18, so you can't purchase a car or other major assets yet.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
            }
        }
    }

    var relationshipsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            if let character = gameManager.character {
                HStack {
                    Image(systemName: "person.2.fill")
                        .font(.headline)
                    Text("Relationships")
                        .font(.headline)
                }

                if character.relationships.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "person.fill.questionmark")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)

                        Text("No relationships yet")
                            .font(.headline)

                        Text("You'll encounter people as you age up and can form relationships.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                } else {
                    ForEach(character.relationships) { relationship in
                        RelationshipRow(relationship: relationship)
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func calculateNetWorth(_ character: Character) -> Int {
        let assetsValue = character.possessions.reduce(0) { $0 + $1.value }
        return Int(character.money + assetsValue)
    }
}

// MARK: - Supporting Views

struct TimelineEventRow: View {
    let event: LifeEvent
    let birthYear: Int

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Age indicator
            VStack {
                Text("\(event.year - birthYear)")
                    .font(.caption)
                    .padding(6)
                    .background(Circle().fill(Color.blue.opacity(0.2)))
            }
            .frame(width: 30)

            // Event content
            VStack(alignment: .leading, spacing: 3) {
                Text(event.title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(event.description)
                    .font(.caption)
                    .foregroundColor(.secondary)

                if let outcome = event.outcome {
                    Text(outcome)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            .padding(.vertical, 5)
        }
    }
}

struct PerformanceMeter: View {
    let value: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<5) { index in
                Rectangle()
                    .frame(width: 30, height: 8)
                    .foregroundColor(
                        colorForIndex(index: index, value: value)
                    )
                    .cornerRadius(2)
            }
        }
    }

    private func colorForIndex(index: Int, value: Int) -> Color {
        let threshold = index * 20
        if value > threshold {
            switch index {
            case 0: return .red
            case 1: return .orange
            case 2: return .yellow
            case 3: return .green
            case 4: return .blue
            default: return .gray.opacity(0.3)
            }
        } else {
            return .gray.opacity(0.3)
        }
    }
}

struct RelationshipRow: View {
    let relationship: Relationship

    var emoji: String {
        switch relationship.type {
        case .parent: return "👨‍👦"
        case .sibling: return "👫"
        case .child: return "👶"
        case .friend: return "🤝"
        case .significantOther: return "❤️"
        case .spouse: return "💍"
        case .exSpouse: return "💔"
        case .coworker: return "👔"
        case .romantic: return "💕"
        @unknown default: return "👤"
        }
    }

    var body: some View {
        HStack {
            Text(emoji)
                .font(.title2)
                .frame(width: 40)

            VStack(alignment: .leading) {
                Text(relationship.name)
                    .fontWeight(.medium)

                Text(relationship.type.rawValue.capitalized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing) {
                Text("\(relationship.years) years")
                    .font(.caption)

                // Closeness indicator
                HStack(spacing: 1) {
                    ForEach(0..<5) { index in
                        Image(systemName: "heart.fill")
                            .font(.system(size: 8))
                            .foregroundColor(
                                index < relationship.closeness / 20 ?
                                .red : .gray.opacity(0.3)
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}

// MARK: - Job Offers View
struct JobOffersView: View {
    let careers: [Career]
    let onAccept: (Career) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(careers, id: \.id) { career in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(career.title)")
                            .font(.headline)

                        Text("at \(career.company)")
                            .font(.subheadline)

                        Text("Salary: $\(Int(career.salary).formattedWithSeparator())/year")
                            .font(.body)
                            .foregroundColor(.green)
                            .padding(.top, 2)

                        Button(action: {
                            onAccept(career)
                        }) {
                            Text("Accept Job")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.top, 5)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("Job Offers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
