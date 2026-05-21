import Foundation
import Combine

/// ViewModel for the search/list input screen
class SearchViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var listText: String = ""
    @Published var itemsWithProducts: [ItemWithProducts] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Computed Properties
    
    var canSearch: Bool {
        !listText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading
    }
    
    var itemCount: Int {
        itemsWithProducts.count
    }
    
    var totalProductCount: Int {
        itemsWithProducts.reduce(0) { $0 + $1.products.count }
    }
    
    // MARK: - Dependencies
    
    private let apiService: APIService
    
    // MARK: - Initialization
    
    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }
    
    // MARK: - Actions
    
    @MainActor
    func search() async {
        let trimmedText = listText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        showError = false
        itemsWithProducts = []
        
        do {
            let results = try await apiService.searchItems(listText: trimmedText)
            itemsWithProducts = results
            
            print("✅ Found \(results.count) items with \(totalProductCount) total products")
            
        } catch {
            // Handle all errors generically
            errorMessage = error.localizedDescription
            showError = true
            print("❌ Error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    func clear() {
        listText = ""
        itemsWithProducts = []
        errorMessage = nil
        showError = false
    }
}
