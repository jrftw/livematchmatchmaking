// MARK: BottomBarView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A custom bar that switches between Menu, Feed, Messages, Profile. Never blocks interaction.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct BottomBarView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @Binding var selectedScreen: MainScreen
    
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
    public var body: some View {
        let isLoggedIn = (authManager.user != nil || authManager.isGuest)
        
        ZStack {
            Rectangle()
                .fill(Color(UIColor.systemBackground).opacity(0.95))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: -2)
            
            HStack {
                Spacer()
                
                Button {
                    if selectedScreen != .menu {
                        selectedScreen = .menu
                    }
                } label: {
                    VStack(spacing: 2) {
                        Image(systemName: "house.fill")
                        Text("Menu").font(.footnote)
                    }
                    .foregroundColor(.primary)
                }
                
                Spacer()
                
                if isLoggedIn {
                    Button {
                        if selectedScreen != .feed {
                            selectedScreen = .feed
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Feed").font(.footnote)
                        }
                        .foregroundColor(.primary)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                if isLoggedIn {
                    Button {
                        if selectedScreen != .messages {
                            selectedScreen = .messages
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "message.fill")
                            Text("Messages").font(.footnote)
                        }
                        .foregroundColor(.primary)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                if isLoggedIn {
                    Button {
                        if selectedScreen != .profile {
                            selectedScreen = .profile
                        }
                    } label: {
                        VStack(spacing: 2) {
                            Image(systemName: "person.crop.circle")
                            Text("Profile").font(.footnote)
                        }
                        .foregroundColor(.primary)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.horizontal)
        }
        .frame(height: 60)
    }
}
