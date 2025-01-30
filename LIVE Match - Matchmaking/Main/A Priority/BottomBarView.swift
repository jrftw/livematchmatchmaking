//
//  BottomBarView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A global bottom bar with 4 icons: Menu, Feed, Messages, Profile.
//  Each icon uses NavigationLink to push a new view. Always on top, never greyed out.
//
import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct BottomBarView: View {
    @ObservedObject private var authManager = AuthManager.shared
    
    public init() {}
    
    public var body: some View {
        let isLoggedIn = (authManager.user != nil || authManager.isGuest)
        
        ZStack(alignment: .center) {
            Rectangle()
                .fill(Color(UIColor.systemBackground).opacity(0.95))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: -2)
            
            HStack {
                Spacer()
                
                NavigationLink(destination: MainMenuView()) {
                    VStack(spacing: 2) {
                        Image(systemName: "house.fill")
                        Text("Menu").font(.footnote)
                    }
                    .padding(.horizontal, 10)
                }
                
                Spacer()
                
                if isLoggedIn {
                    NavigationLink(destination: FeedView()) {
                        VStack(spacing: 2) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("Feed").font(.footnote)
                        }
                        .padding(.horizontal, 10)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                if isLoggedIn {
                    NavigationLink(destination: MessagesView()) {
                        VStack(spacing: 2) {
                            Image(systemName: "message.fill")
                            Text("Messages").font(.footnote)
                        }
                        .padding(.horizontal, 10)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
                
                if isLoggedIn {
                    NavigationLink(destination: ProfileHomeView()) {
                        VStack(spacing: 2) {
                            Image(systemName: "person.crop.circle")
                            Text("Profile").font(.footnote)
                        }
                        .padding(.horizontal, 10)
                    }
                } else {
                    Spacer()
                }
                
                Spacer()
            }
        }
        .frame(height: 60)
        .allowsHitTesting(true)
    }
}
