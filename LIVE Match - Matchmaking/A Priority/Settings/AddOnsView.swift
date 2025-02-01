//
//  AddOnsView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//


//
//  AddOnsView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Lists available add-ons (in-app purchases). For demonstration,
//  we have a subscription "Remove Ads" at $4.99/month. Includes
//  placeholders for "Subscribe" and "Restore Purchase" logic.
//

import SwiftUI
import StoreKit  // or a custom IAP manager if you prefer

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AddOnsView: View {
    
    // We'll list multiple add-ons if needed. Right now, just "Remove Ads"
    @State private var isPurchasing = false
    @State private var purchaseStatusMessage = ""
    
    public init() {}
    
    public var body: some View {
        List {
            Section(header: Text("Subscriptions")) {
                removeAdsRow
            }
            
            Section {
                Button("Restore Purchases") {
                    restorePurchases()
                }
            }
        }
        .navigationTitle("Add-Ons")
        .alert(isPresented: .constant(!purchaseStatusMessage.isEmpty)) {
            Alert(
                title: Text("Purchase Info"),
                message: Text(purchaseStatusMessage),
                dismissButton: .default(Text("OK"), action: {
                    purchaseStatusMessage = ""
                })
            )
        }
    }
    
    // MARK: "Remove Ads" row
    private var removeAdsRow: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Remove Ads (Monthly)")
                    .font(.headline)
                Text("$4.99 / month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isPurchasing {
                ProgressView()
            } else {
                Button("Subscribe") {
                    purchaseRemoveAds()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: Purchase Logic
    private func purchaseRemoveAds() {
        guard !isPurchasing else { return }
        isPurchasing = true
        purchaseStatusMessage = ""
        
        // Placeholder for real StoreKit-based subscription logic:
        // In real code, you'd find the product with ID "com.yourapp.removeads.monthly"
        // then call `StoreKit` or a custom `IAPManager`.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isPurchasing = false
            // Example success or fail
            let success = Bool.random()
            if success {
                purchaseStatusMessage = "Thank you! Remove Ads subscription is now active."
            } else {
                purchaseStatusMessage = "Purchase failed or was cancelled."
            }
        }
    }
    
    // MARK: Restore
    private func restorePurchases() {
        purchaseStatusMessage = ""
        // Placeholder for real restore logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Example random result
            let restored = Bool.random()
            if restored {
                purchaseStatusMessage = "Your subscriptions have been restored."
            } else {
                purchaseStatusMessage = "No previous subscription found."
            }
        }
    }
}