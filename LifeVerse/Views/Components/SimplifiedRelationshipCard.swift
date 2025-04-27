//
//  SimplifiedRelationshipCard.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 26/04/2025.
//

import SwiftUI

struct SimplifiedRelationshipCard: View {
    let relationship: Relationship
    let onTap: () -> Void
    let onAction: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Relationship avatar
                Text(emojiForRelationshipType(relationship.type))
                    .font(.system(size: 28))
                    .frame(width: 50, height: 50)
                    .background(colorForRelationshipType(relationship.type).opacity(0.1))
                    .clipShape(Circle())
                
                // Relationship details
                VStack(alignment: .leading, spacing: 3) {
                    Text(relationship.name)
                        .font(.headline)
                    
                    Text(relationship.type.rawValue.capitalized)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Closeness indicator
                    HStack(spacing: 1) {
                        ForEach(0..<5) { index in
                            Rectangle()
                                .fill(index < relationship.closeness / 20 ? 
                                     colorForRelationshipType(relationship.type) : 
                                     Color.gray.opacity(0.3))
                                .frame(width: 12, height: 4)
                                .cornerRadius(2)
                        }
                    }
                    .padding(.top, 2)
                }
                
                Spacer()
                
                // Quick action button
                Button(action: onAction) {
                    Text("Spend Time")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(colorForRelationshipType(relationship.type))
                        .cornerRadius(15)
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // Helper to determine emoji based on relationship type
    private func emojiForRelationshipType(_ type: Relationship.RelationshipType) -> String {
        switch type {
        case .parent: return "👨‍👦"
        case .sibling: return "👫"
        case .child: return "👶"
        case .friend: return "🤝"
        case .significantOther: return "❤️"
        case .spouse: return "💍"
        case .exSpouse: return "💔"
        case .coworker: return "👔"
        }
    }
    
    // Helper to determine color based on relationship type
    private func colorForRelationshipType(_ type: Relationship.RelationshipType) -> Color {
        switch type {
        case .parent, .child: return .blue
        case .sibling: return .green
        case .friend: return .orange
        case .significantOther: return .pink
        case .spouse: return .red
        case .exSpouse: return .gray
        case .coworker: return .purple
        }
    }
}
