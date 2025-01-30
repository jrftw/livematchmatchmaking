// MARK: MainMenuView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Shows a grid of menu items for the user, minus sign-out button.
// Integrates a reorder option, with "Achievements" for all non-guest users, and "Settings" always bottom-right.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct MainMenuView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @StateObject private var reorderManager = ReorderManager()
    
    @State private var isEditingLayout = false
    
    struct MenuItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let color: Color
        let destination: AnyView
    }
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.white, .gray.opacity(0.1)]),
                           startPoint: .top,
                           endPoint: .bottom)
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Main Menu")
                    .font(.largeTitle)
                    .padding(.top, 30)
                
                // Reorder toggle button
                Button(isEditingLayout ? "Done" : "Edit Layout") {
                    isEditingLayout.toggle()
                }
                .font(.headline)
                .padding(.vertical, 8)
                
                Spacer(minLength: 10)
                
                ScrollView {
                    // Adaptive grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 20)]) {
                        // Return items from reorderManager
                        ForEach(reorderedItems(), id: \.id) { item in
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
                                // Show drag handle if editing layout AND it's not Settings
                                DraggableHandleOverlay(
                                    isEditing: isEditingLayout,
                                    title: item.title,
                                    reorderManager: reorderManager
                                )
                                .offset(x: 40, y: -40)
                                .opacity((isEditingLayout && item.title != "Settings") ? 1 : 0)
                            )
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
            // Load the items into reorderManager
            reorderManager.loadItems(with: dynamicItems())
        }
    }
    
    // MARK: Generate the main menu items.
    // "Achievements" is added for non-guest accounts. "Settings" is always last.
    func dynamicItems() -> [MenuItem] {
        let accountTypes = currentAccountTypes()
        
        // If user is not logged in and not a guest
        if authManager.user == nil && !authManager.isGuest {
            return [
                MenuItem(
                    title: "Create Account or Log In",
                    icon: "person.crop.circle.badge.plus",
                    color: .blue,
                    destination: AnyView(SignUpView())
                ),
                MenuItem(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray,
                    destination: AnyView(AppSettingsView())
                )
            ]
        }
        
        // If user is a guest
        if accountTypes.contains(.guest) && authManager.isGuest {
            return [
                MenuItem(
                    title: "Create Account or Log In",
                    icon: "person.crop.circle.badge.plus",
                    color: .blue,
                    destination: AnyView(SignUpView())
                ),
                MenuItem(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray,
                    destination: AnyView(AppSettingsView())
                )
            ]
        }
        
        // For viewer/creator/gamer
        if accountTypes.contains(.viewer) || accountTypes.contains(.creator) || accountTypes.contains(.gamer) {
            var items: [MenuItem] = []
            if accountTypes.contains(.creator) || accountTypes.contains(.gamer) {
                items.append(
                    MenuItem(
                        title: "LIVE Matchmaking",
                        icon: "video.fill",
                        color: .purple,
                        destination: AnyView(StreamingView())
                    )
                )
                items.append(
                    MenuItem(
                        title: "Game Matchmaking",
                        icon: "gamecontroller.fill",
                        color: .blue,
                        destination: AnyView(MatchmakingView())
                    )
                )
            }
            if accountTypes.contains(.viewer) {
                items.append(
                    MenuItem(
                        title: "Tournaments",
                        icon: "rosette",
                        color: .red,
                        destination: AnyView(TournamentListView())
                    )
                )
            }
            
            // Add Achievements
            items.append(
                MenuItem(
                    title: "Achievements",
                    icon: "star.fill",
                    color: .yellow,
                    destination: AnyView(AchievementsView())
                )
            )
            
            items.append(
                MenuItem(
                    title: "Leaderboards",
                    icon: "list.number",
                    color: .orange,
                    destination: AnyView(LeaderboardsView())
                )
            )
            
            // Always add "Settings" last
            items.append(
                MenuItem(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray,
                    destination: AnyView(AppSettingsView())
                )
            )
            return items
        }
        
        // For team/agency/creatornetwork/scouter
        if accountTypes.contains(.team) || accountTypes.contains(.agency) ||
           accountTypes.contains(.creatornetwork) || accountTypes.contains(.scouter) {
            return [
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
                // Achievements
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
                    title: "Manage Your Business",
                    icon: "briefcase.fill",
                    color: .green,
                    destination: AnyView(ManageBusinessView())
                ),
                MenuItem(
                    title: "Settings",
                    icon: "gearshape.fill",
                    color: .gray,
                    destination: AnyView(AppSettingsView())
                )
            ]
        }
        
        // Fallback for non-guest user not matched above
        return [
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
            // Achievements
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
                title: "Manage Your Community",
                icon: "person.2.fill",
                color: .green,
                destination: AnyView(ManageCommunityView())
            ),
            MenuItem(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray,
                destination: AnyView(AppSettingsView())
            )
        ]
    }
    
    private func reorderedItems() -> [ReorderManager.ReorderableMenuItem] {
        return reorderManager.activeItems
    }
    
    private func currentAccountTypes() -> Set<AccountType> {
        guard let profile = fetchLocalOrRemoteProfile() else { return [] }
        return Set(profile.accountTypes)
    }
    
    private func fetchLocalOrRemoteProfile() -> UserProfile? {
        guard let firebaseUser = authManager.user else {
            if authManager.isGuest {
                let guestProfile = UserProfile(
                    id: nil,
                    accountTypes: [.guest],
                    email: nil,
                    name: "Guest User",
                    bio: "Limited features",
                    birthYear: nil,
                    phone: nil,
                    profilePictureURL: nil,
                    bannerURL: nil,
                    clanTag: nil,
                    tags: [],
                    socialLinks: [],
                    gamingAccounts: [],
                    livePlatforms: [],
                    gamingAccountDetails: [],
                    livePlatformDetails: [],
                    followers: 0,
                    friends: 0,
                    isSearching: false,
                    wins: 0,
                    losses: 0,
                    roster: [],
                    establishedDate: nil,
                    subscriptionActive: false,
                    subscriptionPrice: 0,
                    createdAt: Date()
                )
                return guestProfile
            }
            return nil
        }
        let exampleTypes: [AccountType] = [.creator]
        let profile = UserProfile(
            id: firebaseUser.uid,
            accountTypes: exampleTypes,
            email: firebaseUser.email ?? "",
            name: firebaseUser.displayName ?? "",
            bio: "",
            birthYear: nil,
            phone: nil,
            profilePictureURL: nil,
            bannerURL: nil,
            clanTag: nil,
            tags: [],
            socialLinks: [],
            gamingAccounts: [],
            livePlatforms: [],
            gamingAccountDetails: [],
            livePlatformDetails: [],
            followers: 0,
            friends: 0,
            isSearching: false,
            wins: 0,
            losses: 0,
            roster: [],
            establishedDate: nil,
            subscriptionActive: false,
            subscriptionPrice: 0,
            createdAt: Date()
        )
        return profile
    }
}
