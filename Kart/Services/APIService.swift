//
//  APIService.swift
//  Kart
//
//  Created by Yashi Gaur on 30/03/26.
//

import Foundation

/// Handles all backend API communication
class APIService {
    
    // MARK: - Configuration
    
    /// Backend URL - change this to your actual backend when deployed
    /// For local development with simulator, use localhost
    /// For testing on real iPhone, use your Mac's IP address
    private let baseURL: String = {
        #if targetEnvironment(simulator)
        return "http://localhost:8000"
        #else
        // TODO: Replace with your Mac's IP when testing on real device
        // Find it with: ifconfig | grep "inet " | grep -v 127.0.0.1
        return "http://192.168.1.XXX:8000"  // Replace XXX with your IP
        #endif
    }()
    
    // MARK: - Singleton
    
    /// Shared instance - use APIService.shared throughout the app
    static let shared = APIService()
    
    private init() {}
    
    // MARK: - API Methods
    
    /// Search for items by sending shopping list to backend
    /// - Parameter listText: Raw shopping list string (e.g., "potatoes, PS5, bean bag")
    /// - Returns: Array of parsed ShoppingItems
    /// - Throws: APIError if request fails
    func searchItems(listText: String) async throws -> [ShoppingItem] {
        
        // 1. Construct URL
        guard let url = URL(string: "\(baseURL)/api/search") else {
            throw APIError.invalidURL
        }
        
        // 2. Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Create request body
        let requestBody = ["list_text": listText]
        request.httpBody = try JSONEncoder().encode(requestBody)
        
        // 4. Make API call (async/await)
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // 5. Check HTTP status
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Try to decode error message from backend
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.detail)
            }
            throw APIError.httpError(httpResponse.statusCode)
        }
        
        // 6. Decode response
        let decoder = JSONDecoder()
        
        let searchResponse = try decoder.decode(SearchResponse.self, from: data)
        
        // 7. Convert backend items to ShoppingItems
        let items = searchResponse.items.map { $0.toShoppingItem() }
        
        return items
    }
}

// MARK: - Error Handling

enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "Server error: \(code)"
        case .serverError(let message):
            return message
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

/// Backend error response format
struct ErrorResponse: Codable {
    let detail: String
}
