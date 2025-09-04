//
//  StatisticCard.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 4/9/25.
//

import SwiftUI

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    HStack {
        StatisticCard(
            title: "Total Votes",
            value: "42",
            icon: "hand.raised.fill",
            color: .blue
        )
        
        StatisticCard(
            title: "Total Dishes",
            value: "8",
            icon: "fork.knife",
            color: .green
        )
        
        StatisticCard(
            title: "Created",
            value: "Today",
            icon: "calendar",
            color: .gray
        )
    }
    .padding()
}