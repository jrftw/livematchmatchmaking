// MARK: BottomBarView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A bottom tab for menu, feed, messages, profile. If guest, restrict feed/messages/profile.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MainScreen {
    case menu
    case feed
    case messages
    case profile
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct BottomBarView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @Binding var selectedScreen: MainScreen
    
    @State private var showingGuestAlert = false
    
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
    public var body: some View {
        let isLoggedIn = (authManager.user != nil)
        let isGuest = authManager.isGuest
        let fullyLoggedIn = (isLoggedIn && !isGuest)
        
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemBackground).opacity(0.95))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: -2)
            
            HStack(spacing: 40) {
                Button {
                    selectedScreen = .menu
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "house.fill")
                        Text("Menu").font(.footnote)
                    }
                }
                
                Button {
                    if fullyLoggedIn {
                        selectedScreen = .feed
                    } else {
                        showingGuestAlert = true
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Feed").font(.footnote)
                    }
                }
                
                Button {
                    if fullyLoggedIn {
                        selectedScreen = .messages
                    } else {
                        showingGuestAlert = true
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "message.fill")
                        Text("Messages").font(.footnote)
                    }
                }
                
                Button {
                    if fullyLoggedIn {
                        selectedScreen = .profile
                    } else {
                        showingGuestAlert = true
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "person.crop.circle")
                        Text("Profile").font(.footnote)
                    }
                }
            }
            .padding(.horizontal, 10)
        }
        .frame(height: 60)
        .alert(isPresented: $showingGuestAlert) {
            Alert(
                title: Text("Account Required"),
                message: Text("Log In or Create an account to view this content."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
}
