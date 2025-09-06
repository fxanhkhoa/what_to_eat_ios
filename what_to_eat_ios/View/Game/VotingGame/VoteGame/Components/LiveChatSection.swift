//
//  LiveChatSection.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 24/8/25.
//

import SwiftUI

struct LiveChatSection: View {
    let voteGameId: String
    @Binding var showingChat: Bool
    let chatSocketService: ChatSocketService
    let localization: LocalizationService
    
    @State private var messages: [ChatMessage] = []
    @State private var newMessage: String = ""
    
    var body: some View {
        VStack(spacing: 12) {
            // Chat Header
            HStack {
                Image(systemName: "bubble.left.and.bubble.right")
                    .foregroundColor(Color("PrimaryColor"))
                Text(localization.localizedString(for: "live_chat"))
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    showingChat.toggle()
                }) {
                    Image(systemName: showingChat ? "chevron.down" : "chevron.up")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            if showingChat {
                RealTimeChatView(roomId: voteGameId, roomType: .voteGame, chatService: chatSocketService)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    LiveChatSection(
        voteGameId: "sample-vote-id",
        showingChat: .constant(true),
        chatSocketService: ChatSocketService(),
        localization: LocalizationService.shared
    )
    .padding()
}
