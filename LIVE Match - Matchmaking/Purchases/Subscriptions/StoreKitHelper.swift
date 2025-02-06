// MARK: - StoreKitHelper.swift
import Foundation
import StoreKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class StoreKitHelper: ObservableObject {
    
    // MARK: - Published States
    @Published var purchaseInProgress = false
    @Published var lastPurchaseSuccess = false
    
    // MARK: - Product IDs
    private let removeAdsProductID = "com.Infinitum.imagery.llc.LIVEMatch.removeads.monthly"
    private let templateSubscriptionProductID = "com.Infinitum.imagery.llc.LIVEMatch.templates.monthly"
    private let teamPlanProductID = "com.example.LIVEMatch.team"
    private let agencyPlanProductID = "com.example.LIVEMatch.agency"
    private let scouterPlanProductID = "com.example.LIVEMatch.scouter"
    
    // MARK: - StoreKit 2 References
    private var removeAdsProduct: Product?
    private var templateSubscriptionProduct: Product?
    private var scouterSubscriptionProduct: Product?
    
    // MARK: - Singleton
    static let shared = StoreKitHelper()
    private init() {
        Task {
            await listenForTransactions()
        }
    }
    
    // MARK: - Listen for Transaction Updates
    @MainActor
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            do {
                let transaction = try checkVerified(result)
                await transaction.finish()
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
    }
    
    // MARK: - Load Products
    func loadProducts() async {
        do {
            let productIDs = [
                removeAdsProductID,
                templateSubscriptionProductID,
                teamPlanProductID,
                agencyPlanProductID,
                scouterPlanProductID
            ]
            let storeProducts = try await Product.products(for: productIDs)
            
            for product in storeProducts {
                switch product.id {
                case removeAdsProductID:
                    removeAdsProduct = product
                case templateSubscriptionProductID:
                    templateSubscriptionProduct = product
                case scouterPlanProductID:
                    scouterSubscriptionProduct = product
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
        
        guard let product = removeAdsProduct else {
            print("Remove Ads product not loaded. Cannot proceed with purchase.")
            purchaseInProgress = false
            completion(false)
            return
        }
        
        Task {
            do {
                let result = try await product.purchase()
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
    }
    
    // MARK: - Purchase Template Subscription
    func purchaseTemplateSubscription(completion: @escaping (Bool) -> Void) {
        purchaseInProgress = true
        lastPurchaseSuccess = false
        
        guard let product = templateSubscriptionProduct else {
            print("Template subscription product not loaded. Cannot proceed with purchase.")
            purchaseInProgress = false
            completion(false)
            return
        }
        
        Task {
            do {
                let result = try await product.purchase()
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
    }
    
    // MARK: - Purchase Scouter Subscription
    func purchaseScouterSubscription(completion: @escaping (Bool) -> Void) {
        purchaseInProgress = true
        lastPurchaseSuccess = false
        
        guard let product = scouterSubscriptionProduct else {
            print("Scouter product not loaded. Cannot proceed with purchase.")
            purchaseInProgress = false
            completion(false)
            return
        }
        
        Task {
            do {
                let result = try await product.purchase()
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
    }
    
    // MARK: - Restore Purchases
    @MainActor
    func restorePurchases() async -> Bool {
        do {
            _ = try await AppStore.sync()
            
            var foundSubscription = false
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == removeAdsProductID ||
                       transaction.productID == templateSubscriptionProductID ||
                       transaction.productID == scouterPlanProductID {
                        foundSubscription = true
                    }
                }
            }
            return foundSubscription
        } catch {
            print("Failed to restore purchases: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Helper: Check Verified
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.notVerified
        case .verified(let transaction):
            return transaction
        }
    }
    
    // MARK: - Finish transaction
    private func finish(transaction: Transaction) {
        Task { await transaction.finish() }
    }
}

// MARK: - Simple Error
enum StoreKitError: Error {
    case notVerified
}
