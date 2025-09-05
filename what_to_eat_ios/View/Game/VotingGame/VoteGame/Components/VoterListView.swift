//
//  VoterListView.swift
//  what_to_eat_ios
//
//  Created by GitHub Copilot on 5/9/25.
//

import SwiftUI
import Combine

struct VoterListView: View {
    let userIds: [String]
    let anonymousCount: Int
    
    @StateObject private var userService = UserService.shared
    @State private var users: [UserModel] = []
    @State private var isLoading = false
    @State private var cancellables = Set<AnyCancellable>()
    let localization = LocalizationService.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !users.isEmpty || anonymousCount > 0 {
                Text(String(format: localization.localizedString(for: "voters_count"), users.count + anonymousCount))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVStack(alignment: .leading, spacing: 4) {
                    // Show registered users
                    ForEach(users, id: \.id) { user in
                        VoterRowView(user: user)
                    }
                    
                    // Show anonymous voters count
                    if anonymousCount > 0 {
                        HStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.badge.questionmark")
                                .foregroundColor(.secondary)
                                .font(.caption)
                            
                            Text(String(format: localization.localizedString(for: anonymousCount == 1 ? "voter_singular" : "voter_plural"), anonymousCount))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if isLoading && users.isEmpty {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.7)
                        Text(localization.localizedString(for: "loading_voters"))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            loadUsers()
        }
        .onChange(of: userIds) {
            loadUsers()
        }
    }
    
    private func loadUsers() {
        guard !userIds.isEmpty else {
            users = []
            return
        }
        
        isLoading = true
        cancellables.removeAll()
        
        let userPublishers = userIds.map { userId in
            userService.findOne(id: userId)
                .catch { _ in Empty<UserModel, Never>() }
        }
        
        Publishers.MergeMany(userPublishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in
                    isLoading = false
                },
                receiveValue: { fetchedUsers in
                    users = fetchedUsers.sorted { $0.name ?? $0.email < $1.name ?? $1.email }
                    isLoading = false
                }
            )
            .store(in: &cancellables)
    }
}

struct VoterRowView: View {
    let user: UserModel
    
    var displayName: String {
        user.name?.isEmpty == false ? user.name! : user.email
    }
    
    var body: some View {
        HStack(spacing: 8) {
            AsyncImage(url: URL(string: user.avatar ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Image(systemName: "person.crop.circle.fill")
                    .foregroundColor(.secondary)
            }
            .frame(width: 16, height: 16)
            .clipShape(Circle())
            
            Text(displayName)
                .font(.caption2)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        VoterListView(userIds: ["user1", "user2"], anonymousCount: 3)
        VoterListView(userIds: [], anonymousCount: 2)
        VoterListView(userIds: ["user1"], anonymousCount: 0)
    }
    .padding()
}
