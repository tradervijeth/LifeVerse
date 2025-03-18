//
//  GameplayView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct GameplayView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack {
            // Character info header
            if let character = gameManager.character {
                CharacterInfoHeader(character: character, currentYear: gameManager.currentYear)
            }
            
            // Current events
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("Age \(gameManager.character?.age ?? 0) Events")
                        .font(.headline)
                    
                    ForEach(gameManager.currentEvents, id: \.id) { event in
                        EventCard(event: event, makeChoice: { choice in
                            gameManager.makeChoice(for: event, choice: choice)
                        })
                    }
                }
                .padding()
            }
            
            // Age up button
            Button(action: {
                gameManager.advanceYear()
            }) {
                Text("Age Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
            }
            .padding()
        }
    }
}
