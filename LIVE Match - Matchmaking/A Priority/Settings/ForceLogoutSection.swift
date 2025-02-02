//
//  ForceLogoutSection.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - ForceLogoutSection.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A simple section with a "Force Logout" button that signs out the user
// and navigates them back to sign-in or sign-up.
// Integrated in AppSettingsView above the footer.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ForceLogoutSection: View {
    // MARK: - State
    @State private var showingConfirm = false
    
    // MARK: - Init
    public init() {
        print("[ForceLogoutSection] init called.")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[ForceLogoutSection] body invoked. Building Section with a Logout button.")
        
        Section("Force Logout") {
            Button("Logout Now") {
                print("[ForceLogoutSection] Logout button tapped. showingConfirm set to true.")
                showingConfirm = true
            }
        }
        .alert(isPresented: $showingConfirm) {
            print("[ForceLogoutSection] Alert for logout confirmation triggered.")
            return Alert(
                title: Text("Confirm Logout"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    print("[ForceLogoutSection] User confirmed logout. Calling forceLogout().")
                    forceLogout()
                },
                secondaryButton: .cancel({
                    print("[ForceLogoutSection] User canceled logout.")
                })
            )
        }
    }
    
    // MARK: - Force Logout
    private func forceLogout() {
        print("[ForceLogoutSection] forceLogout called. Attempting sign out.")
        AuthManager.shared.signOut()
        print("[ForceLogoutSection] AuthManager.signOut completed.")
        
        #if canImport(UIKit)
        print("[ForceLogoutSection] Running iOS-specific UI reset after logout.")
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.forEach { window in
                print("[ForceLogoutSection] Replacing rootViewController with SignInView.")
                window.rootViewController = UIHostingController(rootView: SignInView())
                window.makeKeyAndVisible()
            }
        }
        #else
        print("[ForceLogoutSection] No UI reset performed for macOS or visionOS.")
        #endif
    }
}
