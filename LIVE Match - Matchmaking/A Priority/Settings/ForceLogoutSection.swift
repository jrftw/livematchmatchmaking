// MARK: - ForceLogoutSection.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ForceLogoutSection: View {
    @Binding var selectedScreen: MainScreen
    @State private var showingConfirm = false
    
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
        print("[ForceLogoutSection] init called.")
    }
    
    public var body: some View {
        Section("Force Logout") {
            Button("Logout Now") {
                showingConfirm = true
            }
        }
        .alert(isPresented: $showingConfirm) {
            Alert(
                title: Text("Confirm Logout"),
                message: Text("Are you sure you want to log out?"),
                primaryButton: .destructive(Text("Log Out")) {
                    forceLogout()
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    private func forceLogout() {
        AuthManager.shared.signOut()
        
        #if canImport(UIKit)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            scene.windows.forEach { window in
                // Re-init SignInView with binding
                let signInRoot = SignInView(selectedScreen: $selectedScreen)
                window.rootViewController = UIHostingController(rootView: signInRoot)
                window.makeKeyAndVisible()
            }
        }
        #endif
    }
}
