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
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//  Lists available add-ons (in-app purchases). For demonstration,
//  we have a subscription "Remove Ads" at $4.99/month. Includes
//  placeholders for "Subscribe" and "Restore Purchase" logic.
//

import SwiftUI
import StoreKit  // or a custom IAP manager if you prefer

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AddOnsView: View {
    // MARK: - State
    @State private var isPurchasing = false
    @State private var purchaseStatusMessage = ""
    
    // MARK: - Init
    public init() {
        print("[AddOnsView] init called.")
        print("[AddOnsView] Initial isPurchasing: \(isPurchasing), purchaseStatusMessage: '\(purchaseStatusMessage)'")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[AddOnsView] body invoked. Building List. isPurchasing: \(isPurchasing), purchaseStatusMessage: '\(purchaseStatusMessage)'")
        
        return List {
            Section(header: Text("Subscriptions")) {
                removeAdsRow
            }
            
            Section {
                Button("Restore Purchases") {
                    print("[AddOnsView] Restore Purchases button tapped.")
                    restorePurchases()
                }
            }
        }
        .navigationTitle("Add-Ons")
        .alert(isPresented: .constant(!purchaseStatusMessage.isEmpty)) {
            print("[AddOnsView] Alert presented with message: '\(purchaseStatusMessage)'")
            return Alert(
                title: Text("Purchase Info"),
                message: Text(purchaseStatusMessage),
                dismissButton: .default(Text("OK")) {
                    print("[AddOnsView] Alert dismissed. Clearing purchaseStatusMessage.")
                    purchaseStatusMessage = ""
                }
            )
        }
    }
    
    // MARK: - "Remove Ads" row
    private var removeAdsRow: some View {
        let _ = print("[AddOnsView] removeAdsRow computed. isPurchasing: \(isPurchasing)")
        
        return HStack {
            VStack(alignment: .leading) {
                Text("Remove Ads (Monthly)")
                    .font(.headline)
                Text("$4.99 / month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isPurchasing {
                let _ = print("[AddOnsView] isPurchasing == true, showing ProgressView.")
                ProgressView()
            } else {
                let _ = print("[AddOnsView] isPurchasing == false, showing Subscribe button.")
                Button("Subscribe") {
                    print("[AddOnsView] Subscribe button tapped.")
                    purchaseRemoveAds()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    // MARK: - Purchase Logic
    private func purchaseRemoveAds() {
        print("[AddOnsView] purchaseRemoveAds called.")
        guard !isPurchasing else {
            print("[AddOnsView] Already purchasing. Aborting.")
            return
        }
        
        isPurchasing = true
        purchaseStatusMessage = ""
        print("[AddOnsView] Initiating simulated purchase. isPurchasing set to true.")
        
        // Placeholder for real StoreKit-based subscription logic:
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isPurchasing = false
            print("[AddOnsView] Simulated purchase delay complete. isPurchasing set to false.")
            
            let success = Bool.random()
            if success {
                print("[AddOnsView] Simulated purchase success. Updating purchaseStatusMessage.")
                self.purchaseStatusMessage = "Thank you! Remove Ads subscription is now active."
            } else {
                print("[AddOnsView] Simulated purchase failure/cancellation. Updating purchaseStatusMessage.")
                self.purchaseStatusMessage = "Purchase failed or was cancelled."
            }
        }
    }
    
    // MARK: - Restore
    private func restorePurchases() {
        print("[AddOnsView] restorePurchases called. Clearing purchaseStatusMessage.")
        purchaseStatusMessage = ""
        
        // Placeholder for real restore logic
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let restored = Bool.random()
            if restored {
                print("[AddOnsView] Simulated restore success. Updating purchaseStatusMessage.")
                self.purchaseStatusMessage = "Your subscriptions have been restored."
            } else {
                print("[AddOnsView] Simulated restore failed. Updating purchaseStatusMessage.")
                self.purchaseStatusMessage = "No previous subscription found."
            }
        }
    }
}
