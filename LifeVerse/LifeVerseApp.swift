//
//  LifeVerseApp.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//

import SwiftUI

@main
struct LifeVerseApp: App {
    @StateObject private var gameManager = GameManager()
    
    var body: some Scene {
        WindowGroup {
            GameView(gameManager: gameManager)
                .onAppear {
                    // Try to load a saved game on app launch
                    if let loadedManager = SaveSystem.loadGame() {
                        gameManager.character = loadedManager.character
                        gameManager.currentYear = loadedManager.currentYear
                        gameManager.gameStarted = loadedManager.gameStarted
                        gameManager.gameEnded = loadedManager.gameEnded
                    }
                }
                .onDisappear {
                    // Save game when app is closed
                    _ = SaveSystem.saveGame(gameManager: gameManager)
                }
        }
    }
}
