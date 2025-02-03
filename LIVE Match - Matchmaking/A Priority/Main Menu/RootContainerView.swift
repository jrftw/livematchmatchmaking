//
//  RootContainerView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
//  A container that handles selectedScreen for a single view + bottom bar approach,
//  ensuring that when .profile is selected, we fetch and display the *real* profile
//  from Firestore rather than any placeholder.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct RootContainerView: View {
    @Binding var selectedScreen: MainScreen
    
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
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
                MainMenuView(selectedScreen: $selectedScreen)
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarHidden(true)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .feed:
            NavigationView {
                FeedView()
                    .navigationBarTitle("Feed")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .messages:
            NavigationView {
                MessagesHomeView()
                    .navigationBarTitle("Messages")
            }
            .navigationViewStyle(StackNavigationViewStyle())
            
        case .profile:
            NavigationView {
                // Instead of passing placeholder data,
                // we use the ProfileHomeView that fetches real data
                // from Firestore using the current user's uid.
                ProfileHomeView(userID: Auth.auth().currentUser?.uid)
                    .navigationTitle("Profile")
                    .navigationBarTitleDisplayMode(.inline)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
