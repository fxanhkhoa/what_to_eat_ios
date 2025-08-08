//
//  HomeContactSection.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 8/8/25.
//

import SwiftUI
import Combine

// Class to store cancellables since struct properties can't be mutated
private class CancellableStore {
    var cancellables = Set<AnyCancellable>()
}

struct HomeContactSection: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var message: String = ""
    @State private var isSending: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false
    @Environment(\.colorScheme) var colorScheme
    
    private let contactService = ContactService.shared
    private let cancellableStore = CancellableStore()
    private let contactEmail = "fxanhkhoa@gmail.com"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Section Title
            Text(LocalizationService.shared.localizedString(for: "contact_us"))
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            // Contact Form
            VStack(spacing: 16) {
                // Name Field
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationService.shared.localizedString(for: "name"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("", text: $name)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                        .autocapitalization(.words)
                }
                
                // Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationService.shared.localizedString(for: "email"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextField("", text: $email)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                // Message Field
                VStack(alignment: .leading, spacing: 8) {
                    Text(LocalizationService.shared.localizedString(for: "message"))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    TextEditor(text: $message)
                        .frame(minHeight: 120)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 1)
                        )
                }
                
                // Send Button
                Button(action: {
                    sendMessage()
                }) {
                    HStack {
                        Spacer()
                        if isSending {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text(LocalizationService.shared.localizedString(for: "send_message"))
                                .fontWeight(.semibold)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(hex: "#F3A446"))
                    )
                    .foregroundColor(.white)
                }
                .disabled(isSending)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color(UIColor.systemGray5) : Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            
            // Contact Info
            VStack(alignment: .leading, spacing: 12) {
                Text(LocalizationService.shared.localizedString(for: "or_contact_directly"))
                    .font(.headline)
                
                HStack {
                    Image(systemName: "envelope.fill")
                        .foregroundColor(Color(hex: "#F3A446"))
                    
                    Text(contactEmail)
                        .font(.subheadline)
                        .foregroundColor(.primary)
                        .onTapGesture {
                            openURL("mailto:\(contactEmail)")
                        }
                }
                .padding(.bottom, 8)
                
                Text(LocalizationService.shared.localizedString(for: "follow_us"))
                    .font(.headline)
                
                HStack(spacing: 16) {
                    // Facebook Button
                    Button(action: {
                        openURL("https://facebook.com/whattoeatapp")
                    }) {
                        socialButton(icon: "f.cursive", text: "Facebook")
                    }
                    
                    // TikTok Button
                    Button(action: {
                        openURL("https://tiktok.com/@whattoeatapp")
                    }) {
                        socialButton(icon: "tiktok", text: "TikTok")
                    }
                    
                    // Website Button
                    Button(action: {
                        openURL("https://whattoeat.app")
                    }) {
                        socialButton(icon: "globe", text: "Website")
                    }
                }
            }
            .padding()
            .padding(.bottom, 40)
            .padding(.horizontal)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Social media button view
    private func socialButton(icon: String, text: String) -> some View {
        VStack {
            Image(systemName: icon == "tiktok" ? "music.note" : icon)
                .font(.system(size: 20))
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(colorScheme == .dark ? Color(UIColor.systemGray6) : Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            
            Text(text)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // Function to send message
    private func sendMessage() {
        // Basic validation
        guard !name.isEmpty else {
            alertMessage = LocalizationService.shared.localizedString(for: "name_required")
            showAlert = true
            isSuccess = false
            return
        }
        
        guard !email.isEmpty, isValidEmail(email) else {
            alertMessage = LocalizationService.shared.localizedString(for: "valid_email_required")
            showAlert = true
            isSuccess = false
            return
        }
        
        guard !message.isEmpty else {
            alertMessage = LocalizationService.shared.localizedString(for: "message_required")
            showAlert = true
            isSuccess = false
            return
        }
        
        isSending = true
        
        let contactDto = CreateContactDto(email: email, name: name, message: message)
        
        ContactService.shared.create(dto: contactDto)
            .sink(receiveCompletion: { completion in
                isSending = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    isSuccess = false
                    alertMessage = error.localizedDescription
                    showAlert = true
                }
            }, receiveValue: { _ in
                isSuccess = true
                alertMessage = LocalizationService.shared.localizedString(for: "message_sent_success")
                showAlert = true
                
                // Clear form
                name = ""
                email = ""
                message = ""
            })
            .store(in: &cancellableStore.cancellables)
    }
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Function to open URLs
    private func openURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIApplication.shared.open(url)
    }
    
    // Alert title based on success/failure
    private var alertTitle: String {
        return LocalizationService.shared.localizedString(for: isSuccess ? "success" : "error")
    }
}

#Preview {
    HomeContactSection()
}
