//
//  CharacterInfoHeader.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//

import SwiftUI

struct CharacterInfoHeader: View {
    let character: Character
    let currentYear: Int
    
    var body: some View {
        VStack(spacing: 6) {
            // Character name and age
            HStack {
                Text("\(character.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Age \(character.age)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Year
            Text("\(currentYear)")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 4)
            
            // Stats with emojis
            HStack(spacing: 8) {
                EmojiStatView(label: "Health", emoji: "❤️", value: character.health, color: .red)
                EmojiStatView(label: "Happy", emoji: "😊", value: character.happiness, color: .yellow)
                EmojiStatView(label: "Smart", emoji: "🧠", value: character.intelligence, color: .blue)
                EmojiStatView(label: "Looks", emoji: "😎", value: character.looks, color: .purple)
                EmojiStatView(label: "Fitness", emoji: "💪", value: character.athleticism, color: .green)
            }
            .padding(.horizontal)
            
            // Money
            HStack {
                Text("💰")
                    .font(.title3)
                
                Text("$\(Int(character.money).formattedWithSeparator())")
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .padding(.top, 4)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
        .padding(.horizontal)
    }
}

// Extension to format number with thousand separators
extension Int {
    func formattedWithSeparator() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}