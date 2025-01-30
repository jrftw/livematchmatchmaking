//
//  RootContainerView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Hosts a single NavigationView plus a permanent BottomBarView.
//  The bar is always visible and clickable on top of any pushed view.
//
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct RootContainerView: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                MainMenuView()
                    .navigationBarHidden(true)
                
                BottomBarView()
                    .zIndex(9999)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
