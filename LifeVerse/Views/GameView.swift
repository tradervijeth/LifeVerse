//
//  GameView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct GameView: View {
    @ObservedObject var gameManager: GameManager
    
    var body: some View {
        if gameManager.gameStarted {
            if gameManager.gameEnded {
                GameOverView(gameManager: gameManager)
            } else {
                GameplayView(gameManager: gameManager)
            }
        } else {
            NewGameView(gameManager: gameManager)
        }
    }
}

