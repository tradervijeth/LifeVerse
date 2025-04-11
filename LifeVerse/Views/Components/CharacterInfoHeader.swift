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
    let bankManager: BankManager

    var body: some View {
        CharacterHeaderModern(character: character, currentYear: currentYear, bankManager: bankManager)
    }
}

// Extensions for Int formatting are now in Utilities/Extensions.swift
