// MARK: - AddOnsView.swift
import SwiftUI
import StoreKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AddOnsView: View {
    @State private var isPurchasingRemoveAds = false
    @State private var isPurchasingTemplates = false
    @State private var isPurchasingScouter = false
    @State private var purchaseStatusMessage = ""
    
    public init() {}
    
    public var body: some View {
        List {
            Section(header: Text("Subscriptions")) {
                removeAdsRow
                templateSubscriptionRow
                scouterSubscriptionRow
            }
            
            Section {
                Button("Restore Purchases") {
                    Task {
                        let restored = await StoreKitHelper.shared.restorePurchases()
                        purchaseStatusMessage = restored
                        ? "Purchases restored successfully."
                        : "No previous subscription found or restore failed."
                    }
                }
            }
            
            Section(header: Text("What is each Add-On")) {
                Text("• Remove Ads – Completely remove ads throughout the app for an uninterrupted experience.")
                Text("• Templates – Unlock all match templates for creating and organizing tournaments easily.")
                Text("• Scouter – Discover and recruit Creators who are currently unaffiliated with agencies or networks. (Coming Soon)")
            }
        }
        .navigationTitle("Add-Ons")
        .alert(isPresented: .constant(!purchaseStatusMessage.isEmpty)) {
            Alert(
                title: Text("Purchase Info"),
                message: Text(purchaseStatusMessage),
                dismissButton: .default(Text("OK")) {
                    purchaseStatusMessage = ""
                }
            )
        }
        .task {
            await StoreKitHelper.shared.loadProducts()
        }
    }
    
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
            if isPurchasingRemoveAds {
                ProgressView()
            } else {
                Button("Subscribe") {
                    isPurchasingRemoveAds = true
                    StoreKitHelper.shared.purchaseRemoveAds { success in
                        isPurchasingRemoveAds = false
                        purchaseStatusMessage = success
                        ? "Remove Ads subscription active."
                        : "Purchase failed or was cancelled."
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var templateSubscriptionRow: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Templates (Monthly)")
                    .font(.headline)
                Text("$0.99 / month")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isPurchasingTemplates {
                ProgressView()
            } else {
                Button("Subscribe") {
                    isPurchasingTemplates = true
                    StoreKitHelper.shared.purchaseTemplateSubscription { success in
                        isPurchasingTemplates = false
                        purchaseStatusMessage = success
                        ? "Templates subscription active."
                        : "Purchase failed or was cancelled."
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    private var scouterSubscriptionRow: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Scouter (Weekly)")
                    .font(.headline)
                Text("$9.99 / week")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if isPurchasingScouter {
                ProgressView()
            } else {
                Button("Subscribe") {
                    isPurchasingScouter = true
                    StoreKitHelper.shared.purchaseScouterSubscription { success in
                        isPurchasingScouter = false
                        purchaseStatusMessage = success
                        ? "Scouter subscription active."
                        : "Purchase failed or was cancelled."
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }
}
