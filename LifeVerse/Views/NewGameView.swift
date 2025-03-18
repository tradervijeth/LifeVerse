//
//  NewGameView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct NewGameView: View {
    @ObservedObject var gameManager: GameManager
    @State private var name: String = ""
    @State private var birthYear: Int = Calendar.current.component(.year, from: Date()) - 18
    @State private var selectedGender: Gender = .male
    
    var body: some View {
        VStack(spacing: 20) {
            Text("LIFE VERSE")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Create Your Character")
                .font(.title2)
            
            TextField("Name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            HStack {
                Text("Birth Year:")
                Picker("Birth Year", selection: $birthYear) {
                    ForEach((1920...Calendar.current.component(.year, from: Date())), id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
            }
            
            HStack {
                Text("Gender:")
                Picker("Gender", selection: $selectedGender) {
                    ForEach(Gender.allCases, id: \.self) { gender in
                        Text(gender.rawValue).tag(gender)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .padding(.horizontal)
            
            Button(action: {
                gameManager.startNewGame(name: name, birthYear: birthYear, gender: selectedGender)
            }) {
                Text("Start Life")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .disabled(name.isEmpty)
        }
        .padding()
    }
}
