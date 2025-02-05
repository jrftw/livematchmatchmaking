//
//  BottomBarView.swift
//  LIVE Match - Matchmaking
//
//  A bottom bar with 5 buttons (Menu, Feed, Search, Messages, Profile).
//  If not fully logged in, show an alert for feed/search/messages/profile.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct BottomBarView: View {
    // MARK: - ObservedObject
    @ObservedObject private var authManager = AuthManager.shared
    
    // MARK: - Binding
    @Binding var selectedScreen: MainScreen
    
    // MARK: - State
    @State private var showingGuestAlert = false
    
    // MARK: - Search Toggle
    // Currently disabled; set to true when you want Search to be active
    private let searchEnabled = false
    
    // MARK: - Init
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
    // MARK: - Body
    public var body: some View {
        let isLoggedIn = (authManager.user != nil)
        let isGuest = authManager.isGuest
        let fullyLoggedIn = (isLoggedIn && !isGuest)
        
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemBackground).opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: -2)
            
            HStack(spacing: 30) {
                // MARK: Menu
                Button {
                    selectedScreen = .menu
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "house.fill")
                        Text("Menu").font(.footnote)
                    }
                }
                
                // MARK: Feed
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
                
                // MARK: Search (Only show if searchEnabled and not guest)
                if searchEnabled && fullyLoggedIn {
                    Button {
                        selectedScreen = .search
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "magnifyingglass")
                            Text("Search").font(.footnote)
                        }
                    }
                }
                
                // MARK: Messages
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
                
                // MARK: Profile
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
