//
//  ConnectionStatusBar.swift
//  what_to_eat_ios
//
//  Created by System on 30/8/25.
//

import SwiftUI

struct ConnectionStatusBar: View {
    let isConnected: Bool
    let onReconnect: () -> Void
    
    let localization = LocalizationService.shared
    
    var body: some View {
        HStack {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(isConnected ? localization.localizedString(for: "live") : localization.localizedString(for: "disconnected"))
                .font(.caption)
                .foregroundColor(isConnected ? .green : .red)
            
            Spacer()
            
            if !isConnected {
                Button(localization.localizedString(for: "reconnect")) {
                    onReconnect()
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

#Preview {
    VStack(spacing: 0) {
        ConnectionStatusBar(isConnected: true, onReconnect: {})
        ConnectionStatusBar(isConnected: false, onReconnect: {})
    }
}
