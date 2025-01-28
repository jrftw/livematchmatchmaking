// MARK: File 8: MainMenuView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// We'll add a non-intrusive banner at the bottom for iOS only.

import SwiftUI

@available(iOS 15.6, *)
struct MainMenuView: View {
    
    private struct MenuItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
        let destination: AnyView
    }
    
    private let items: [MenuItem] = [
        MenuItem(
            title: "LIVE Matchmaking",
            icon: "video.fill",
            color: .purple,
            destination: AnyView(StreamingView())
        ),
        MenuItem(
            title: "Game Matchmaking",
            icon: "gamecontroller.fill",
            color: .blue,
            destination: AnyView(MatchmakingView())
        ),
        MenuItem(
            title: "My Profile",
            icon: "person.crop.circle",
            color: .green,
            destination: AnyView(ProfileHomeView())
        ),
        MenuItem(
            title: "Feed",
            icon: "bubble.left.and.bubble.right.fill",
            color: .orange,
            destination: AnyView(FeedView())
        ),
        MenuItem(
            title: "Tournaments",
            icon: "rosette",
            color: .red,
            destination: AnyView(TournamentListView())
        ),
        MenuItem(
            title: "DM",
            icon: "envelope.fill",
            color: .pink,
            destination: AnyView(DirectMessagesListView())
        ),
        MenuItem(
            title: "Settings",
            icon: "gearshape.fill",
            color: .gray,
            destination: AnyView(AppSettingsView())
        )
    ]
    
    var body: some View {
        #if os(iOS)
        iOSMainMenuContent()
        #else
        MacOrOtherMainMenuContent()
        #endif
    }
    
    // MARK: iOS Content with Banner
    @ViewBuilder
    private func iOSMainMenuContent() -> some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.2)]),
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                
                VStack {
                    Text("Main Menu")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                    
                    Spacer(minLength: 10)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)]) {
                            ForEach(items) { item in
                                NavigationLink(destination: item.destination) {
                                    VStack(spacing: 12) {
                                        Image(systemName: item.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .padding()
                                            .background(item.color.opacity(0.1))
                                            .clipShape(Circle())
                                        Text(item.title)
                                            .font(.headline)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 12)
                                        .fill(item.color.opacity(0.2)))
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Banner at bottom
                    BannerAdView()
                        .frame(width: 320, height: 50) // typical banner size
                        .padding(.bottom, 10)
                    
                    // Sign Out
                    Button {
                        AuthManager.shared.signOut()
                    } label: {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 10)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    // MARK: macOS / other platforms Content
    @ViewBuilder
    private func MacOrOtherMainMenuContent() -> some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.2)]),
                               startPoint: .top,
                               endPoint: .bottom)
                .ignoresSafeArea()
                
                VStack {
                    Text("Main Menu")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top, 20)
                    
                    Spacer(minLength: 10)
                    
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)]) {
                            ForEach(items) { item in
                                NavigationLink(destination: item.destination) {
                                    VStack(spacing: 12) {
                                        Image(systemName: item.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .padding()
                                            .background(item.color.opacity(0.1))
                                            .clipShape(Circle())
                                        Text(item.title)
                                            .font(.headline)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(RoundedRectangle(cornerRadius: 12)
                                        .fill(item.color.opacity(0.2)))
                                }
                            }
                        }
                        .padding()
                    }
                    
                    Spacer(minLength: 20)
                    
                    // No banner on macOS / visionOS
                    Button {
                        AuthManager.shared.signOut()
                    } label: {
                        Text("Sign Out")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(8)
                            .padding(.horizontal, 30)
                    }
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
