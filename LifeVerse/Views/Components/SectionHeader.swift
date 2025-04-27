//
//  SectionHeader.swift
//  LifeVerse
//
//  Created by Vithushan Jeyapahan on 26/04/2025.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let icon: String
    var showAddButton: Bool = false
    var addAction: (() -> Void)? = nil
    
    var body: some View {
        HStack {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                
                Text(title)
                    .font(.headline)
            }
            
            Spacer()
            
            if showAddButton, let action = addAction {
                Button(action: action) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
            }
        }
    }
}
