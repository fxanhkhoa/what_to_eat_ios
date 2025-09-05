//
//  VoteGameFilterView.swift
//  what_to_eat_ios
//
//  Created by Khoa Bui on 20/8/25.
//

import SwiftUI

struct VoteGameFilterView: View {
    @ObservedObject var viewModel: VoteGameListViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var selectedSortBy: String
    @State private var selectedSortOrder: String
    
    var localization = LocalizationService.shared
    
    init(viewModel: VoteGameListViewModel) {
        self.viewModel = viewModel
        self._selectedSortBy = State(initialValue: viewModel.sortBy)
        self._selectedSortOrder = State(initialValue: viewModel.sortOrder)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Filter Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Sort Section
                        sortSection
                        
                        // Quick Actions
                        quickActionsSection
                    }
                    .padding()
                }
                
                Spacer()
                
                // Bottom Action Bar
                bottomActionBar
            }
            .navigationTitle(localization.localizedString(for: "filter_vote_games"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(localization.localizedString(for: "cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.localizedString(for: "reset")) {
                        resetFilters()
                    }
                    .disabled(!viewModel.hasActiveFilters)
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "line.3.horizontal.decrease.circle")
                    .font(.title2)
                    .foregroundColor(Color("PrimaryColor"))
                
                Text(localization.localizedString(for: "filter_and_sort"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(localization.localizedString(for: "customize_vote_games_display"))
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
    
    // MARK: - Sort Section
    private var sortSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.localizedString(for: "sort_options"))
                .font(.headline)
                .foregroundColor(.primary)
            
            // Sort By
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for: "sort_by"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                VStack(spacing: 8) {
                    SortOptionRow(
                        title: localization.localizedString(for: "creation_date"),
                        subtitle: localization.localizedString(for: "sort_by_creation_date"),
                        value: "createdAt",
                        selectedValue: $selectedSortBy
                    )
                    
                    SortOptionRow(
                        title: localization.localizedString(for: "title"),
                        subtitle: localization.localizedString(for: "sort_by_title"),
                        value: "title",
                        selectedValue: $selectedSortBy
                    )
                    
                    SortOptionRow(
                        title: localization.localizedString(for: "vote_count"),
                        subtitle: localization.localizedString(for: "sort_by_vote_count"),
                        value: "voteCount",
                        selectedValue: $selectedSortBy
                    )
                    
                    SortOptionRow(
                        title: localization.localizedString(for: "dish_count"),
                        subtitle: localization.localizedString(for: "sort_by_dish_count"),
                        value: "dishCount",
                        selectedValue: $selectedSortBy
                    )
                }
            }
            
            // Sort Order
            VStack(alignment: .leading, spacing: 8) {
                Text(localization.localizedString(for: "sort_order"))
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 12) {
                    SortOrderButton(
                        title: localization.localizedString(for: "newest_first"),
                        icon: "arrow.down",
                        value: "desc",
                        selectedValue: $selectedSortOrder
                    )
                    
                    SortOrderButton(
                        title: localization.localizedString(for: "oldest_first"),
                        icon: "arrow.up",
                        value: "asc",
                        selectedValue: $selectedSortOrder
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
    
    // MARK: - Quick Actions Section
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(localization.localizedString(for: "quick_filters"))
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                QuickFilterButton(
                    title: localization.localizedString(for: "most_popular"),
                    subtitle: localization.localizedString(for: "sort_by_vote_count_desc"),
                    icon: "hand.raised.fill",
                    action: {
                        selectedSortBy = "voteCount"
                        selectedSortOrder = "desc"
                    }
                )
                
                QuickFilterButton(
                    title: localization.localizedString(for: "recently_created"),
                    subtitle: localization.localizedString(for: "show_newest_first"),
                    icon: "clock.fill",
                    action: {
                        selectedSortBy = "createdAt"
                        selectedSortOrder = "desc"
                    }
                )
                
                QuickFilterButton(
                    title: localization.localizedString(for: "most_dishes"),
                    subtitle: localization.localizedString(for: "votes_with_most_dishes"),
                    icon: "fork.knife",
                    action: {
                        selectedSortBy = "dishCount"
                        selectedSortOrder = "desc"
                    }
                )
                
                QuickFilterButton(
                    title: localization.localizedString(for: "alphabetical"),
                    subtitle: localization.localizedString(for: "sort_by_title_az"),
                    icon: "textformat.abc",
                    action: {
                        selectedSortBy = "title"
                        selectedSortOrder = "asc"
                    }
                )
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
                Button(action: {
                    resetFilters()
                }) {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text(localization.localizedString(for: "reset"))
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
                .disabled(!viewModel.hasActiveFilters)
                
                Spacer()
                
                Button(action: {
                    applyFilters()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text(localization.localizedString(for: "apply_filters"))
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color("PrimaryColor"))
                    )
                }
            }
            .padding()
        }
        .background(colorScheme == .dark ? Color(.systemBackground) : Color(.systemBackground))
    }
    
    // MARK: - Helper Methods
    
    private func resetFilters() {
        selectedSortBy = "createdAt"
        selectedSortOrder = "desc"
    }
    
    private func applyFilters() {
        viewModel.applySorting(sortBy: selectedSortBy, sortOrder: selectedSortOrder)
        dismiss()
    }
}

// MARK: - Sort Option Row
struct SortOptionRow: View {
    let title: String
    let subtitle: String
    let value: String
    @Binding var selectedValue: String
    
    var body: some View {
        Button(action: {
            selectedValue = value
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if selectedValue == value {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color("PrimaryColor"))
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.gray)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedValue == value ? Color("PrimaryColor").opacity(0.1) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(selectedValue == value ? Color("PrimaryColor") : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Sort Order Button
struct SortOrderButton: View {
    let title: String
    let icon: String
    let value: String
    @Binding var selectedValue: String
    
    var body: some View {
        Button(action: {
            selectedValue = value
        }) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(selectedValue == value ? .white : Color("PrimaryColor"))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(selectedValue == value ? Color("PrimaryColor") : Color("PrimaryColor").opacity(0.1))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Filter Button
struct QuickFilterButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color("PrimaryColor"))
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VoteGameFilterView(viewModel: VoteGameListViewModel())
}
