//
//  AgeUpView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct AgeUpView: View {
    @ObservedObject var gameManager: GameManager
    @Binding var isPresented: Bool
    @State private var animationProgress = 0.0
    @State private var showSummary = false
    @State private var yearSummary: YearSummary?
    
    var body: some View {
        VStack {
            if showSummary, let summary = yearSummary {
                yearSummaryView(summary)
            } else {
                ageUpProgressView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemBackground))
        .onAppear {
            startAgeUpAnimation()
        }
    }
    
    var ageUpProgressView: some View {
        VStack(spacing: 30) {
            Text("Getting Older...")
                .font(.title)
                .fontWeight(.bold)
            
            if let character = gameManager.character {
                Text("\(character.age) → \(character.age + 1)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.blue)
            }
            
            // Progress animation
            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 12)
                    .foregroundColor(.gray.opacity(0.3))
                    .cornerRadius(6)
                
                Rectangle()
                    .frame(width: CGFloat(animationProgress) * 300, height: 12)
                    .foregroundColor(.green)
                    .cornerRadius(6)
            }
            .frame(width: 300)
        }
        .padding()
    }
    
    func yearSummaryView(_ summary: YearSummary) -> some View {
        VStack(spacing: 20) {
            Text("Year in Review")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Age \(summary.age)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 15) {
                let hasCareer = summary.career != nil
                if hasCareer {
                    let career = summary.career!
                    HStack {
                        Image(systemName: "briefcase.fill")
                            .foregroundColor(.blue)
                        Text("Career")
                            .font(.headline)
                    }
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(career.title) at \(career.company)")
                            .font(.subheadline)
                        Text("Salary: $\(Int(career.salary).formattedWithSeparator())")
                            .font(.subheadline)
                        
                        if summary.incomeAdded > 0 {
                            Text("Added $\(Int(summary.incomeAdded).formattedWithSeparator()) to your account")
                                .foregroundColor(.green)
                                .font(.caption)
                                .padding(.top, 2)
                        }
                    }
                    .padding(.leading)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.purple)
                    Text("Stats Changes")
                        .font(.headline)
                }
                
                ForEach(summary.statChanges, id: \.attribute) { change in
                    HStack {
                        Text(change.attribute.capitalized)
                            .font(.subheadline)
                        Spacer()
                        Text(change.change > 0 ? "+\(change.change)" : "\(change.change)")
                            .foregroundColor(change.change > 0 ? .green : .red)
                    }
                    .padding(.horizontal)
                }
                
                Divider()
                
                HStack {
                    Image(systemName: "calendar")
                        .foregroundColor(.orange)
                    Text("Events")
                        .font(.headline)
                }
                
                ForEach(summary.events, id: \.id) { event in
                    VStack(alignment: .leading, spacing: 3) {
                        Text(event.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if let outcome = event.outcome {
                            Text(outcome)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 3)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.horizontal)
            
            Button(action: {
                isPresented = false
            }) {
                Text("Continue")
                    .fontWeight(.medium)
                    .padding()
                    .frame(width: 200)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
        .padding()
    }
    
    private func startAgeUpAnimation() {
        // Animate the progress bar
        withAnimation(.linear(duration: 1.5)) {
            animationProgress = 1.0
        }
        
        // After animation completes, advance the year and show summary
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            // Capture state before advancing
            let beforeHealth = gameManager.character?.health ?? 0
            let beforeHappiness = gameManager.character?.happiness ?? 0
            let beforeIntelligence = gameManager.character?.intelligence ?? 0
            let beforeLooks = gameManager.character?.looks ?? 0
            let beforeAthleticism = gameManager.character?.athleticism ?? 0
            let beforeMoney = gameManager.character?.money ?? 0
            
            // Progress the game
            gameManager.advanceYear()
            
            // If the character died, close the sheet
            if gameManager.gameEnded {
                isPresented = false
                return
            }
            
            // Create year summary
            if let character = gameManager.character {
                // Calculate stat changes
                var statChanges: [StatChange] = []
                if character.health != beforeHealth {
                    statChanges.append(StatChange(attribute: "health", change: character.health - beforeHealth))
                }
                if character.happiness != beforeHappiness {
                    statChanges.append(StatChange(attribute: "happiness", change: character.happiness - beforeHappiness))
                }
                if character.intelligence != beforeIntelligence {
                    statChanges.append(StatChange(attribute: "intelligence", change: character.intelligence - beforeIntelligence))
                }
                if character.looks != beforeLooks {
                    statChanges.append(StatChange(attribute: "looks", change: character.looks - beforeLooks))
                }
                if character.athleticism != beforeAthleticism {
                    statChanges.append(StatChange(attribute: "athleticism", change: character.athleticism - beforeAthleticism))
                }
                
                // Calculate income added (excluding effects from events to avoid double counting)
                var incomeAdded: Double = 0
                let hasCareer = character.career != nil
                if hasCareer {
                    incomeAdded = character.money - beforeMoney
                    // If money decreased, don't show negative income (that would be from events)
                    if incomeAdded < 0 {
                        incomeAdded = 0
                    }
                }
                
                yearSummary = YearSummary(
                    age: character.age,
                    career: character.career,
                    statChanges: statChanges,
                    events: gameManager.currentEvents,
                    incomeAdded: incomeAdded
                )
                
                showSummary = true
            }
        }
    }
}

// MARK: - Supporting Types

struct YearSummary {
    let age: Int
    let career: Career?
    let statChanges: [StatChange]
    let events: [LifeEvent]
    let incomeAdded: Double
}

struct StatChange {
    let attribute: String
    let change: Int
}