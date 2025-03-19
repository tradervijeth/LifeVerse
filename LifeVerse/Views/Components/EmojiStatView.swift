//
//  EmojiStatView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct EmojiStatView: View {
    let label: String
    let emoji: String
    let value: Int
    let color: Color
    
    // Calculate filled bars based on value (0-100)
    private var filledCount: Int {
        return Int(round(Double(value) / 20.0)) // 5 levels (0-20, 21-40, 41-60, 61-80, 81-100)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            Text(emoji)
                .font(.title2)
            
            // Display value as small bars (filled and unfilled)
            HStack(spacing: 2) {
                ForEach(0..<5) { index in
                    Rectangle()
                        .frame(width: 6, height: 12)
                        .foregroundColor(index < filledCount ? color : color.opacity(0.2))
                        .cornerRadius(1)
                }
            }
            
            Text("\(value)%")
                .font(.system(size: 10))
                .foregroundColor(.gray)
        }
        .frame(minWidth: 60)
    }
}

// Preview provider for SwiftUI canvas
struct EmojiStatView_Previews: PreviewProvider {
    static var previews: some View {
        HStack(spacing: 20) {
            EmojiStatView(label: "Health", emoji: "❤️", value: 80, color: .red)
            EmojiStatView(label: "Happy", emoji: "😊", value: 60, color: .yellow)
            EmojiStatView(label: "Smart", emoji: "🧠", value: 40, color: .blue)
            EmojiStatView(label: "Looks", emoji: "😎", value: 20, color: .purple)
            EmojiStatView(label: "Fitness", emoji: "💪", value: 100, color: .green)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}