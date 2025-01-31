// MARK: VerificationManager.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI
import Firebase

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public class VerificationManager: ObservableObject {
    @Published public var verifiedUsers: Set<String> = []
    
    public init() {}
    
    public func loadPreVerified() {
        verifiedUsers = ["jrftw", "infinitum_US"]
    }
    
    public func isUserVerified(username: String) -> Bool {
        verifiedUsers.contains(username.lowercased())
    }
    
    public func requestVerification(for username: String, colorChoice: Color) {
        print("Verification requested for: \(username), color: \(colorChoice)")
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct VerificationView: View {
    @ObservedObject var vm = VerificationManager()
    @State private var desiredColor = Color.blue
    @State private var userToVerify = ""
    
    var body: some View {
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
