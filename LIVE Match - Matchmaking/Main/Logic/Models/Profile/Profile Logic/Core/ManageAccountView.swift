//
//  ManageAccountView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/4/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ManageAccountView: View {
    
    @State private var showingDeleteAlert = false
    @State private var deletionErrorAlert = false
    @State private var errorMessage = ""
    @State private var showingEmailSheet = false
    @State private var showingPasswordSheet = false
    @State private var showingPrivacySheet = false
    @State private var showingLinkedAccountsSheet = false
    @State private var showingTwoFASheet = false
    
    // MARK: Body
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                // MARK: Update Email
                Button("Update Email") {
                    showingEmailSheet = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.orange.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showingEmailSheet) {
                    UpdateEmailView()
                }
                
                // MARK: Change Password
                Button("Change Password") {
                    showingPasswordSheet = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.purple.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showingPasswordSheet) {
                    ChangePasswordView()
                }
                
                // MARK: Linked Accounts
                Button("Manage Linked Accounts") {
                    showingLinkedAccountsSheet = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showingLinkedAccountsSheet) {
                    LinkedAccountsView()
                }
                
                // MARK: Two-Factor Authentication (2FA)
                Button("Enable Two-Factor Authentication") {
                    showingTwoFASheet = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showingTwoFASheet) {
                    TwoFactorAuthView()
                }
                
                // MARK: Privacy Settings
                Button("Privacy Settings") {
                    showingPrivacySheet = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .sheet(isPresented: $showingPrivacySheet) {
                    PrivacySettingsView()
                }
                
                // MARK: Sign Out
                Button("Sign Out") {
                    signOut()
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                // MARK: Delete Account
                Button("Delete Account") {
                    showingDeleteAlert = true
                }
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text("Confirm Delete"),
                        message: Text("Are you sure you want to permanently delete your account? This action cannot be undone."),
                        primaryButton: .destructive(Text("Delete")) {
                            deleteAccount()
                        },
                        secondaryButton: .cancel()
                    )
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Manage Account")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(isPresented: $deletionErrorAlert) {
            Alert(
                title: Text("Error"),
                message: Text(errorMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: Sign Out
    private func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            self.errorMessage = error.localizedDescription
            self.deletionErrorAlert = true
        }
    }
    
    // MARK: Delete Account
    private func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        user.delete { error in
            if let error = error {
                self.errorMessage = error.localizedDescription
                self.deletionErrorAlert = true
            }
        }
    }
}

// MARK: - Update Email View
struct UpdateEmailView: View {
    @State private var newEmail = ""
    
    var body: some View {
        VStack {
            Text("Update Email")
                .font(.title2)
                .fontWeight(.bold)
            
            TextField("New Email", text: $newEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Update") {
                updateEmail()
            }
            .font(.headline)
            .padding()
            .background(Color.orange.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    private func updateEmail() {
        guard let user = Auth.auth().currentUser else { return }
        user.sendEmailVerification(beforeUpdatingEmail: newEmail) { error in
            if let error = error {
                print("Error updating email: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Manage Linked Accounts View
struct LinkedAccountsView: View {
    var body: some View {
        VStack {
            Text("Manage Linked Accounts")
                .font(.title2)
                .fontWeight(.bold)
            Text("Connect or disconnect accounts like Google, Facebook, or Apple ID.")
                .padding()
            
            Button("Link Google Account") {
                linkGoogleAccount()
            }
            .font(.headline)
            .padding()
            .background(Color.green.opacity(0.8))
            .foregroundColor(.white)
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
    }
    
    private func linkGoogleAccount() {
        // Firebase linking logic for Google
    }
}

// MARK: - Two-Factor Authentication View
struct TwoFactorAuthView: View {
    @State private var isEnabled = false
    
    var body: some View {
        VStack {
            Text("Two-Factor Authentication")
                .font(.title2)
                .fontWeight(.bold)
            Toggle("Enable 2FA", isOn: $isEnabled)
                .padding()
            
            if isEnabled {
                Button("Send Verification Code") {
                    sendTwoFactorCode()
                }
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
    }
    
    private func sendTwoFactorCode() {
        // Logic for sending OTP verification code
    }
}

// MARK: - Privacy Settings View
struct PrivacySettingsView: View {
    @State private var isPublicProfile = false
    @State private var showEmail = false
    
    var body: some View {
        VStack {
            Text("Privacy Settings")
                .font(.title2)
                .fontWeight(.bold)
            
            Toggle("Public Profile", isOn: $isPublicProfile)
                .padding()
            
            Toggle("Show Email", isOn: $showEmail)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}
