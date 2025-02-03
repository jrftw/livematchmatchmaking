//
//  MainMenuView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
//  Updated to accept a @Binding var selectedScreen so we can properly navigate to
//  SignInView(selectedScreen: $selectedScreen), AppSettingsView(selectedScreen: $selectedScreen), etc.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MainMenuView: View {
    // MARK: - ObservedObject
    @ObservedObject private var authManager = AuthManager.shared
    
    // MARK: - Binding
    @Binding var selectedScreen: MainScreen
    
    // MARK: - State
    @StateObject private var reorderManager = ReorderManager()
    @State private var isEditingLayout = false
    
    // MARK: - Init
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
    // MARK: - Body
    public var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [.white, .gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                #if os(iOS)
                BannerAdView()
                    .frame(height: 50)
                #endif
                
                Text("Main Menu")
                    .font(.largeTitle)
                    .padding(.top, 30)
                
                Button(isEditingLayout ? "Done" : "Edit Layout") {
                    isEditingLayout.toggle()
                }
                .font(.headline)
                .padding(.vertical, 8)
                
                Spacer(minLength: 10)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)]) {
                        ForEach(reorderManager.activeItems, id: \.id) { item in
                            if !item.isHidden {
                                NavigationLink(destination: item.destination) {
                                    VStack(spacing: 12) {
                                        Image(systemName: item.icon)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                            .padding()
                                            .background(item.color.opacity(0.15))
                                            .clipShape(Circle())
                                        Text(item.title)
                                            .font(.headline)
                                            .foregroundColor(.primary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(item.color.opacity(0.2))
                                    )
                                }
                                .overlay(
                                    DraggableHandleOverlay(
                                        isEditing: isEditingLayout,
                                        title: item.title,
                                        reorderManager: reorderManager
                                    )
                                    .offset(x: 40, y: -40)
                                    .opacity(isEditingLayout ? 1 : 0)
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                }
                
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            let items = buildMenuItems()
            reorderManager.loadItems(with: items)
        }
    }
    
    // MARK: - Build Menu Items
    private func buildMenuItems() -> [MenuItem] {
        // If user is a guest => normal items + "Create Account or Log In"
        if authManager.isGuest {
            var items = normalItems()
            items.insert(
                MenuItem(
                    title: "Create Account or Log In",
                    icon: "person.crop.circle.badge.plus",
                    color: .blue,
                    // Pass selectedScreen to SignInView
                    destination: AnyView(SignInView(selectedScreen: $selectedScreen))
                ),
                at: 0
            )
            return items
        }
        
        // If user is logged in => normal items
        if authManager.user != nil {
            return normalItems()
        }
        
        // If user == nil & NOT guest => minimal set
        return [
            MenuItem(
                title: "Create Account or Log In",
                icon: "person.crop.circle.badge.plus",
                color: .blue,
                destination: AnyView(SignInView(selectedScreen: $selectedScreen))
            ),
            MenuItem(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray,
                destination: AnyView(AppSettingsView(selectedScreen: $selectedScreen))
            )
        ]
    }
    
    // MARK: - Normal Items
    private func normalItems() -> [MenuItem] {
        [
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
                title: "Tournaments",
                icon: "rosette",
                color: .red,
                destination: AnyView(TournamentListView())
            ),
            MenuItem(
                title: "Achievements",
                icon: "star.fill",
                color: .yellow,
                destination: AnyView(AchievementsView())
            ),
            MenuItem(
                title: "Leaderboards",
                icon: "list.number",
                color: .orange,
                destination: AnyView(LeaderboardsView())
            ),
            MenuItem(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray,
                // Pass selectedScreen to AppSettingsView
                destination: AnyView(AppSettingsView(selectedScreen: $selectedScreen))
            )
        ]
    }
}
