//
//  ShoppingItem.swift
//  Kart
//
//  Created by Yashi Gaur on 30/03/26.
//

import Foundation

/// Represents a single item from the parsed shopping list
/// This matches the backend's ParsedItem model
struct ShoppingItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: String
    let quantity: Int
    let unit: String?
    let platforms: [String]
    
    /// Computed property: returns platforms as comma-separated string
    /// e.g., ["blinkit", "zepto"] → "Blinkit, Zepto"
    var platformsDisplay: String {
        platforms
            .map { $0.capitalized.replacingOccurrences(of: "_", with: " ") }
            .joined(separator: ", ")
    }
    
    /// Category emoji for visual display
    /// Category icon (SF Symbol name) for visual display
    var categoryIcon: String {
        switch category.lowercased() {
        case "grocery":
            return "cart.fill"
        case "electronics":
            return "laptopcomputer"
        case "furniture":
            return "chair.fill"
        case "fashion":
            return "tshirt.fill"
        default:
            return "shippingbox.fill"
        }
    }
    
    /// Initialize with ID auto-generated
    init(id: UUID = UUID(), name: String, category: String, quantity: Int, unit: String?, platforms: [String]) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.platforms = platforms
    }
}

/// Response from backend /api/search endpoint
struct SearchResponse: Codable {
    let items: [BackendItem]
    let rawInput: String
    
    enum CodingKeys: String, CodingKey {
        case items
        case rawInput = "raw_input"
    }
}

/// Backend's item format (before we convert to ShoppingItem)
struct BackendItem: Codable {
    let name: String
    let category: String
    let quantity: Int
    let unit: String?
    let platforms: [String]
    
    /// Convert backend item to our app's ShoppingItem
    func toShoppingItem() -> ShoppingItem {
        ShoppingItem(
            name: name,
            category: category,
            quantity: quantity,
            unit: unit,
            platforms: platforms
        )
    }
}
