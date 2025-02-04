// MARK: - TemplatesView.swift
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct TemplatesView: View {
    // MARK: Properties
    @StateObject private var subscriptionManager = TemplateSubscriptionManager()
    
    // MARK: Init
    public init() {}
    
    // MARK: Body
    public var body: some View {
        VStack {
            if subscriptionManager.isSubscribed {
                Text("Templates")
                    .font(.largeTitle)
                    .padding()
                Spacer()
                Text("You have access to all template features.")
                Spacer()
            } else {
                Text("Template Subscription")
                    .font(.largeTitle)
                    .padding(.bottom, 10)
                Text("Subscribe for $0.99/month to access templates.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 20)
                
                if let errorMessage = subscriptionManager.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)
                }
                
                Button("Subscribe Now") {
                    Task {
                        await subscriptionManager.purchaseSubscription()
                    }
                }
                .font(.headline)
                .padding()
                
                Button("Restore Purchases") {
                    Task {
                        await subscriptionManager.restorePurchases()
                    }
                }
                .font(.subheadline)
                .padding()
                
                Spacer()
            }
        }
        .navigationTitle("Templates")
        .padding()
    }
}
