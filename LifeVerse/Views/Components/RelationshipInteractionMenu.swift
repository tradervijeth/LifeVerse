//
//  RelationshipInteractionMenu.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 26/04/2025.
//

import SwiftUI

struct RelationshipInteractionMenu: View {
    let relationship: Relationship
    let onDismiss: () -> Void
    let onInteraction: (RelationshipInteraction) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Interact with \(relationship.name)")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .font(.title3)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            
            Divider()
            
            // Interaction options
            ScrollView {
                VStack(spacing: 0) {
                    // Always show these basic interactions
                    interactionButton(title: "Spend Time", icon: "clock.fill", color: .blue, interaction: .spendTime)
                    interactionButton(title: "Give a Gift", icon: "gift.fill", color: .purple, interaction: .gift)
                    interactionButton(title: "Deep Conversation", icon: "bubble.left.and.bubble.right.fill", color: .green, interaction: .deepTalk)
                    
                    // Show these for romantic relationships
                    if relationship.type == .significantOther || relationship.type == .spouse {
                        interactionButton(title: "Romantic Date", icon: "heart.fill", color: .red, interaction: .romance)
                        
                        // More serious options based on closeness
                        if relationship.closeness > 60 {
                            if relationship.type == .significantOther {
                                interactionButton(title: "Move In Together", icon: "house.fill", color: .orange, interaction: .moveIn)
                                
                                if relationship.closeness > 80 {
                                    interactionButton(title: "Propose", icon: "ring", color: .pink, interaction: .propose)
                                }
                            } else if relationship.type == .spouse {
                                interactionButton(title: "Plan Something Special", icon: "star.fill", color: .yellow, interaction: .planWedding)
                            }
                        }
                    }
                    
                    // Negative interactions
                    Divider()
                        .padding(.vertical, 8)
                    
                    interactionButton(title: "Argue", icon: "exclamationmark.bubble.fill", color: .orange, interaction: .argue)
                    
                    if relationship.type == .significantOther || relationship.type == .spouse {
                        interactionButton(title: "Break Up", icon: "heart.slash.fill", color: .red, interaction: .breakUp)
                    }
                }
            }
            .background(Color.white)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    private func interactionButton(title: String, icon: String, color: Color, interaction: RelationshipInteraction) -> some View {
        Button(action: {
            onInteraction(interaction)
        }) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .background(
            Rectangle()
                .fill(Color.white)
                .cornerRadius(0)
        )
    }
}

// Define the relationship interaction types
enum RelationshipInteraction {
    case spendTime
    case gift
    case deepTalk
    case romance
    case moveIn
    case propose
    case planWedding
    case argue
    case breakUp
}
