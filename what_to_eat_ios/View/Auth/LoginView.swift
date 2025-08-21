//
//  LoginView.swift
//  what-to-eat-ios
//
//  Created by System on 18/8/25.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var authViewModel: AuthViewModel
    
    let dismiss: () -> Void
    
    // Use the shared authService from authViewModel instead of creating a new one
    private var authService: AuthService {
        authViewModel.authService
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color("PrimaryColor").opacity(0.1),
                        Color("SecondaryBackground"),
                        Color("PrimaryColor").opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Logo and welcome section
                        logoSection
                            .frame(height: geometry.size.height * 0.4)
                        
                        // Login buttons section
                        loginButtonsSection
                            .frame(minHeight: geometry.size.height * 0.6)
                            .padding(.horizontal, 32)
                    }
                }
                
                // Loading overlay
                if authService.isLoading {
                    loadingOverlay
                }
            }
        }
        .alert("Error", isPresented: .constant(authService.errorMessage != nil)) {
            Button("OK") {
                authService.errorMessage = nil
            }
        } message: {
            if let errorMessage = authService.errorMessage {
                Text(errorMessage)
            }
        }
        .onChange(of: authService.isAuthenticated) {
            if authService.isAuthenticated {
                // No need to manually update authViewModel properties
                // They will be updated automatically via the Combine subscriptions
                dismiss()
            }
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // App logo
            Image("what-to-eat-high-resolution-logo-transparent") // You can replace with your app logo
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Welcome text
            VStack(spacing: 8) {
                LocalizedText("welcome_back")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color("PrimaryText"))
                
                LocalizedText("login_subtitle")
                    .font(.body)
                    .foregroundColor(Color("SecondaryText"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            
            Spacer()
        }
    }
    
    private var loginButtonsSection: some View {
        VStack(spacing: 20) {
            // Apple Sign In Button
            SignInWithAppleButton(
                onRequest: { request in
                    request.requestedScopes = [.fullName, .email]
                },
                onCompletion: { result in
                    authService.signInWithApple(result: result)
                }
            )
            .signInWithAppleButtonStyle(
                colorScheme == .dark ? .white : .black
            )
            .frame(height: 56)
            .cornerRadius(28)
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            
            // Google Sign In Button
            Button(action: {
                authService.signInWithGoogle()
            }) {
                HStack(spacing: 12) {
                    Image("google_logo") // Add Google logo to assets
                        .resizable()
                        .frame(width: 24, height: 24)
                    
                    LocalizedText("sign_in_with_google")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                )
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            }
            .disabled(authService.isLoading)
            
            // Terms and privacy
            VStack(spacing: 8) {
                LocalizedText("by_continuing_you_agree")
                    .font(.caption)
                    .foregroundColor(Color("SecondaryText"))
                
                HStack(spacing: 4) {
                    Button(action: {
                        // Handle terms of service
                    }) {
                        LocalizedText("terms_of_service")
                            .font(.caption)
                            .foregroundColor(Color("PrimaryColor"))
                            .underline()
                    }
                    
                    LocalizedText("and")
                        .font(.caption)
                        .foregroundColor(Color("SecondaryText"))
                    
                    Button(action: {
                        // Handle privacy policy
                    }) {
                        LocalizedText("privacy_policy")
                            .font(.caption)
                            .foregroundColor(Color("PrimaryColor"))
                            .underline()
                    }
                }
            }
            .padding(.top, 20)
            
            Spacer()
        }
    }
    
    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.2)
                
                LocalizedText("signing_in")
                    .font(.body)
                    .foregroundColor(.white)
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.black.opacity(0.7))
            )
        }
    }
}

#Preview {
    LoginView( dismiss: {})
}
