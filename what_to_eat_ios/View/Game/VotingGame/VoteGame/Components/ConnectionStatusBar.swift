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
    
    var body: some View {
        HStack {
            Circle()
                .fill(isConnected ? Color.green : Color.red)
                .frame(width: 8, height: 8)
            
            Text(isConnected ? "Live" : "Disconnected")
                .font(.caption)
                .foregroundColor(isConnected ? .green : .red)
            
            Spacer()
            
            if !isConnected {
                Button("Reconnect") {
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