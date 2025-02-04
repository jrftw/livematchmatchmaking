//
//  ChangePasswordView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChangePasswordView: View {
    
    @State public var currentPassword = ""
    @State public var newPassword = ""
    @State public var confirmPassword = ""
    @State public var errorMessage = ""
    @State public var successMessage = ""
    @Environment(\.presentationMode) public var presentationMode
    
    public init() {}

    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: - Current Password
                SecureField("Current Password", text: $currentPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // MARK: - New Password
                SecureField("New Password", text: $newPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // MARK: - Confirm Password
                SecureField("Confirm New Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                // MARK: - Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
                
                // MARK: - Success Message
                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .padding()
                }
                
                // MARK: - Update Password Button
                Button("Update Password") {
                    updatePassword()
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Close") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    // MARK: - Update Password Logic
    public func updatePassword() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not found."
            return
        }
        
        // Check if new passwords match
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match."
            return
        }
        
        // Firebase requires recent login to change password
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: currentPassword)
        user.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Re-authentication failed: \(error.localizedDescription)"
            } else {
                // Update password
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        errorMessage = "Error updating password: \(error.localizedDescription)"
                    } else {
                        successMessage = "Password successfully updated!"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
            }
        }
    }
}
