//
//  TemplateSubscriptionManager.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//


// MARK: - TemplateSubscriptionManager.swift
import SwiftUI
import StoreKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class TemplateSubscriptionManager: ObservableObject {
    // MARK: Properties
    @Published public var isSubscribed: Bool = false
    @Published public var errorMessage: String?
    
    private let subscriptionID = "com.Infinitum.imagery.llc.LIVEMatch.templates.monthly"
    
    // MARK: Init
    public init() {
        Task {
            await checkSubscriptionStatus()
        }
    }
    
    // MARK: Purchase Subscription
    @MainActor
    public func purchaseSubscription() async {
        do {
            let products = try await Product.products(for: [subscriptionID])
            guard let product = products.first else {
                errorMessage = "Subscription product not found."
                return
            }
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                if case .verified(_) = verification {
                    isSubscribed = true
                } else {
                    errorMessage = "Unverified transaction."
                }
            case .userCancelled:
                errorMessage = "Purchase cancelled."
            case .pending:
                errorMessage = "Purchase pending."
            @unknown default:
                errorMessage = "Purchase failed."
            }
        } catch {
            errorMessage = "Error purchasing subscription: \(error.localizedDescription)"
        }
    }
    
    // MARK: Restore Purchases
    @MainActor
    public func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkSubscriptionStatus()
        } catch {
            errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    // MARK: Check Subscription
    @MainActor
    public func checkSubscriptionStatus() async {
        for await verificationResult in StoreKit.Transaction.currentEntitlements {
            if case .verified(let storeTransaction) = verificationResult,
               storeTransaction.productID == subscriptionID {
                isSubscribed = true
                return
            }
        }
        isSubscribed = false
    }
}