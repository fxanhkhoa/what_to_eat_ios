//
//  AuthService.swift
//  what-to-eat-ios
//
//  Created by System on 18/8/25.
//

import Foundation
import AuthenticationServices
import GoogleSignIn

struct AppUser: Codable {
    let id: String
    let email: String?
    let name: String?
    let profileImageURL: String?
    let provider: String
}

class AuthService: ObservableObject {
    @Published var user: AppUser?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager = AuthenticationManager.shared
    
    init() {
        loadUser()
    }
    
    // MARK: - Persistence
    private func saveUser(_ user: AppUser) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "authenticated_user")
            DispatchQueue.main.async {
                self.user = user
                self.isAuthenticated = true
            }
        }
    }
    
    private func loadUser() {
        if let userData = UserDefaults.standard.data(forKey: "authenticated_user"),
           let user = try? JSONDecoder().decode(AppUser.self, from: userData) {
            DispatchQueue.main.async {
                self.user = user
                self.isAuthenticated = true
            }
        }
    }
    
    private func clearUser() {
        UserDefaults.standard.removeObject(forKey: "authenticated_user")
        DispatchQueue.main.async {
            self.user = nil
            self.isAuthenticated = false
        }
    }
    
    // MARK: - Apple Sign In
    func signInWithApple(result: Result<ASAuthorization, Error>) {
        isLoading = true
        errorMessage = nil
        
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                self.errorMessage = "Failed to get Apple ID credential"
                self.isLoading = false
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                self.errorMessage = "Failed to get identity token"
                self.isLoading = false
                return
            }
            print(idTokenString)
            // Send token to backend
            loginWithBackend(token: idTokenString) { [weak self] success, error in
                if success {
                    let userID = appleIDCredential.user
                    let email = appleIDCredential.email
                    let fullName = appleIDCredential.fullName
                    var displayName: String? = nil
                    if let fullName = fullName {
                        let nameComponents = [fullName.givenName, fullName.familyName].compactMap { $0 }
                        displayName = nameComponents.isEmpty ? nil : nameComponents.joined(separator: " ")
                    }
                    let appUser = AppUser(
                        id: userID,
                        email: email,
                        name: displayName,
                        profileImageURL: nil,
                        provider: "apple"
                    )
                    self?.saveUser(appUser)
                } else {
                    self?.errorMessage = error
                }
                self?.isLoading = false
            }
        case .failure(let error):
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let presentingViewController = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            self.errorMessage = "Failed to get presenting view controller"
            self.isLoading = false
            return
        }
        
        let manualNonce = UUID().uuidString
        
        GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController, hint: nil,
            additionalScopes: nil,
            nonce: manualNonce) { [weak self] result, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    guard let user = result?.user,
                          let idToken = user.idToken?.tokenString else {
                        self?.errorMessage = "Failed to get Google ID token"
                        return
                    }
                    
                    // Send token to backend
                    self?.loginWithBackend(token: idToken) { success, error in
                        if success {
                            let appUser = AppUser(
                                id: user.userID ?? UUID().uuidString,
                                email: user.profile?.email,
                                name: user.profile?.name,
                                profileImageURL: user.profile?.imageURL(withDimension: 200)?.absoluteString,
                                provider: "google"
                            )
                            self?.saveUser(appUser)
                        } else {
                            self?.errorMessage = error
                        }
                    }
                }
            }
    }
    
    // MARK: - Login with Backend
    func loginWithBackend(token: String, completion: @escaping (Bool, String?) -> Void) {
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(APIConstants.baseURL)/auth/login") else {
            self.isLoading = false
            completion(false, "Invalid backend URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["token": token]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    completion(false, error.localizedDescription)
                    return
                }
                guard let data = data else {
                    self?.errorMessage = "No data received"
                    completion(false, "No data received")
                    return
                }
                do {
                    let result = try JSONDecoder().decode(ResultToken.self, from: data)
                    // Use centralized token management
                    self?.authManager.saveTokens(accessToken: result.token, refreshToken: result.refreshToken)
                    self?.isAuthenticated = true
                    completion(true, nil)
                } catch {
                    self?.errorMessage = "Failed to parse token: \(error.localizedDescription)"
                    completion(false, self?.errorMessage)
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Sign Out
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        clearUser()
        // Use centralized token management
        authManager.clearTokens()
        DispatchQueue.main.async {
            self.errorMessage = nil
        }
    }
    
    // MARK: - Delete Account
    func deleteAccount() {
        isLoading = true
        errorMessage = nil
        // In a real app, call backend API to delete account
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            self.clearUser()
            // Use centralized token management
            self.authManager.clearTokens()
        }
    }
}
