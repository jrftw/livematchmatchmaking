//
//  RootContainerView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Hosts the entire app with a custom bottom bar that remains visible and doesn't block interactions.
//

import SwiftUI
import FirebaseAuth

// MARK: - MainScreen Enum
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public enum MainScreen {
    case menu
    case feed
    case messages
    case profile
}

// MARK: - RootContainerView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct RootContainerView: View {
    @State private var selectedScreen: MainScreen = .menu
    
    public init() {}
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            screenContent
                .padding(.bottom, 60)
            
            BottomBarView(selectedScreen: $selectedScreen)
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    @ViewBuilder
    private var screenContent: some View {
        switch selectedScreen {
        case .menu:
            NavigationView {
                MainMenuView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .feed:
            NavigationView {
                FeedView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Feed")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .messages:
            NavigationView {
                MessagesHomeView()
                    .navigationTitle("Messages")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .profile:
            NavigationView {
                // Ensure that ProfileHomeView is defined somewhere in your project.
                // If it's in another file, just import it.
                ProfileHomeView()
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationTitle("Profile")
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
