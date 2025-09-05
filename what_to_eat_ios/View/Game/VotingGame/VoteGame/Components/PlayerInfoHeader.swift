//
//  PlayerInfoHeader.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct PlayerInfoHeader: View {
    let playerName: String
    
    let localization = LocalizationService.shared
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color("PrimaryColor"))
                
                Text(String(format: localization.localizedString(for: "playing_as"), playerName))
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color("PrimaryColor").opacity(0.1))
            .cornerRadius(20)
            
            Spacer()
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        PlayerInfoHeader(playerName: "John Doe")
        PlayerInfoHeader(playerName: "Anonymous User")
    }
    .padding()
}
