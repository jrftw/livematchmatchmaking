// MARK: MainMenuView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A production-ready menu view with reorderable layout and membership-based tabs.

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
            LinearGradient(
                gradient: Gradient(colors: [.white, .gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
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
                destination: AnyView(SignInView()) // Updated to SignInView
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
        
        if profile.accountTypes.contains(.creator) || profile.accountTypes.contains(.gamer) {
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
        }
        
        if profile.accountTypes.contains(.viewer) {
            result.append(
                MenuItem(
                    title: "Tournaments",
                    icon: "rosette",
                    color: .red,
                    destination: AnyView(TournamentListView())
                )
            )
        }
        
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
                    isCreatorNetworkAdmin: false
                )
            }
            return nil
        }
        
        // Example fallback profile
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
            isCreatorNetworkAdmin: false
        )
        return example
    }
}
