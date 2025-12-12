//
//  SubscriptionService.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import Foundation
import StoreKit
import Combine

/// Subscription management service using StoreKit 2
@MainActor
class SubscriptionService: ObservableObject {
    
    static let shared = SubscriptionService()
    
    enum ProductID: String, CaseIterable {
        case fullAccess = "com.steadystride.fullaccess"
        case premiumMonthly = "com.steadystride.premium.monthly"
        case premiumYearly = "com.steadystride.premium.yearly"
        
        var tier: SubscriptionTier {
            switch self {
            case .fullAccess: return .unlocked
            case .premiumMonthly, .premiumYearly: return .premium
            }
        }
    }
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var currentSubscription: SubscriptionTier = .free
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    
    var hasFullAccess: Bool {
        purchasedProductIDs.contains(ProductID.fullAccess.rawValue)
    }
    
    var hasPremium: Bool {
        purchasedProductIDs.contains(ProductID.premiumMonthly.rawValue) ||
        purchasedProductIDs.contains(ProductID.premiumYearly.rawValue)
    }
    
    private init() {
        updateListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await updateCurrentEntitlements()
        }
    }
    
    func loadProducts() async {
        isLoading = true
        do {
            let productIDs = ProductID.allCases.map { $0.rawValue }
            products = try await Product.products(for: Set(productIDs))
            isLoading = false
        } catch {
            errorMessage = "Failed to load products"
            isLoading = false
        }
    }
    
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updateCurrentEntitlements()
            await transaction.finish()
            isLoading = false
            return true
        case .userCancelled, .pending:
            isLoading = false
            return false
        @unknown default:
            isLoading = false
            return false
        }
    }
    
    func restorePurchases() async throws {
        isLoading = true
        try await AppStore.sync()
        await updateCurrentEntitlements()
        isLoading = false
    }
    
    func updateCurrentEntitlements() async {
        var purchased: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result) {
                purchased.insert(transaction.productID)
            }
        }
        
        purchasedProductIDs = purchased
        currentSubscription = hasPremium ? .premium : (hasFullAccess ? .unlocked : .free)
    }
    
    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                if let transaction = try? self.checkVerified(result) {
                    await self.updateCurrentEntitlements()
                    await transaction.finish()
                }
            }
        }
    }
    
    private nonisolated func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified: throw SubscriptionError.verificationFailed
        case .verified(let safe): return safe
        }
    }
}

enum SubscriptionError: Error {
    case verificationFailed
}
