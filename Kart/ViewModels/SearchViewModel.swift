//
//  SearchViewModel.swift
//  Kart
//
//  Created by Yashi Gaur on 30/03/26.
//

import Foundation
import Combine

/// ViewModel for the search/list input screen
/// Follows MVVM pattern: View observes this, ViewModel talks to Services
class SearchViewModel: ObservableObject {
    
    // MARK: - Published Properties (UI observes these)
    
    /// User's input text
    @Published var listText: String = ""
    
    /// Parsed shopping items from backend
    @Published var items: [ShoppingItem] = []
    
    /// Loading state
    @Published var isLoading: Bool = false
    
    /// Error message (if any)
    @Published var errorMessage: String?
    
    /// Whether to show error alert
    @Published var showError: Bool = false
    
    // MARK: - Computed Properties
    
    /// Whether the search button should be enabled
    var canSearch: Bool {
        !listText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    /// Count of items found
    var itemCount: Int {
        items.count
    }
    
    // MARK: - Dependencies
    
    private let apiService: APIService
    
    // MARK: - Initialization
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    /// Search for items by sending list to backend
    @MainActor  // ← Moved @MainActor here instead of class level
    func search() async {
        // Validate input
        let trimmedText = listText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Reset state
        isLoading = true
        errorMessage = nil
        showError = false
        items = []
        
        do {
            // Call backend API
            let foundItems = try await apiService.searchItems(listText: trimmedText)
            
            // Update UI
            items = foundItems
            
            print("✅ Found \(foundItems.count) items")
            
        } catch let error as APIError {
            // Handle API errors
            errorMessage = error.errorDescription
            showError = true
            print("❌ API Error: \(error.errorDescription ?? "Unknown")")
            
        } catch {
            // Handle unexpected errors
            errorMessage = "Something went wrong. Please try again."
            showError = true
            print("❌ Unexpected error: \(error)")
        }
        
        isLoading = false
    }
    
    /// Clear all data (reset)
    func clear() {
        listText = ""
        items = []
        errorMessage = nil
        showError = false
    }
}
