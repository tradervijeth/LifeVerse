//
//  GameOverView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let character = gameManager.character {
                Text("\(character.name)'s Life")
                    .font(.title)
                
                Text("Born: \(character.birthYear) - Died: \(character.birthYear + character.age)")
                    .font(.headline)
                
                Text("Lived to age \(character.age)")
                    .font(.subheadline)
                
                Divider()
                
                Text("Life Events")
                    .font(.title2)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(character.lifeEvents, id: \.id) { event in
                            HStack(alignment: .top) {
                                Text("Age \(event.year - character.birthYear):")
                                    .fontWeight(.bold)
                                
                                VStack(alignment: .leading) {
                                    Text(event.title)
                                        .fontWeight(.semibold)
                                    Text(event.description)
                                        .font(.body)
                                    if let outcome = event.outcome {
                                        Text(outcome)
                                            .font(.body)
                                            .italic()
                                    }
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    }
                    .padding()
                }
                
                Button(action: {
                    gameManager.gameStarted = false
                    gameManager.gameEnded = false
                }) {
                    Text("Start New Life")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}
