//
//  MainMenuView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//
//  Default order with booleans controlling each item’s inclusion.
//  - Items #1–6 also hide if not logged in.
//  - Item #7 hides if logged in.
//  - Items #8–9 visible to everyone if their booleans are true.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MainMenuView: View {
    // MARK: - ObservedObject
    @ObservedObject private var authManager = AuthManager.shared
    
    // Binding to track which main screen is selected
    @Binding var selectedScreen: MainScreen
    
    // MARK: - Boolean Toggles (turn each page on/off in code)
    private let showLiveMatchmaking      = true
    private let showGameMatchmaking      = true
    private let showTournaments          = false
    private let showAchievements         = true
    private let showLeaderboards         = true
    private let showAgencyCNReview       = false
    private let showCreateAccountOrLogin = true
    private let showHelp                 = true
    private let showSettings             = true
    
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
            // Build the full list in default order, then filter based on login.
            let defaultItems = allMenuItems()
            let final = filterMenuItems(defaultItems)
            
            reorderManager.loadItems(with: final)
        }
    }
    
    // MARK: - Default Ordered Items
    ///
    /// We only add the item if the corresponding boolean is true.
    /// Then we apply login-based hiding in filterMenuItems().
    private func allMenuItems() -> [MenuItem] {
        var items = [MenuItem]()
        
        // 1. LIVE Matchmaking (logged in only)
        if showLiveMatchmaking {
            items.append(MenuItem(
                title: "LIVE Matchmaking",
                icon: "video.fill",
                color: .purple,
                destination: AnyView(StreamingView())
            ))
        }
        
        // 2. Game Matchmaking (logged in only)
        if showGameMatchmaking {
            items.append(MenuItem(
                title: "Game Matchmaking",
                icon: "gamecontroller.fill",
                color: .blue,
                destination: AnyView(MatchmakingView())
            ))
        }
        
        // 3. Tournaments (logged in only)
        if showTournaments {
            items.append(MenuItem(
                title: "Tournaments",
                icon: "rosette",
                color: .red,
                destination: AnyView(TournamentListView())
            ))
        }
        
        // 4. Achievements (logged in only)
        if showAchievements {
            items.append(MenuItem(
                title: "Achievements",
                icon: "star.fill",
                color: .yellow,
                destination: AnyView(AchievementsView())
            ))
        }
        
        // 5. Leaderboards (logged in only)
        if showLeaderboards {
            items.append(MenuItem(
                title: "Leaderboards",
                icon: "list.number",
                color: .orange,
                destination: AnyView(LeaderboardsView())
            ))
        }
        
        // 6. Agency / Creator Network Review (logged in only)
        if showAgencyCNReview {
            items.append(MenuItem(
                title: "Agency / Creator Network Review",
                icon: "magnifyingglass.circle",
                color: .indigo,
                destination: AnyView(AgencyCNReviewView())
            ))
        }
        
        // 7. Create Account or Log In (not logged in only)
        if showCreateAccountOrLogin {
            items.append(MenuItem(
                title: "Create Account or Log In",
                icon: "person.crop.circle.badge.plus",
                color: .blue,
                destination: AnyView(SignInView(selectedScreen: $selectedScreen))
            ))
        }
        
        // 8. Help (everyone)
        if showHelp {
            items.append(MenuItem(
                title: "Help",
                icon: "questionmark.circle",
                color: .green,
                destination: AnyView(HelpView())
            ))
        }
        
        // 9. Settings (everyone)
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
    
    // MARK: - Filter Items Based on Login State
    ///
    /// After building the default array (minus booleans that are off),
    /// we further hide #1–6 if not logged in, hide #7 if logged in.
    ///
    private func filterMenuItems(_ items: [MenuItem]) -> [MenuItem] {
        var newItems = items
        
        let isLoggedIn = (authManager.user != nil && !authManager.isGuest)
        
        for i in newItems.indices {
            let title = newItems[i].title
            
            switch title {
            case "LIVE Matchmaking",
                 "Game Matchmaking",
                 "Tournaments",
                 "Achievements",
                 "Leaderboards",
                 "Agency / Creator Network Review":
                // Hide if not logged in
                if !isLoggedIn {
                    newItems[i].isHidden = true
                }
            case "Create Account or Log In":
                // Hide if logged in
                if isLoggedIn {
                    newItems[i].isHidden = true
                }
            // "Help" / "Settings" => do nothing
            default:
                break
            }
        }
        
        return newItems
    }
}
