//
//  SaveSystem.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import Foundation

class SaveSystem {
    static let saveKey = "lifeVerseGameSave"
    
    static func saveGame(gameManager: GameManager) -> Bool {
        guard let character = gameManager.character else { return false }
        
        do {
            let encoder = JSONEncoder()
            let characterData = try encoder.encode(character)
            
            let saveDict: [String: Any] = [
                "characterData": characterData,
                "currentYear": gameManager.currentYear,
                "gameStarted": gameManager.gameStarted,
                "gameEnded": gameManager.gameEnded
            ]
            
            UserDefaults.standard.set(saveDict, forKey: saveKey)
            return true
        } catch {
            print("Failed to save game: \(error)")
            return false
        }
    }
    
    static func loadGame() -> GameManager? {
        guard let saveDict = UserDefaults.standard.dictionary(forKey: saveKey),
              let characterData = saveDict["characterData"] as? Data,
              let currentYear = saveDict["currentYear"] as? Int,
              let gameStarted = saveDict["gameStarted"] as? Bool,
              let gameEnded = saveDict["gameEnded"] as? Bool else {
            return nil
        }
        
        do {
            let decoder = JSONDecoder()
            let character = try decoder.decode(Character.self, from: characterData)
            
            let gameManager = GameManager()
            gameManager.character = character
            gameManager.currentYear = currentYear
            gameManager.gameStarted = gameStarted
            gameManager.gameEnded = gameEnded
            
            return gameManager
        } catch {
            print("Failed to load game: \(error)")
            return nil
        }
    }
}
