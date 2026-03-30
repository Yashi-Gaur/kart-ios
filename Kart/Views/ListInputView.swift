//
//  ListInputView.swift
//  Kart
//
//  Created by Yashi Gaur on 30/03/26.
//

import SwiftUI

/// Main screen: User inputs shopping list and sees parsed results
struct ListInputView: View {
    
    // MARK: - State
    
    /// ViewModel manages all business logic and state
    @StateObject private var viewModel = SearchViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                
                // Input Section
                inputSection
                
                Divider()
                
                // Results Section
                if viewModel.isLoading {
                    loadingView
                } else if !viewModel.items.isEmpty {
                    resultsSection
                } else {
                    emptyStateView
                }
            }
            .navigationTitle("Kart")
            .navigationBarTitleDisplayMode(.large)
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Unknown error")
            }
        }
    }
    
    // MARK: - Input Section
    
    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("What do you need?")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Text input
            TextEditor(text: $viewModel.listText)
                .frame(minHeight: 100, maxHeight: 150)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            // Placeholder hint (shown when empty)
            if viewModel.listText.isEmpty {
                Text("e.g., \"2kg potatoes, PS5 controller, bean bag\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, -140)
                    .padding(.leading, 16)
                    .allowsHitTesting(false)  // Let taps pass through to TextEditor
            }
            
            // Action buttons
            HStack {
                Button(action: viewModel.clear) {
                    Label("Clear", systemImage: "xmark.circle.fill")
                        .font(.subheadline)
                }
                .buttonStyle(.bordered)
                .disabled(viewModel.listText.isEmpty)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await viewModel.search()
                    }
                }) {
                    Label("Search", systemImage: "magnifyingglass")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSearch)
            }
        }
        .padding()
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Parsing your list...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Results Section
    
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Header
            HStack {
                Text("Found \(viewModel.itemCount) items")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top)
            
            // List of items
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.items) { item in
                        ItemCard(item: item)
                    }
                }
                .padding()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "cart")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Enter your shopping list above")
                .font(.headline)
                .foregroundColor(.secondary)
            Text("We'll find the best places to buy each item")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Item Card Component

/// Individual card showing a parsed item
struct ItemCard: View {
    let item: ShoppingItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Top row: emoji + name + quantity
            // Top row: icon + name + quantity
            HStack {
                Image(systemName: item.categoryIcon)  // ← NEW
                    .font(.title2)
                    .foregroundColor(.blue)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.name)
                        .font(.headline)
                    
                    Text("\(item.quantity) \(item.unit ?? "pc")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Category badge
                Text(item.category.capitalized)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(6)
            }
            
            // Bottom row: platforms
            HStack(spacing: 4) {
                Image(systemName: "storefront")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(item.platformsDisplay)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
}

// MARK: - Preview

#Preview {
    ListInputView()
}
