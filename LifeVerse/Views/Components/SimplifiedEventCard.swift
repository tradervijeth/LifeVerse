//
//  SimplifiedEventCard.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 26/04/2025.
//

import SwiftUI

struct SimplifiedEventCard: View {
    let event: LifeEvent
    let makeChoice: (EventChoice) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                // Event type icon
                Image(systemName: iconForEventType(event.type))
                    .font(.system(size: 16))
                    .foregroundColor(colorForEventType(event.type))
                    .frame(width: 32, height: 32)
                    .background(colorForEventType(event.type).opacity(0.1))
                    .clipShape(Circle())
                
                Text(event.title)
                    .font(.headline)
            }
            
            Text(event.description)
                .font(.body)
                .foregroundColor(.primary)
            
            if let outcome = event.outcome {
                Text(outcome)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.top, 2)
            }
            
            if let choices = event.choices, event.outcome == nil {
                VStack(spacing: 8) {
                    ForEach(choices) { choice in
                        Button(action: {
                            makeChoice(choice)
                        }) {
                            Text(choice.text)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(12)
    }
    
    // Helper to determine icon based on event type
    private func iconForEventType(_ type: LifeEvent.EventType) -> String {
        switch type {
        case .birth: return "figure.wave"
        case .school, .graduation: return "graduationcap.fill"
        case .career: return "briefcase.fill"
        case .relationship: return "heart.fill"
        case .health: return "heart.text.square.fill"
        case .financial: return "dollarsign.circle.fill"
        case .random: return "sparkles"
        case .death: return "cross.fill"
        }
    }
    
    // Helper to determine color based on event type
    private func colorForEventType(_ type: LifeEvent.EventType) -> Color {
        switch type {
        case .birth: return .blue
        case .school, .graduation: return .orange
        case .career: return .indigo
        case .relationship: return .pink
        case .health: return .red
        case .financial: return .green
        case .random: return .purple
        case .death: return .gray
        }
    }
}
