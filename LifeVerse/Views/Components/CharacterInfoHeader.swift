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
        VStack(spacing: 5) {
            Text("\(character.name), Age \(character.age)")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(currentYear)")
                .font(.subheadline)
            
            HStack(spacing: 20) {
                StatView(label: "Health", value: character.health, color: .red)
                StatView(label: "Happy", value: character.happiness, color: .yellow)
                StatView(label: "Intel", value: character.intelligence, color: .blue)
                StatView(label: "Looks", value: character.looks, color: .purple)
                StatView(label: "Athle", value: character.athleticism, color: .green)
            }
            .padding(.vertical, 5)
            
            Text("💰 $\(Int(character.money))")
                .font(.headline)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}
