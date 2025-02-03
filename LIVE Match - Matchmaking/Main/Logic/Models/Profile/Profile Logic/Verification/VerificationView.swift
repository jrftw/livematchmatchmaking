//
//  VerificationView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/2/25.
//


// MARK: - VerificationView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct VerificationView: View {
    @ObservedObject var vm = VerificationManager()
    @State private var desiredColor = Color.blue
    @State private var userToVerify = ""
    
    public init() {}
    
    public var body: some View {
        VStack(spacing: 12) {
            Text("Request Verification")
                .font(.title2)
            TextField("Enter your username", text: $userToVerify)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            ColorPicker("Pick Verification Color", selection: $desiredColor)
                .padding()
            Button("Request Verification") {
                vm.requestVerification(for: userToVerify, colorChoice: desiredColor)
            }
            .padding()
            Spacer()
        }
        .onAppear {
            vm.loadPreVerified()
        }
        .navigationTitle("Verification")
    }
}