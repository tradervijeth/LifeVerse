//
//  StatView.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 18/03/2025.
//
import SwiftUI

struct StatView: View {
    let label: String
    let value: Int
    let color: Color
    
    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
            ZStack(alignment: .bottom) {
                Rectangle()
                    .frame(width: 20, height: 60)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Rectangle()
                    .frame(width: 20, height: CGFloat(value) / 100 * 60)
                    .foregroundColor(color)
            }
            Text("\(value)")
                .font(.caption)
        }
    }
}

