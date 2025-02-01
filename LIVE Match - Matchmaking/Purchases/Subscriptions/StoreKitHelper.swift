//
//  StoreKitHelper.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Example StoreKit 2 helper with "Remove Ads" product integration.
//

import Foundation
import StoreKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class StoreKitHelper: ObservableObject {
    
    // MARK: - Published States
    @Published var purchaseInProgress = false
    @Published var lastPurchaseSuccess = false
    
    // MARK: - Product IDs
    // Updated product ID for Remove Ads subscription
    private let removeAdsProductID = "com.Infinitum.imagery.llc.LIVEMatch.removeads.monthly"
    
    // Some example product IDs if you also want them
    private let teamPlanProductID = "com.example.LIVEMatch.team"
    private let agencyPlanProductID = "com.example.LIVEMatch.agency"
    private let scouterPlanProductID = "com.example.LIVEMatch.scouter"
    
    // MARK: - StoreKit 2 References
    // If using .storekit files, you could load products via `Product.products(for:)`
    private var removeAdsProduct: Product? = nil
    
    // MARK: - Singleton or init
    static let shared = StoreKitHelper()
    private init() {}
    
    // MARK: - Load Products (Placeholder)
    func loadProducts() async {
        do {
            let productIDs = [
                removeAdsProductID,
                teamPlanProductID,
                agencyPlanProductID,
                scouterPlanProductID
            ]
            let storeProducts = try await Product.products(for: productIDs)
            
            // Store references if needed
            for product in storeProducts {
                switch product.id {
                case removeAdsProductID:
                    removeAdsProduct = product
                default:
                    break
                }
            }
        } catch {
            print("Failed to load products: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Purchase Remove Ads
    func purchaseRemoveAds(completion: @escaping (Bool) -> Void) {
        purchaseInProgress = true
        lastPurchaseSuccess = false
        
        // If you already loaded products, we can purchase `removeAdsProduct`.
        // For demonstration, do a placeholder approach if the real product isn't loaded:
        
        if let product = removeAdsProduct {
            // Make a StoreKit 2 purchase
            Task {
                do {
                    let result = try await product.purchase()
                    // Evaluate result
                    switch result {
                    case .success(let verification):
                        let transaction = try checkVerified(verification)
                        finish(transaction: transaction)
                        purchaseInProgress = false
                        lastPurchaseSuccess = true
                        completion(true)
                        
                    case .userCancelled, .pending:
                        purchaseInProgress = false
                        completion(false)
                        
                    @unknown default:
                        purchaseInProgress = false
                        completion(false)
                    }
                } catch {
                    print("Purchase error: \(error.localizedDescription)")
                    purchaseInProgress = false
                    completion(false)
                }
            }
        } else {
            // Fallback or do a random success for placeholder
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let success = Bool.random()
                self.purchaseInProgress = false
                self.lastPurchaseSuccess = success
                completion(success)
            }
        }
    }
    
    // MARK: - Helper: Check Verified
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // StoreKit 2 verification approach
        switch result {
        case .unverified:
            throw StoreKitError.notVerified
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Finish transaction
    private func finish(transaction: Transaction) {
        // Optionally finish it if needed
        Task {
            await transaction.finish()
        }
        // Also, you'd set the user's profile hasRemoveAds = true
        // either locally or in Firestore, etc.
    }
}

// MARK: - Simple Error
enum StoreKitError: Error {
    case notVerified
}
