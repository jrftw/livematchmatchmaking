//
//  EULAView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/5/25.
//

// MARK: - EULAView.swift
// Displays the EULA and requires acceptance before showing main content.

import SwiftUI

// MARK: - EULAViolationPolicy
public let eulaText = """
LIVE Match - Matchmaking Terms of Use - EULA

1. By using this app, you agree not to post objectionable or abusive content.
2. We have zero tolerance for harassment, hate speech, or explicit material.
3. Violations may result in immediate suspension or removal.

For more details, read our Terms & Conditions below.
"""

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct EULAView: View {
    @AppStorage("didAcceptEULA") private var didAcceptEULA = false
    
    public init() {}
    
    public var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Text("Welcome to LIVE Match!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(eulaText)
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                        
                        Link(destination: URL(string: "https://infinitumlive.com/live-match-matchmaking-app/")!) {
                            Text("Read Full Terms & Conditions")
                                .font(.body)
                                .underline()
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical, 10)
                
                Spacer()
                
                Button(action: {
                    didAcceptEULA = true
                }) {
                    Text("I Agree")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.8))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
}
