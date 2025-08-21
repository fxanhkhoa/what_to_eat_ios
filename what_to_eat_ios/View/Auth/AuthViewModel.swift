//
//  AuthViewModel.swift
//  what-to-eat-ios
//
//  Created by System on 18/8/25.
//

import Foundation
import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var showingLogin = false
    
    private var cancellables = Set<AnyCancellable>()
    let authService = AuthService() // Changed from private to public
    
    init() {
        // Subscribe to auth service changes
        authService.$isAuthenticated
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isAuthenticated in
                self?.isAuthenticated = isAuthenticated
                self?.showingLogin = !isAuthenticated
            }
            .store(in: &cancellables)
        
        authService.$user
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    func signOut() {
        authService.signOut()
    }
    
    func deleteAccount() {
        authService.deleteAccount()
    }
}
