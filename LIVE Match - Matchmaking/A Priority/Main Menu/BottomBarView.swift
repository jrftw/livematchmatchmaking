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
    // MARK: - Observed Objects
    @ObservedObject private var authManager = AuthManager.shared
    
    // MARK: - Binding
    @Binding var selectedScreen: MainScreen
    
    // MARK: - State
    @State private var showingGuestAlert = false
    
    // MARK: - Init
    public init(selectedScreen: Binding<MainScreen>) {
        print("[BottomBarView] init called.")
        self._selectedScreen = selectedScreen
        print("[BottomBarView] init completed. Initial selectedScreen: \(selectedScreen.wrappedValue)")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[BottomBarView] body invoked. Checking auth state.")
        
        let isLoggedIn = (authManager.user != nil)
        let isGuest = authManager.isGuest
        let fullyLoggedIn = (isLoggedIn && !isGuest)
        
        let _ = print("[BottomBarView] isLoggedIn: \(isLoggedIn), isGuest: \(isGuest), fullyLoggedIn: \(fullyLoggedIn)")
        
        return ZStack {
            let _ = print("[BottomBarView] Building background rectangle and shadow.")
            Rectangle()
                .fill(Color(UIColor.systemBackground).opacity(0.95))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: -2)
            
            HStack(spacing: 40) {
                
                // MARK: - Menu Button
                Button {
                    print("[BottomBarView] Menu button tapped. Setting selectedScreen = .menu.")
                    selectedScreen = .menu
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "house.fill")
                        Text("Menu").font(.footnote)
                    }
                }
                
                // MARK: - Feed Button
                Button {
                    print("[BottomBarView] Feed button tapped.")
                    if fullyLoggedIn {
                        print("[BottomBarView] User is fully logged in. Navigating to feed.")
                        selectedScreen = .feed
                    } else {
                        print("[BottomBarView] User not fully logged in. Triggering guest alert.")
                        showingGuestAlert = true
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "bubble.left.and.bubble.right.fill")
                        Text("Feed").font(.footnote)
                    }
                }
                
                // MARK: - Messages Button
                Button {
                    print("[BottomBarView] Messages button tapped.")
                    if fullyLoggedIn {
                        print("[BottomBarView] User is fully logged in. Navigating to messages.")
                        selectedScreen = .messages
                    } else {
                        print("[BottomBarView] User not fully logged in. Triggering guest alert.")
                        showingGuestAlert = true
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "message.fill")
                        Text("Messages").font(.footnote)
                    }
                }
                
                // MARK: - Profile Button
                Button {
                    print("[BottomBarView] Profile button tapped.")
                    if fullyLoggedIn {
                        print("[BottomBarView] User is fully logged in. Navigating to profile.")
                        selectedScreen = .profile
                    } else {
                        print("[BottomBarView] User not fully logged in. Triggering guest alert.")
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
            print("[BottomBarView] Guest alert is presented.")
            return Alert(
                title: Text("Account Required"),
                message: Text("Log In or Create an account to view this content."),
                dismissButton: .default(Text("OK"), action: {
                    print("[BottomBarView] Guest alert dismissed.")
                })
            )
        }
    }
}
