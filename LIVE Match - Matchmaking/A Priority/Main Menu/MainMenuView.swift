//
//  MainMenuView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A membership-based main menu that can be edited/reordered/hidden using ReorderManager,
//  now includes a top banner ad if the user has not subscribed to remove ads.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MainMenuView: View {
    @ObservedObject private var authManager = AuthManager.shared
    @StateObject private var reorderManager = ReorderManager()
    @State private var isEditingLayout = false
    
    // We assume your user profile or membership logic includes a `hasRemoveAds` (or similar) boolean.
    // If the user is subscribed to "Remove Ads," we hide the banner.
    
    // Make it public so ReorderManager can reference [MainMenuView.MenuItem] publicly.
    public struct MenuItem: Identifiable {
        public let id = UUID()
        public let title: String
        public let icon: String
        public let color: Color
        public let destination: AnyView
        
        // If you need hiding:
        // public var isHidden: Bool = false
        
        public init(title: String, icon: String, color: Color, destination: AnyView) {
            self.title = title
            self.icon = icon
            self.color = color
            self.destination = destination
        }
    }
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.white, .gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // --- Banner Ad at top, only if not subscribed and on iOS ---
                if !hideAds {
                    #if canImport(UIKit)
                    BannerAdView()
                        .frame(height: 50)  // typical banner height
                    #endif
                }
                
                // Title
                Text("Main Menu")
                    .font(.largeTitle)
                    .padding(.top, 30)
                
                // Edit Layout Button
                Button(isEditingLayout ? "Done" : "Edit Layout") {
                    isEditingLayout.toggle()
                }
                .font(.headline)
                .padding(.vertical, 8)
                
                Spacer(minLength: 10)
                
                // Grid of items
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
                                    .opacity(shouldShowDragOverlay(title: item.title) ? 1 : 0)
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
            // Build the final array of items
            let items = buildMenuItems()
            // Load them into reorderManager
            reorderManager.loadItems(with: items)
        }
    }
    
    // MARK: - Hide Ads Check
    private var hideAds: Bool {
        guard let profile = fetchUserProfile() else {
            // If not logged in or no profile, show ads
            return false
        }
        // If the user has subscribed to "Remove Ads," hide it:
        // e.g., `profile.hasRemoveAds` or your subscription logic
        return profile.hasRemoveAds
    }
    
    // Show drag overlay if editing, except for certain blocked items (like "Settings")
    private func shouldShowDragOverlay(title: String) -> Bool {
        guard isEditingLayout else { return false }
        return (title != "Settings")
    }
    
    private func buildMenuItems() -> [MenuItem] {
        guard let profile = fetchUserProfile() else {
            return notLoggedInOrGuestItems()
        }
        if authManager.user == nil, !authManager.isGuest {
            return notLoggedInOrGuestItems()
        }
        if profile.accountTypes.contains(.guest), authManager.isGuest {
            return notLoggedInOrGuestItems()
        }
        return memberOrOwnerItems(profile: profile)
    }
    
    private func notLoggedInOrGuestItems() -> [MenuItem] {
        [
            MenuItem(
                title: "Create Account or Log In",
                icon: "person.crop.circle.badge.plus",
                color: .blue,
                destination: AnyView(SignInView())
            ),
            MenuItem(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray,
                destination: AnyView(AppSettingsView())
            )
        ]
    }
    
    private func memberOrOwnerItems(profile: MyUserProfile) -> [MenuItem] {
        var result: [MenuItem] = []
        
        // Everyone sees these:
        result.append(
            MenuItem(
                title: "LIVE Matchmaking",
                icon: "video.fill",
                color: .purple,
                destination: AnyView(StreamingView())
            )
        )
        result.append(
            MenuItem(
                title: "Game Matchmaking",
                icon: "gamecontroller.fill",
                color: .blue,
                destination: AnyView(MatchmakingView())
            )
        )
        result.append(
            MenuItem(
                title: "Tournaments",
                icon: "rosette",
                color: .red,
                destination: AnyView(TournamentListView())
            )
        )
        
        // Achievements & Leaderboards for non-guest
        if !profile.accountTypes.contains(.guest) {
            result.append(
                MenuItem(
                    title: "Achievements",
                    icon: "star.fill",
                    color: .yellow,
                    destination: AnyView(AchievementsView())
                )
            )
            result.append(
                MenuItem(
                    title: "Leaderboards",
                    icon: "list.number",
                    color: .orange,
                    destination: AnyView(LeaderboardsView())
                )
            )
        }
        
        // Membership booleans
        if profile.hasCommunityMembership {
            result.append(
                MenuItem(
                    title: "Community",
                    icon: "person.3.fill",
                    color: .green,
                    destination: AnyView(CommunityViewPlaceholder())
                )
            )
        }
        if profile.hasGroupMembership {
            result.append(
                MenuItem(
                    title: "Group",
                    icon: "person.3.sequence.fill",
                    color: .blue,
                    destination: AnyView(GroupViewPlaceholder())
                )
            )
        }
        if profile.hasTeamMembership {
            result.append(
                MenuItem(
                    title: "Team",
                    icon: "sportscourt.fill",
                    color: .purple,
                    destination: AnyView(TeamViewPlaceholder())
                )
            )
        }
        if profile.hasAgencyMembership {
            result.append(
                MenuItem(
                    title: "Agency",
                    icon: "briefcase.fill",
                    color: .pink,
                    destination: AnyView(AgencyViewPlaceholder())
                )
            )
        }
        if profile.hasCreatorNetworkMembership {
            result.append(
                MenuItem(
                    title: "Creator Network",
                    icon: "antenna.radiowaves.left.and.right",
                    color: .orange,
                    destination: AnyView(CreatorNetworkViewPlaceholder())
                )
            )
        }
        
        // Admin checks
        if profile.isCommunityAdmin {
            result.append(
                MenuItem(
                    title: "Community Management",
                    icon: "person.3.fill",
                    color: .green,
                    destination: AnyView(ManageCommunityView())
                )
            )
        }
        if profile.isGroupAdmin {
            result.append(
                MenuItem(
                    title: "Group Management",
                    icon: "person.3.sequence.fill",
                    color: .blue,
                    destination: AnyView(GroupManagementViewPlaceholder())
                )
            )
        }
        if profile.isTeamAdmin {
            result.append(
                MenuItem(
                    title: "Team Management",
                    icon: "sportscourt.fill",
                    color: .purple,
                    destination: AnyView(ManageBusinessView())
                )
            )
        }
        if profile.isAgencyAdmin {
            result.append(
                MenuItem(
                    title: "Agency Management",
                    icon: "briefcase.fill",
                    color: .pink,
                    destination: AnyView(ManageBusinessView())
                )
            )
        }
        if profile.isCreatorNetworkAdmin {
            result.append(
                MenuItem(
                    title: "Creator Network Management",
                    icon: "antenna.radiowaves.left.and.right",
                    color: .orange,
                    destination: AnyView(ManageBusinessView())
                )
            )
        }
        
        // Always add Settings
        result.append(
            MenuItem(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray,
                destination: AnyView(AppSettingsView())
            )
        )
        
        return result
    }
    
    private func fetchUserProfile() -> MyUserProfile? {
        guard let user = authManager.user else {
            // If guest
            if authManager.isGuest {
                return MyUserProfile(
                    id: nil,
                    accountTypes: [.guest],
                    email: nil,
                    name: "Guest",
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
                    createdAt: Date(),
                    hasCommunityMembership: false,
                    isCommunityAdmin: false,
                    hasGroupMembership: false,
                    isGroupAdmin: false,
                    hasTeamMembership: false,
                    isTeamAdmin: false,
                    hasAgencyMembership: false,
                    isAgencyAdmin: false,
                    hasCreatorNetworkMembership: false,
                    isCreatorNetworkAdmin: false,
                    hasRemoveAds: false // <-- add this or track in another field
                )
            }
            return nil
        }
        
        // Example fallback if user is present
        let example = MyUserProfile(
            id: user.uid,
            accountTypes: [.viewer, .creator],
            email: user.email ?? "",
            name: user.displayName ?? "",
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
            createdAt: Date(),
            hasCommunityMembership: true,
            isCommunityAdmin: false,
            hasGroupMembership: true,
            isGroupAdmin: true,
            hasTeamMembership: false,
            isTeamAdmin: false,
            hasAgencyMembership: false,
            isAgencyAdmin: false,
            hasCreatorNetworkMembership: false,
            isCreatorNetworkAdmin: false,
            hasRemoveAds: false // or set to true to hide banner
        )
        return example
    }
}
