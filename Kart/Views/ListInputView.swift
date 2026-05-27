import SwiftUI

struct ListInputView: View {

    @StateObject private var viewModel = SearchViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {

                    inputSection

                    Divider()
                        .padding(.vertical, 16)

                    if viewModel.isLoading {
                        loadingView
                    } else if !viewModel.itemsWithProducts.isEmpty {
                        resultsContent
                    } else {
                        emptyStateView
                    }
                }
            }
            .navigationTitle("Kart")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out", role: .destructive) {
                        Task { await authViewModel.signOut() }
                    }
                }
            }
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
            
            TextEditor(text: $viewModel.listText)
                .frame(minHeight: 100, maxHeight: 150)
                .padding(12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            
            if viewModel.listText.isEmpty {
                Text("e.g., \"2kg potatoes, PS5 controller, bean bag\"")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, -140)
                    .padding(.leading, 16)
                    .allowsHitTesting(false)
            }
            
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
            Text("Searching for products...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
    
    // MARK: - Results Content
    
    private var resultsContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // Header
            HStack {
                Text("Found \(viewModel.totalProductCount) products for \(viewModel.itemCount) items")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            // Items with their products
            ForEach(viewModel.itemsWithProducts) { itemWithProducts in
                ItemSection(itemWithProducts: itemWithProducts)
            }
        }
        .padding(.vertical)
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
            Text("We'll find the best products with prices")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }
}

// MARK: - Item Section (Item + Products)

struct ItemSection: View {
    let itemWithProducts: ItemWithProducts
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // Item header
            HStack {
                Image(systemName: itemWithProducts.shoppingItem.categoryIcon)
                    .font(.title3)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(itemWithProducts.shoppingItem.name)
                        .font(.headline)
                    
                    Text("\(itemWithProducts.shoppingItem.quantity) \(itemWithProducts.shoppingItem.unit ?? "pc") • \(itemWithProducts.shoppingItem.category.capitalized)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(itemWithProducts.products.count) options")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .cornerRadius(6)
            }
            .padding(.horizontal)
            
            // Products horizontal scroll
            if !itemWithProducts.products.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(itemWithProducts.products) { product in
                            ProductCard(product: product)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                Text("No products found")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            // Product image
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 140, height: 140)
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 140, height: 140)
                        .clipped()
                case .failure:
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                        .frame(width: 140, height: 140)
                        .background(Color(.systemGray5))
                @unknown default:
                    EmptyView()
                }
            }
            .cornerRadius(8)
            
            // Product details
            VStack(alignment: .leading, spacing: 4) {
                Text(product.name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .frame(height: 32, alignment: .top)
                
                Text(product.formattedPrice)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    if product.rating > 0 {
                        Text(product.ratingDisplay)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("•")
                        .foregroundColor(.secondary)
                        .font(.caption2)
                    
                    Text(product.platform.capitalized)
                        .font(.caption2)
                        .foregroundColor(.blue)
                }
                
                Text(product.deliveryInfo)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(width: 140)
            
            // View button (placeholder - product URLs are empty for now)
            Button(action: {
                // TODO: Open product URL when available
                print("View product: \(product.name)")
            }) {
                Text("View")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(6)
            }
            .frame(width: 140)
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 2)
        .frame(width: 164) // 140 + padding
    }
}

#Preview {
    ListInputView()
        .environmentObject(AuthViewModel())
}
