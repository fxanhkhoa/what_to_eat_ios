//
//  VotingGameCreateView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 19/8/25.
//

import SwiftUI
import Combine

struct VotingGameCreateView: View {
    @StateObject private var viewModel = VotingGameCreateViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var showingAddDishSheet = false
    @State private var showingCustomDishSheet = false
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header Section
                headerSection
                
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Vote Info Section
                        voteInfoSection
                        
                        // Selected Dishes Section
                        selectedDishesSection
                        
                        // Add Dishes Section
                        addDishesSection
                    }
                    .padding()
                }
                
                // Bottom Action Bar
                bottomActionBar
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("clear_all") {
                        showingClearAlert = true
                    }
                    .disabled(viewModel.selectedDishes.isEmpty)
                }
            }
            .alert("confirm_clear", isPresented: $showingClearAlert) {
                Button("cancel", role: .cancel) { }
                Button("clear", role: .destructive) {
                    viewModel.clearAllDishes()
                }
            }
            .sheet(isPresented: $showingAddDishSheet) {
                DishSearchAndSelectView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingCustomDishSheet) {
                CustomDishAddView(viewModel: viewModel)
            }
            .onChange(of: viewModel.showSuccess) {
                if viewModel.showSuccess {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "list.bullet.clipboard")
                    .font(.title2)
                    .foregroundColor(Color("PrimaryColor"))
                
                Text("create_vote")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text("add_dish_prompt")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("PrimaryColor").opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    // MARK: - Vote Info Section
    private var voteInfoSection: some View {
        VStack(spacing: 16) {
            // Vote Title Input
            VStack(alignment: .leading, spacing: 8) {
                Text("vote_title")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("enter_vote_title", text: $viewModel.voteTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Vote Description Input
            VStack(alignment: .leading, spacing: 8) {
                Text("vote_description")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("vote_description", text: $viewModel.voteDescription, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Selected Dishes Section
    private var selectedDishesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("selected_dishes")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.selectedDishes.count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color("PrimaryColor").opacity(0.2))
                    .foregroundColor(Color("PrimaryColor"))
                    .cornerRadius(8)
            }
            
            if viewModel.selectedDishes.isEmpty {
                emptyDishesView
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.selectedDishes.indices, id: \.self) { index in
                        let item = viewModel.selectedDishes[index]
                        SelectedDishRow(
                            item: item,
                            onRemove: {
                                viewModel.removeDish(at: index)
                            }
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                .shadow(radius: 2)
        )
    }
    
    // MARK: - Empty Dishes View
    private var emptyDishesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 40))
                .foregroundColor(.gray)
            
            Text("no_dishes_selected")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - Add Dishes Section
    private var addDishesSection: some View {
        VStack(spacing: 12) {
            Text("add_dishes")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                // Search and Add Button
                Button(action: {
                    showingAddDishSheet = true
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("search_and_add")
                            .multilineTextAlignment(.center)
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color("PrimaryColor"))
                    .cornerRadius(10)
                }
                
                // Add Custom Dish Button
                Button(action: {
                    showingCustomDishSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("add_custom_dish")
                            .multilineTextAlignment(.center)
                    }
                    .font(.subheadline)
                    .foregroundColor(Color("PrimaryColor"))
                    .padding()
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color("PrimaryColor").opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color("PrimaryColor"), lineWidth: 1)
                    )
                }
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
                    Text("\(viewModel.selectedDishes.count) dishes")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("minimum_dishes_required")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.createVote()
                }) {
                    HStack {
                        if viewModel.isCreating {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        
                        Text("create_voting_session")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(viewModel.canCreateVote ? Color("PrimaryColor") : Color.gray)
                    )
                }
                .disabled(!viewModel.canCreateVote || viewModel.isCreating)
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemBackground))
    }
}

// MARK: - Selected Dish Row
struct SelectedDishRow: View {
    let item: DishVoteItem
    let onRemove: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Dish Image/Icon
            AsyncImage(url: item.isCustom ? (item.customTitle != nil ? URL(string: item.customTitle!) : nil) : nil) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color("PrimaryColor").opacity(0.2))
                    .overlay(
                        Image(systemName: item.isCustom ? "person.crop.circle.badge.plus" : "fork.knife")
                            .foregroundColor(Color("PrimaryColor"))
                    )
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            // Dish Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.isCustom ? (item.customTitle ?? "custom_dish") : item.slug)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if item.isCustom {
                        Text("custom_dish")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    } else {
                        Text("from_database")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    }
                }
                
                if item.isCustom && item.customTitle != item.slug {
                    Text(item.slug)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Remove Button
            Button(action: onRemove) {
                Image(systemName: "minus.circle.fill")
                    .foregroundColor(.red)
                    .font(.title3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
        )
    }
}

#Preview {
    VotingGameCreateView()
}
