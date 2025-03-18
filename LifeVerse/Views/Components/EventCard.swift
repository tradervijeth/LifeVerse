//
//  EventCard.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct EventCard: View {
    let event: LifeEvent
    let makeChoice: (EventChoice) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(event.title)
                .font(.headline)
            
            Text(event.description)
                .font(.body)
            
            if let outcome = event.outcome {
                Text(outcome)
                    .font(.body)
                    .italic()
                    .padding(.top, 5)
            }
            
            if let choices = event.choices, event.outcome == nil {
                ForEach(choices) { choice in
                    Button(action: {
                        makeChoice(choice)
                    }) {
                        Text(choice.text)
                            .foregroundColor(.white)
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(5)
                    }
                    .padding(.top, 5)
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
}
