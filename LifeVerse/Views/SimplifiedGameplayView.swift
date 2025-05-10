//
//  SimplifiedGameplayView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 05/04/2025.
//

import SwiftUI

struct SimplifiedGameplayView: View {
    @ObservedObject var gameManager: GameManager
    @State private var selectedTab: String = "Life"
    @State private var showActionSheet: Bool = false
    @State private var showSettingsSheet: Bool = false
    @State private var showRelationshipInteraction: Bool = false
    @State private var selectedRelationship: Relationship?

    // Main tabs
    private let tabs = [
        ("Life", "calendar"),
        ("Relationships", "heart"),
        ("Age Up", "waveform.path.ecg"),
        ("Career", "briefcase"),
        ("Money", "dollarsign.circle"),
        ("Assets", "house")
    ]

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Character info header
                if let character = gameManager.character {
                    characterHeader(character: character)
                }

                // Main content area
                ScrollView {
                    VStack(spacing: 20) {
                        switch selectedTab {
                        case "Life":
                            lifeTabView
                        case "Relationships":
                            relationshipsTabView
                        case "Career":
                            careerTabView
                        case "Money":
                            moneyTabView
                        case "Age Up":
                            // This tab doesn't have content as it's just a button
                            Text("Tap the Age Up button to advance to the next year")
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding()
                        case "Assets":
                            assetsTabView
                        default:
                            lifeTabView
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80) // Space for bottom navigation
                }

                // Bottom navigation bar
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.0) { tab in
                        if tab.0 == "Age Up" {
                            // Special Age Up button
                            Button(action: {
                                gameManager.advanceYear()
                            }) {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.1)
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)

                                    Text(tab.0)
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(Color.red)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal, 4)
                        } else {
                            // Regular navigation tab
                            MainNavigationTab(
                                title: tab.0,
                                icon: tab.1,
                                isSelected: selectedTab == tab.0,
                                action: {
                                    selectedTab = tab.0
                                }
                            )
                        }
                    }
                }
                .padding(.vertical, 5)
                .background(Color(UIColor.secondarySystemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -2)
            }

            // Relationship interaction sheet
            if showRelationshipInteraction, let relationship = selectedRelationship {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showRelationshipInteraction = false
                    }

                RelationshipInteractionMenu(
                    relationship: relationship,
                    onDismiss: {
                        showRelationshipInteraction = false
                    },
                    onInteraction: { interaction in
                        handleRelationshipInteraction(interaction, with: relationship)
                        showRelationshipInteraction = false
                    }
                )
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showRelationshipInteraction)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2)
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            Text("Settings")
                .font(.title)
                .padding()

            Button("Close") {
                showSettingsSheet = false
            }
            .padding()
        }
    }

    // MARK: - Character Header
    private func characterHeader(character: Character) -> some View {
        VStack(spacing: 0) {
            HStack {
                // Character info
                VStack(alignment: .leading, spacing: 4) {
                    Text(character.name)
                        .font(.headline)

                    Text("Age: \(character.age) • Year: \(gameManager.currentYear)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Settings button
                Button(action: {
                    showSettingsSheet = true
                }) {
                    Image(systemName: "gear")
                        .font(.system(size: 20))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            // Stats bar
            HStack(spacing: 20) {
                statIndicator(value: character.health, icon: "heart.fill", color: .red)
                statIndicator(value: character.happiness, icon: "face.smiling.fill", color: .yellow)
                statIndicator(value: character.intelligence, icon: "brain.fill", color: .blue)
                statIndicator(value: character.looks, icon: "person.fill", color: .purple)

                Spacer()

                // Money display
                HStack(spacing: 4) {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.green)

                    Text("$\(Int(character.money).formattedWithSeparator())")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 10)

            Divider()
        }
        .background(Color(UIColor.secondarySystemBackground))
    }

    private func statIndicator(value: Int, icon: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12))

            Text("\(value)")
                .font(.system(size: 14, weight: .medium))
        }
    }

    // MARK: - Life Tab
    private var lifeTabView: some View {
        VStack(spacing: 20) {
            // Current events section
            SectionHeader(title: "Current Events", icon: "calendar")

            if gameManager.currentEvents.isEmpty {
                Text("No current events. Age up to continue your life journey.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            } else {
                ForEach(gameManager.currentEvents) { event in
                    SimplifiedEventCard(event: event) { choice in
                        gameManager.makeChoice(for: event, choice: choice)
                    }
                }
            }

            // Life timeline section
            SectionHeader(title: "Life Timeline", icon: "clock.arrow.circlepath")

            if gameManager.character?.lifeEvents.isEmpty ?? true {
                Text("Your life story will appear here as you age up.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            } else {
                ForEach(gameManager.character?.lifeEvents.suffix(5).reversed() ?? []) { event in
                    timelineEventRow(event: event)
                }

                if (gameManager.character?.lifeEvents.count ?? 0) > 5 {
                    Button(action: {
                        // Show full timeline
                    }) {
                        Text("View Full Timeline")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.blue)
                            .padding(.vertical, 10)
                    }
                }
            }
        }
        .padding(.top)
    }

    private func timelineEventRow(event: LifeEvent) -> some View {
        HStack(spacing: 15) {
            // Year indicator
            Text("\(event.year)")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, height: 24)
                .background(Color.blue)
                .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(event.title)
                    .font(.system(size: 16, weight: .medium))

                Text(event.description)
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }

    // MARK: - Relationships Tab
    private var relationshipsTabView: some View {
        VStack(spacing: 20) {
            // Relationships section
            SectionHeader(
                title: "Your Relationships",
                icon: "person.2.fill",
                showAddButton: true,
                addAction: {
                    // Show relationship finder
                }
            )

            if gameManager.character?.relationships.isEmpty ?? true {
                Text("You don't have any relationships yet. Age up or use the + button to find new people.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            } else {
                ForEach(gameManager.character?.relationships ?? []) { relationship in
                    SimplifiedRelationshipCard(
                        relationship: relationship,
                        onTap: {
                            selectedRelationship = relationship
                            showRelationshipInteraction = true
                        },
                        onAction: {
                            // Quick action - spend time
                            if let index = gameManager.character?.relationships.firstIndex(where: { $0.id == relationship.id }) {
                                gameManager.interactWithRelationship(at: index, interaction: .spendTime)
                            }
                        }
                    )
                }
            }

            // Quick actions
            SectionHeader(title: "Quick Actions", icon: "bolt.fill")

            HStack {
                ActionButton(
                    title: "Find Friends",
                    icon: "person.badge.plus",
                    color: .blue
                ) {
                    // Show friend finder
                }

                ActionButton(
                    title: "Dating App",
                    icon: "heart.fill",
                    color: .pink
                ) {
                    // Show dating app
                }
            }

            if !(gameManager.character?.relationships.isEmpty ?? true) {
                ActionButton(
                    title: "Group Gathering",
                    icon: "person.3.fill",
                    color: .purple
                ) {
                    gameManager.spendTimeWithAllRelationships()
                }
            }
        }
        .padding(.top)
    }

    // MARK: - Career Tab
    private var careerTabView: some View {
        VStack(spacing: 20) {
            // Current career section
            SectionHeader(title: "Career", icon: "briefcase.fill")

            if let career = gameManager.character?.career {
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(career.title)
                                .font(.headline)

                            Text("at \(career.company)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        // Performance indicator
                        HStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundColor(.green)

                            Text("Performance: \(career.performanceRating)%")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                    }

                    Divider()

                    // Salary info
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Annual Salary")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("$\(Int(career.salary).formattedWithSeparator())")
                                .font(.title3)
                                .foregroundColor(.green)
                        }

                        Spacer()

                        // Years at company
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Years at Company")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("\(career.yearsAtJob)")
                                .font(.title3)
                        }
                    }

                    Divider()

                    // Career actions
                    HStack {
                        ActionButton(
                            title: "Work Harder",
                            icon: "arrow.up.forward.circle.fill",
                            color: .blue
                        ) {
                            // Work harder action
                            if let career = gameManager.character?.career {
                                gameManager.createEvent(
                                    title: "Working Hard",
                                    description: "You put in extra effort at your job as \(career.title).",
                                    type: .career
                                )
                            }
                        }

                        ActionButton(
                            title: "Ask for Raise",
                            icon: "dollarsign.circle.fill",
                            color: .green
                        ) {
                            // Ask for raise action
                            if let career = gameManager.character?.career {
                                gameManager.createEvent(
                                    title: "Asking for a Raise",
                                    description: "You asked for a raise at \(career.company).",
                                    type: .career
                                )
                            }
                        }
                    }

                    ActionButton(
                        title: "Look for New Job",
                        icon: "briefcase.fill",
                        color: .purple
                    ) {
                        // Find new job action
                        gameManager.createEvent(
                            title: "Job Search",
                            description: "You're looking for a new job opportunity.",
                            type: .career
                        )
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            } else {
                VStack(spacing: 15) {
                    Text("You don't have a job yet")
                        .font(.headline)

                    Text("Find a job to start your career")
                        .foregroundColor(.secondary)

                    Button(action: {
                        // Find new job action
                        gameManager.createEvent(
                            title: "Job Search",
                            description: "You're looking for your first job.",
                            type: .career
                        )
                    }) {
                        HStack {
                            Image(systemName: "briefcase.fill")
                            Text("Find a Job")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(12)
            }

            // Education section
            SectionHeader(title: "Education", icon: "book.fill")

            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Current Education")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text(gameManager.character?.education.rawValue ?? "None")
                            .font(.headline)
                    }

                    Spacer()

                    // Education actions
                    Button(action: {
                        // Show education options
                    }) {
                        Text("Continue Education")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.orange)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .padding(.top)
    }

    // MARK: - Money Tab
    private var moneyTabView: some View {
        VStack(spacing: 20) {
            // Financial overview
            SectionHeader(title: "Financial Overview", icon: "chart.pie.fill")

            VStack(spacing: 15) {
                // Net worth
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Net Worth")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("$\(Int(gameManager.getBankingNetWorth()).formattedWithSeparator())")
                            .font(.title2)
                            .foregroundColor(.green)
                    }

                    Spacer()

                    // Credit score
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Credit Score")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("\(gameManager.bankManager.creditScore)")
                            .font(.title2)
                            .foregroundColor(creditScoreColor)
                    }
                }

                Divider()

                // Cash and income
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Cash")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("$\(Int(gameManager.character?.money ?? 0).formattedWithSeparator())")
                            .font(.headline)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Monthly Income")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Text("$\(Int((gameManager.character?.career?.salary ?? 0) / 12).formattedWithSeparator())")
                            .font(.headline)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)

            // Bank accounts
            SectionHeader(
                title: "Bank Accounts",
                icon: "building.columns.fill",
                showAddButton: true,
                addAction: {
                    // Show new account options
                }
            )

            let accounts = gameManager.bankManager.getActiveAccounts()

            if accounts.isEmpty {
                Text("You don't have any bank accounts yet. Open an account to start managing your finances.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            } else {
                ForEach(accounts) { account in
                    bankAccountCard(account: account)
                }
            }

            // Quick actions
            SectionHeader(title: "Quick Actions", icon: "bolt.fill")

            HStack {
                ActionButton(
                    title: "Banking",
                    icon: "building.columns.fill",
                    color: .blue
                ) {
                    // Show full banking view
                }

                ActionButton(
                    title: "Investments",
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                ) {
                    // Show investments view
                }
            }
        }
        .padding(.top)
    }

    private func bankAccountCard(account: BankAccount) -> some View {
        HStack {
            // Account icon
            Image(systemName: accountIcon(account.accountType))
                .font(.system(size: 24))
                .foregroundColor(accountColor(account.accountType))
                .frame(width: 50, height: 50)
                .background(accountColor(account.accountType).opacity(0.1))
                .clipShape(Circle())

            // Account details
            VStack(alignment: .leading, spacing: 4) {
                Text(account.accountType.rawValue)
                    .font(.system(size: 16, weight: .medium))

                Text("Bank Account")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("$\(Int(account.balance).formattedWithSeparator())")
                    .font(.headline)
                    .foregroundColor(account.balance >= 0 ? .green : .red)
            }

            Spacer()

            // Interest rate if applicable
            if account.interestRate > 0 {
                Text("\(String(format: "%.2f", account.interestRate * 100))%")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Assets Tab
    private var assetsTabView: some View {
        VStack(spacing: 20) {
            // Properties section
            SectionHeader(
                title: "Properties",
                icon: "house.fill",
                showAddButton: true,
                addAction: {
                    // Show property purchase options
                }
            )

            let properties = gameManager.bankManager.getPropertyInvestments()

            if properties.isEmpty {
                Text("You don't own any properties yet. Buy a property to start building your real estate portfolio.")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
            } else {
                ForEach(properties) { property in
                    propertyCard(property: property)
                }
            }

            // Vehicles section
            SectionHeader(
                title: "Vehicles",
                icon: "car.fill",
                showAddButton: true,
                addAction: {
                    // Show vehicle purchase options
                }
            )

            // No vehicles implementation yet

            Text("You don't own any vehicles yet. Buy a vehicle to improve your transportation options.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)

            // Other assets section
            SectionHeader(title: "Other Assets", icon: "briefcase.fill")

            Text("Other valuable assets you own will appear here.")
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
        }
        .padding(.top)
    }

    private func propertyCard(property: PropertyInvestment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(property.propertyType.rawValue)
                        .font(.headline)

                    Text(property.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Property status
                Text(property.isRental ? "Rental" : "Residence")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(property.isRental ? Color.green : Color.blue)
                    .cornerRadius(8)
            }

            Divider()

            // Property value and income
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Value")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Text("$\(Int(property.currentValue).formattedWithSeparator())")
                        .font(.system(size: 16, weight: .medium))
                }

                Spacer()

                if property.isRental {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Monthly Income")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("$\(Int(property.monthlyRent).formattedWithSeparator())")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    private func vehicleCard(vehicle: String) -> some View {
        HStack {
            // Vehicle icon
            Image(systemName: "car.fill")
                .font(.system(size: 24))
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .background(Color.blue.opacity(0.1))
                .clipShape(Circle())

            // Vehicle details
            VStack(alignment: .leading, spacing: 4) {
                Text(vehicle)
                    .font(.system(size: 16, weight: .medium))

                Text("Good Condition")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Text("$25,000")
                    .font(.headline)
            }

            Spacer()
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }

    // MARK: - Helper Methods

    private var creditScoreColor: Color {
        let score = gameManager.bankManager.creditScore
        if score >= 750 { return .green }
        if score >= 670 { return .blue }
        if score >= 580 { return .orange }
        return .red
    }

    private func accountIcon(_ type: BankAccountType) -> String {
        switch type {
        case .checking: return "dollarsign.circle"
        case .savings: return "banknote"
        case .creditCard: return "creditcard"
        case .loan: return "dollarsign.square"
        case .cd: return "timer"
        case .investment: return "chart.line.uptrend.xyaxis"
        case .mortgage: return "house"
        case .autoLoan: return "car"
        case .studentLoan: return "book"
        case .businessAccount: return "briefcase"
        case .retirementAccount: return "leaf"
        @unknown default: return "questionmark.circle"
        }
    }

    private func accountColor(_ type: BankAccountType) -> Color {
        switch type {
        case .checking: return .blue
        case .savings: return .green
        case .creditCard: return .purple
        case .loan, .mortgage, .autoLoan, .studentLoan: return .red
        case .cd: return .orange
        case .investment, .businessAccount, .retirementAccount: return .indigo
        @unknown default: return .gray
        }
    }


    private func handleRelationshipInteraction(_ interaction: RelationshipInteraction, with relationship: Relationship) {
        guard let index = gameManager.character?.relationships.firstIndex(where: { $0.id == relationship.id }) else {
            return
        }

        switch interaction {
        case .spendTime:
            gameManager.interactWithRelationship(at: index, interaction: .spendTime)
        case .gift:
            gameManager.interactWithRelationship(at: index, interaction: .gift)
        case .deepTalk:
            gameManager.interactWithRelationship(at: index, interaction: .deepTalk)
        case .romance:
            gameManager.interactWithRelationship(at: index, interaction: .romance)
        case .moveIn:
            // Handle move in together
            gameManager.interactWithRelationship(at: index, interaction: .deepTalk)
            gameManager.createEvent(title: "Moving In", description: "You decided to move in with \(relationship.name).", type: .relationship)
        case .propose:
            // Handle proposal
            gameManager.interactWithRelationship(at: index, interaction: .romance)
            gameManager.createEvent(title: "Proposal", description: "You're considering proposing to \(relationship.name).", type: .relationship)
        case .planWedding:
            // Handle wedding planning
            gameManager.interactWithRelationship(at: index, interaction: .romance)
            gameManager.createEvent(title: "Wedding Plans", description: "You're planning your wedding with \(relationship.name).", type: .relationship)
        case .argue:
            gameManager.interactWithRelationship(at: index, interaction: .argue)
        case .breakUp:
            // Handle breakup
            gameManager.interactWithRelationship(at: index, interaction: .argue)
            gameManager.createEvent(title: "Relationship End", description: "You decided to end your relationship with \(relationship.name).", type: .relationship)
        @unknown default:
            gameManager.interactWithRelationship(at: index, interaction: .spendTime)
            gameManager.createEvent(title: "Spending Time", description: "You spent time with \(relationship.name).", type: .relationship)
        }
    }
}
