// MARK: - MainMenuView.swift
import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MainMenuView: View {
    // MARK: Properties
    @ObservedObject private var authManager = AuthManager.shared
    @StateObject private var achievementsManager = AchievementsManager()
    
    @Binding var selectedScreen: MainScreen
    
    private let showLiveMatchmaking      = true
    private let showGameMatchmaking      = false
    private let showTournaments          = false
    private let showNews                 = true
    private let showMyEvents             = true
    private let showAchievements         = true
    private let showLeaderboards         = true
    private let showAgencyCNReview       = false
    private let showTemplates            = true
    private let showCreateAccountOrLogin = true
    private let showHelp                 = true
    private let showSettings             = true
    
    @StateObject private var reorderManager = ReorderManager()
    @State private var isEditingLayout = false
    
    // MARK: Init
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
    // MARK: Body
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
            let defaultItems = allMenuItems()
            let final = filterMenuItems(defaultItems)
            reorderManager.loadItems(with: final)
        }
    }
    
    // MARK: Menu Items
    private func allMenuItems() -> [MenuItem] {
        var items = [MenuItem]()
        
        // 1. LIVE Matchmaking
        if showLiveMatchmaking {
            items.append(MenuItem(
                title: "LIVE Matchmaking",
                icon: "video.fill",
                color: .purple,
                destination: AnyView(StreamingView())
            ))
        }
        
        // 2. Game Matchmaking
        if showGameMatchmaking {
            items.append(MenuItem(
                title: "Game Matchmaking",
                icon: "gamecontroller.fill",
                color: .blue,
                destination: AnyView(MatchmakingView())
            ))
        }
        
        // 3. Tournaments
        if showTournaments {
            items.append(MenuItem(
                title: "Tournaments",
                icon: "rosette",
                color: .red,
                destination: AnyView(TournamentListView())
            ))
        }
        
        // 4. My Events
        if showMyEvents {
            items.append(MenuItem(
                title: "My Events",
                icon: "calendar",
                color: .red,
                destination: AnyView(MyEventsView())
            ))
        }
        
        // 5. Achievements
        if showAchievements {
            items.append(MenuItem(
                title: "Achievements",
                icon: "star.fill",
                color: .yellow,
                destination: AnyView(AchievementsView(manager: achievementsManager))
            ))
        }
        
        // 6. Leaderboards
        if showLeaderboards {
            // LeaderboardsView has no init with arguments, so remove "manager:"
            items.append(MenuItem(
                title: "Leaderboards",
                icon: "list.number",
                color: .orange,
                destination: AnyView(LeaderboardsView())
            ))
        }
        
        // 7. Agency / Creator Network Review
        if showAgencyCNReview {
            items.append(MenuItem(
                title: "Agency / Creator Network Review",
                icon: "magnifyingglass.circle",
                color: .indigo,
                destination: AnyView(AgencyCNReviewView())
            ))
        }
        
        // 8. Create Account or Log In
        if showCreateAccountOrLogin {
            items.append(MenuItem(
                title: "Create Account or Log In",
                icon: "person.crop.circle.badge.plus",
                color: .blue,
                destination: AnyView(SignInView(selectedScreen: $selectedScreen))
            ))
        }
        
        // 9. Templates
        if showTemplates {
            items.append(MenuItem(
                title: "Templates",
                icon: "doc.text.fill",
                color: .cyan,
                destination: AnyView(TemplatesView())
            ))
        }
        
        // 10. News
        if showNews {
            items.append(MenuItem(
                title: "News",
                icon: "newspaper",
                color: .mint,
                destination: AnyView(NewsView())
            ))
        }
        
        // 11. Help
        if showHelp {
            items.append(MenuItem(
                title: "Help",
                icon: "questionmark.circle",
                color: .green,
                destination: AnyView(HelpView())
            ))
        }
        
        // 12. Settings
        if showSettings {
            items.append(MenuItem(
                title: "Settings",
                icon: "gearshape.fill",
                color: .gray,
                destination: AnyView(AppSettingsView(selectedScreen: $selectedScreen))
            ))
        }
        
        return items
    }
    
    // MARK: Filter Items
    private func filterMenuItems(_ items: [MenuItem]) -> [MenuItem] {
        var newItems = items
        let isLoggedIn = (authManager.user != nil && !authManager.isGuest)
        
        for i in newItems.indices {
            let title = newItems[i].title
            switch title {
            case "LIVE Matchmaking",
                 "Game Matchmaking",
                 "Tournaments",
                 "My Events",
                 "Achievements",
                 "Leaderboards",
                 "Agency / Creator Network Review":
                if !isLoggedIn {
                    newItems[i].isHidden = true
                }
            case "Create Account or Log In":
                if isLoggedIn {
                    newItems[i].isHidden = true
                }
            default:
                break
            }
        }
        
        return newItems
    }
}
