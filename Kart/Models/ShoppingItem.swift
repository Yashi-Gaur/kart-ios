import Foundation

/// Represents a single item from the parsed shopping list
struct ShoppingItem: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: String
    let quantity: Int
    let unit: String?
    let platforms: [String]
    
    var platformsDisplay: String {
        platforms
            .map { $0.capitalized.replacingOccurrences(of: "_", with: " ") }
            .joined(separator: ", ")
    }
    
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
    
    init(id: UUID = UUID(), name: String, category: String, quantity: Int, unit: String?, platforms: [String]) {
        self.id = id
        self.name = name
        self.category = category
        self.quantity = quantity
        self.unit = unit
        self.platforms = platforms
    }
}

/// Product from search results
struct Product: Identifiable, Codable {
    let id: UUID
    let name: String
    let price: Double
    let currency: String
    let imageUrl: String
    let productUrl: String
    let rating: Double
    let reviewsCount: Int
    let platform: String
    let seller: String
    let deliveryInfo: String
    let inStock: Bool
    let score: Double?
    
    enum CodingKeys: String, CodingKey {
        case name, price, currency, rating, platform, seller, score
        case imageUrl = "image_url"
        case productUrl = "product_url"
        case reviewsCount = "reviews_count"
        case deliveryInfo = "delivery_info"
        case inStock = "in_stock"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.name = try container.decode(String.self, forKey: .name)
        self.price = try container.decode(Double.self, forKey: .price)
        self.currency = try container.decode(String.self, forKey: .currency)
        self.imageUrl = try container.decode(String.self, forKey: .imageUrl)
        self.productUrl = try container.decode(String.self, forKey: .productUrl)
        self.rating = try container.decode(Double.self, forKey: .rating)
        self.reviewsCount = try container.decode(Int.self, forKey: .reviewsCount)
        self.platform = try container.decode(String.self, forKey: .platform)
        self.seller = try container.decode(String.self, forKey: .seller)
        self.deliveryInfo = try container.decode(String.self, forKey: .deliveryInfo)
        self.inStock = try container.decode(Bool.self, forKey: .inStock)
        self.score = try? container.decode(Double.self, forKey: .score)
    }
    
    /// Formatted price with currency symbol
    var formattedPrice: String {
        "₹\(Int(price))"
    }
    
    /// Star rating display (e.g., "4.5 ⭐")
    var ratingDisplay: String {
        if rating > 0 {
            return String(format: "%.1f ⭐", rating)
        }
        return "No ratings"
    }
}

/// Item with its product search results
struct ItemWithProducts: Identifiable, Codable {
    let id: UUID
    let item: BackendItem
    let products: [Product]
    
    enum CodingKeys: String, CodingKey {
        case item, products
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.item = try container.decode(BackendItem.self, forKey: .item)
        self.products = try container.decode([Product].self, forKey: .products)
    }
    
    /// Convert to ShoppingItem for backward compatibility
    var shoppingItem: ShoppingItem {
        item.toShoppingItem()
    }
}

/// Backend's item format
struct BackendItem: Codable {
    let name: String
    let category: String
    let quantity: Int
    let unit: String?
    let platforms: [String]
    
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

/// New response format with products
struct SearchResponseWithProducts: Codable {
    let items: [ItemWithProducts]
    let rawInput: String
    
    enum CodingKeys: String, CodingKey {
        case items
        case rawInput = "raw_input"
    }
}
