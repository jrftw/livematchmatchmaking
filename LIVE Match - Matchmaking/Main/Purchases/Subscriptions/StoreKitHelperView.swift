// MARK: File: StoreKitHelperView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// View that displays subscription requirement for certain account types.

import SwiftUI

public struct StoreKitHelperView: View {
    public let accountTypes: [AccountType]
    public let onSubscribed: () -> Void
    
    public init(accountTypes: [AccountType], onSubscribed: @escaping () -> Void) {
        self.accountTypes = accountTypes
        self.onSubscribed = onSubscribed
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Subscription Required")
                .font(.title)
            
            Text("Paid Types: \(paidTypesString)")
                .font(.subheadline)
            
            Button("Subscribe & Continue") {
                onSubscribed()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(24)
    }
    
    private var paidTypesString: String {
        let paid = accountTypes.filter {
            $0 == .team || $0 == .agency || $0 == .scouter
        }
        if paid.isEmpty { return "None" }
        return paid.map { $0.rawValue.capitalized }.joined(separator: ", ")
    }
}
