//
//  CustomDishAddView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 19/8/25.
//

import SwiftUI

struct CustomDishAddView: View {
    @ObservedObject var viewModel: VotingGameCreateViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var dishTitle: String = ""
    @State private var dishURL: String = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    let localization = LocalizationService.shared
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Form Section
                ScrollView {
                    VStack(spacing: 20) {
                        formSection
                        previewSection
                    }
                    .padding()
                }
                
                Spacer()
                
                // Bottom Action Bar
                bottomActionBar
            }
            .navigationTitle(localization.localizedString(for: "add_custom_dish"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localizedString(for: "cancel")) {
                        dismiss()
                    }
                }
            }
            .alert(localization.localizedString(for: "Error"), isPresented: $showingAlert) {
                Button(localization.localizedString(for: "ok")) { }
            } message: {
                Text(localization.localizedString(for: alertMessage))
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "plus.circle")
                    .font(.title2)
                    .foregroundColor(Color("PrimaryColor"))
                
                Text(localization.localizedString(for: "add_custom_dish"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(localization.localizedString(for: "custom_dish_header_desc"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 16) {
            // Dish Title Input
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(localization.localizedString(for: "custom_dish_title"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("*")
                        .font(.headline)
                        .foregroundColor(.red)
                }
                
                TextField(localization.localizedString(for: "custom_dish_title_placeholder"), text: $dishTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .autocapitalization(.words)
            }
            
            // Dish URL Input
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for: "custom_dish_url"))
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField(localization.localizedString(for: "custom_dish_url_placeholder"), text: $dishURL)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
            }
            
            // Helper Text
            Text(localization.localizedString(for: "custom_dish_url_helper"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(localization.localizedString(for: "Preview"))
                .font(.headline)
                .foregroundColor(.primary)
            
            if !dishTitle.isEmpty {
                // Preview of how the dish will look
                HStack(spacing: 12) {
                    // Preview Image
                    AsyncImage(url: dishURL.isEmpty ? nil : URL(string: dishURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.orange.opacity(0.2))
                            .overlay(
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .foregroundColor(.orange)
                            )
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    // Preview Info
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(dishTitle)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text(localization.localizedString(for: "custom_dish"))
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                        
                        if !dishURL.isEmpty {
                            Text(dishURL)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
                )
            } else {
                Text(localization.localizedString(for: "custom_dish_preview_placeholder"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .italic()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Bottom Action Bar
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localization.localizedString(for: "custom_dish"))
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(localization.localizedString(for: "custom_dish_bottom_desc"))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    addCustomDish()
                }) {
                    HStack {
                        Image(systemName: "plus")
                        Text(localization.localizedString(for: "add_custom_dish"))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(canAddDish ? Color.orange : Color.gray)
                    )
                }
                .disabled(!canAddDish)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemBackground))
    }
    
    // MARK: - Computed Properties
    
    private var canAddDish: Bool {
        !dishTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Methods
    
    private func addCustomDish() {
        let trimmedTitle = dishTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedURL = dishURL.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedTitle.isEmpty else {
            alertMessage = "custom_dish_alert_empty_title"
            showingAlert = true
            return
        }
        
        // Check if custom dish with same title already exists
        if viewModel.selectedDishes.contains(where: { $0.isCustom && $0.customTitle == trimmedTitle }) {
            alertMessage = "custom_dish_alert_duplicate_title"
            showingAlert = true
            return
        }
        
        // Validate URL if provided
        if !trimmedURL.isEmpty {
            if !isValidURL(trimmedURL) {
                alertMessage = "custom_dish_alert_invalid_url"
                showingAlert = true
                return
            }
        }
        
        // Add the custom dish
        viewModel.addCustomDish(
            title: trimmedTitle,
            url: trimmedURL.isEmpty ? nil : trimmedURL
        )
        
        // Close the sheet
        dismiss()
    }
    
    private func isValidURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        return url.scheme != nil && url.host != nil
    }
}

#Preview {
    CustomDishAddView(viewModel: VotingGameCreateViewModel())
}
