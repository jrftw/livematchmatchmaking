//
//  MainMenuView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A membership-based main menu that can be edited/reordered/hidden using ReorderManager,
//  now includes a top banner ad if the user has not subscribed to remove ads.
//  This file references MyUserProfile's updated init with consistent parameters.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MainMenuView: View {
    
    // MARK: - Observed & State
    @ObservedObject private var authManager = AuthManager.shared
    @StateObject private var reorderManager = ReorderManager()
    @State private var isEditingLayout = false
    
    // MARK: - MenuItem
    public struct MenuItem: Identifiable {
        public let id = UUID()
        public let title: String
        public let icon: String
        public let color: Color
        public let destination: AnyView
        
        // If you need hiding:
        public var isHidden: Bool = false
        
        public init(title: String, icon: String, color: Color, destination: AnyView) {
            print("[MainMenuView.MenuItem] init => title: \(title), icon: \(icon)")
            self.title = title
            self.icon = icon
            self.color = color
            self.destination = destination
            print("[MainMenuView.MenuItem] init completed.")
        }
    }
    
    // MARK: - Init
    public init() {
        print("[MainMenuView] init called.")
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[MainMenuView] body invoked. Building layout.")
        
        return ZStack {
            let _ = print("[MainMenuView] Creating background gradient.")
            LinearGradient(
                gradient: Gradient(colors: [.white, .gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                if !hideAds {
                    let _ = print("[MainMenuView] hideAds == false => Displaying BannerAdView if iOS.")
                    #if canImport(UIKit)
                    BannerAdView()
                        .frame(height: 50)
                    #endif
                } else {
                    let _ = print("[MainMenuView] hideAds == true => BannerAdView is hidden.")
                }
                
                let _ = print("[MainMenuView] Adding 'Main Menu' title.")
                Text("Main Menu")
                    .font(.largeTitle)
                    .padding(.top, 30)
                
                let _ = print("[MainMenuView] Adding Edit Layout button. isEditingLayout: \(isEditingLayout)")
                Button(isEditingLayout ? "Done" : "Edit Layout") {
                    print("[MainMenuView] Toggling isEditingLayout from \(isEditingLayout) to \(!isEditingLayout).")
                    isEditingLayout.toggle()
                }
                .font(.headline)
                .padding(.vertical, 8)
                
                Spacer(minLength: 10)
                
                let _ = print("[MainMenuView] Building ScrollView with lazy grid for menu items.")
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
                            } else {
                                let _ = print("[MainMenuView] Item '\(item.title)' isHidden == true, skipping display.")
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
            print("[MainMenuView] onAppear => Loading menu items via buildMenuItems().")
            let items = buildMenuItems()
            print("[MainMenuView] onAppear => loadItems called with \(items.count) items.")
            reorderManager.loadItems(with: items)
        }
    }
    
    // MARK: - Hide Ads
    private var hideAds: Bool {
        let _ = print("[MainMenuView] hideAds computed property accessed. Fetching user profile.")
        guard let profile = fetchUserProfile() else {
            print("[MainMenuView] hideAds => No profile found. Returning false.")
            return false
        }
        print("[MainMenuView] hideAds => profile.hasRemoveAds: \(profile.hasRemoveAds)")
        return profile.hasRemoveAds
    }
    
    // MARK: - Drag Overlay
    private func shouldShowDragOverlay(title: String) -> Bool {
        let _ = print("[MainMenuView] shouldShowDragOverlay called for title: \(title). isEditingLayout: \(isEditingLayout)")
        guard isEditingLayout else {
            print("[MainMenuView] shouldShowDragOverlay => Not editing layout. Return false.")
            return false
        }
        let result = (title != "Settings")
        print("[MainMenuView] shouldShowDragOverlay => \(result).")
        return result
    }
    
    // MARK: - Build Items
    private func buildMenuItems() -> [MenuItem] {
        let _ = print("[MainMenuView] buildMenuItems called. Checking user profile and states.")
        
        guard let profile = fetchUserProfile() else {
            print("[MainMenuView] buildMenuItems => No valid profile. Returning notLoggedInOrGuestItems.")
            return notLoggedInOrGuestItems()
        }
        
        if authManager.user == nil, !authManager.isGuest {
            print("[MainMenuView] buildMenuItems => user is nil & not guest => returning notLoggedInOrGuestItems.")
            return notLoggedInOrGuestItems()
        }
        
        if profile.accountTypes.contains(.guest), authManager.isGuest {
            print("[MainMenuView] buildMenuItems => profile/account is guest => returning notLoggedInOrGuestItems.")
            return notLoggedInOrGuestItems()
        }
        
        print("[MainMenuView] buildMenuItems => returning memberOrOwnerItems.")
        return memberOrOwnerItems(profile: profile)
    }
    
    // MARK: - Guest Items
    private func notLoggedInOrGuestItems() -> [MenuItem] {
        print("[MainMenuView] notLoggedInOrGuestItems => Building guest items array.")
        return [
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
    
    // MARK: - Member or Owner
    private func memberOrOwnerItems(profile: MyUserProfile) -> [MenuItem] {
        print("[MainMenuView] memberOrOwnerItems => Building items for profile id: \(profile.id ?? "nil").")
        var result: [MenuItem] = []
        
        // Common
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
        
        // Achievements & Leaderboards if not guest
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
        
        // Membership
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
        
        // Admin
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
        
        // Always Settings
        result.append(
            MenuItem(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray,
                destination: AnyView(AppSettingsView())
            )
        )
        
        print("[MainMenuView] memberOrOwnerItems => Returning \(result.count) items.")
        return result
    }
    
    // MARK: - Fetch Profile
    private func fetchUserProfile() -> MyUserProfile? {
        print("[MainMenuView] fetchUserProfile called.")
        guard let user = authManager.user else {
            if authManager.isGuest {
                print("[MainMenuView] fetchUserProfile => Current user is nil but isGuest == true. Returning guest profile.")
                return MyUserProfile(
                    id: nil,
                    name: "Guest",
                    phone: nil,
                    phonePublicly: false,
                    birthYear: nil,
                    birthYearPublicly: false,
                    email: nil,
                    emailPublicly: false,
                    clanTag: nil,
                    clanColorHex: nil,
                    profilePictureURL: nil,
                    bannerURL: nil,
                    followers: 0,
                    friends: 0,
                    wins: 0,
                    losses: 0,
                    livePlatforms: [],
                    livePlatformLinks: [],
                    agencies: [],
                    creatorNetworks: [],
                    teams: [],
                    communities: [],
                    tags: [],
                    socialLinks: [],
                    gamingAccounts: [],
                    gamingAccountDetails: [],
                    livePlatformDetails: [],
                    accountTypes: [.guest],
                    bio: "",
                    isSearching: false,
                    roster: nil,
                    establishedDate: nil,
                    subscriptionActive: false,
                    subscriptionPrice: 0.0,
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
                    hasRemoveAds: false
                )
            }
            print("[MainMenuView] fetchUserProfile => Current user is nil and not guest. Returning nil.")
            return nil
        }
        
        // Example fallback if user is present
        print("[MainMenuView] fetchUserProfile => user found: \(user.uid), using example MyUserProfile.")
        let example = MyUserProfile(
            id: user.uid,
            name: user.displayName ?? "",
            phone: nil,
            phonePublicly: false,
            birthYear: nil,
            birthYearPublicly: false,
            email: user.email ?? "",
            emailPublicly: false,
            clanTag: nil,
            clanColorHex: nil,
            profilePictureURL: nil,
            bannerURL: nil,
            followers: 0,
            friends: 0,
            wins: 0,
            losses: 0,
            livePlatforms: [],
            livePlatformLinks: [],
            agencies: [],
            creatorNetworks: [],
            teams: [],
            communities: [],
            tags: [],
            socialLinks: [],
            gamingAccounts: [],
            gamingAccountDetails: [],
            livePlatformDetails: [],
            accountTypes: [.viewer, .creator],
            bio: "",
            isSearching: false,
            roster: nil,
            establishedDate: nil,
            subscriptionActive: false,
            subscriptionPrice: 0.0,
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
            hasRemoveAds: false
        )
        print("[MainMenuView] fetchUserProfile => example profile created.")
        return example
    }
}
