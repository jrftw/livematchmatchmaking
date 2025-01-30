//
//  SignUpMainContent.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Primary scrollable sign-up form referencing your existing enums/models.
//  Shows category-specific UI (Solo, Community, Business) with brief explanations.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SignUpMainContent: View {
    // MARK: Bound Properties
    @Binding public var firstName: String
    @Binding public var lastName: String
    @Binding public var username: String
    @Binding public var bio: String
    @Binding public var birthday: Date
    @Binding public var email: String
    @Binding public var phoneNumber: String
    @Binding public var password: String
    @Binding public var confirmPassword: String
    
    @Binding public var profileImage: UIImage?
    @Binding public var showImagePicker: Bool
    @Binding public var clanTag: String
    @Binding public var clanColor: Color
    
    @Binding public var mainAccountCategory: MainAccountCategory
    @Binding public var selectedSoloTypes: Set<SoloSubType>
    @Binding public var selectedCommunityTypes: Set<CommunitySubType>
    @Binding public var selectedBusinessTypes: Set<BusinessSubType>
    
    @Binding public var selectedTags: Set<String>
    public let allSoloTags: [String]
    public let allCommunityTags: [String]
    public let allBusinessTags: [String]
    
    @Binding public var socialLinks: [String]
    @Binding public var newSocialLink: String
    
    @Binding public var gamingAccounts: [GamingAccountDetail]
    @Binding public var newGamingUsername: String
    @Binding public var newGamingTeams: [String]
    @Binding public var newGamingTeamInput: String
    
    @Binding public var toggledLivePlatforms: Set<String>
    @Binding public var livePlatformUsernames: [String: String]
    @Binding public var livePlatformLinks: [String: String]
    @Binding public var favoriteCreators: [String: [String]]
    
    @Binding public var agencyOrNetworkPlatforms: Set<String>
    @Binding public var agencyOrNetworkNames: [String: String]
    @Binding public var showingAgencySearch: Bool
    @Binding public var agencySearchText: String
    @Binding public var selectedAgencyName: String
    
    @Binding public var selectedTeamName: String
    @Binding public var selectedCommunityName: String
    
    @Binding public var showingError: Bool
    @Binding public var errorMessage: String
    @Binding public var showSubscriptionSheet: Bool
    
    public let defaultAgencies: [String]
    
    // MARK: Body
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // Title
                Text("Create An Account")
                    .font(.largeTitle)
                    .padding(.top, 24)
                
                // Profile picker
                profilePickerSection()
                
                // Basic fields
                basicFieldsSection()
                
                // Category Picker
                Picker("Main Category", selection: $mainAccountCategory) {
                    Text("Solo").tag(MainAccountCategory.solo)
                    Text("Community").tag(MainAccountCategory.community)
                    Text("Business").tag(MainAccountCategory.business)
                }
                .pickerStyle(.segmented)
                
                // Explanation block
                explanationForCategory()
                
                // Category-Specific UI
                if mainAccountCategory == .solo {
                    VStack(alignment: .leading, spacing: 8) {
                        soloTogglesSectionView()
                        if selectedSoloTypes.contains(.viewer) {
                            viewerSection()
                        }
                        if selectedSoloTypes.contains(.creator) {
                            creatorSection()
                        }
                    }
                } else if mainAccountCategory == .community {
                    communityTogglesSection()
                } else {
                    businessTogglesSection()
                }
                
                // Clan
                clanSection()
                
                // Tags
                tagSectionIfNeeded()
                
                // Gaming
                if shouldShowGamingPlatforms() {
                    gamingAccountsSection()
                }
                
                // Team / Community extension
                teamCommunitySection()
                
                // Social
                socialLinksSection()
                
                // Sign Up Button
                Button("Create Account") {
                    signUpAction()
                }
                .font(.headline)
                .padding(.vertical, 8)
                .sheet(isPresented: $showSubscriptionSheet) {
                    StoreKitHelperView(accountTypes: determineAccountTypes()) {
                        finalizeSignUp()
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
            .sheet(isPresented: $showingAgencySearch) {
                agencyNetworkSearchView()
            }
        }
        .navigationTitle("Sign Up")
    }
}

// MARK: - Private UI Sections
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension SignUpMainContent {
    
    // Explanation text for each category
    private func explanationForCategory() -> some View {
        // Show a short text describing each category
        VStack(alignment: .leading, spacing: 6) {
            switch mainAccountCategory {
            case .solo:
                Text("Solo: For individual users. Choose from Viewer, Creator, or Gamer subtypes.")
                    .font(.subheadline)
            case .community:
                Text("Community: For groups or communities. Organize members, events, and more.")
                    .font(.subheadline)
            case .business:
                Text("Business: For teams, agencies, networks, and scouters with more advanced tools.")
                    .font(.subheadline)
            }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: Profile Picker
    private func profilePickerSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile Picture").font(.headline)
            HStack {
                if let img = profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                }
                Button("Choose Image") {
                    showImagePicker = true
                }
            }
        }
    }
    
    // MARK: Basic Fields
    private func basicFieldsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Bio", text: $bio)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    // MARK: Solo Toggles
    private func soloTogglesSectionView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose Solo Subtypes").font(.headline)
            ForEach(SoloSubType.allCases, id: \.self) { subType in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedSoloTypes.contains(subType) },
                    set: { val in
                        if val {
                            selectedSoloTypes.insert(subType)
                        } else {
                            selectedSoloTypes.remove(subType)
                        }
                    }
                )) {
                    Text(subType.rawValue.capitalized)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: Viewer Section
    private func viewerSection() -> some View {
        ViewerPlatformList(
            platformOptions: [
                "TikTok","Favorited","Mango","LIVE.Me","YouNow",
                "YouTube","Clapper","Fanbase","kick"
            ],
            toggledLivePlatforms: $toggledLivePlatforms,
            livePlatformUsernames: $livePlatformUsernames,
            livePlatformLinks: $livePlatformLinks,
            favoriteCreators: $favoriteCreators
        )
    }
    
    // MARK: Creator Section
    private func creatorSection() -> some View {
        CreatorPlatformList(
            platformOptions: [
                "TikTok","Favorited","Mango","LIVE.Me","YouNow",
                "YouTube","Clapper","Fanbase","kick"
            ],
            toggledLivePlatforms: $toggledLivePlatforms,
            livePlatformUsernames: $livePlatformUsernames,
            livePlatformLinks: $livePlatformLinks,
            agencyOrNetworkPlatforms: $agencyOrNetworkPlatforms,
            agencyOrNetworkNames: $agencyOrNetworkNames,
            selectedAgencyName: $selectedAgencyName,
            showingAgencySearch: $showingAgencySearch
        )
    }
    
    // MARK: Community Toggles
    private func communityTogglesSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose Community Subtypes").font(.headline)
            ForEach(CommunitySubType.allCases, id: \.self) { subType in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedCommunityTypes.contains(subType) },
                    set: { val in
                        if val {
                            selectedCommunityTypes.insert(subType)
                        } else {
                            selectedCommunityTypes.remove(subType)
                        }
                    }
                )) {
                    Text(subType.rawValue.capitalized)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: Business Toggles
    private func businessTogglesSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose Business Subtypes").font(.headline)
            ForEach(BusinessSubType.allCases, id: \.self) { subType in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedBusinessTypes.contains(subType) },
                    set: { val in
                        if val {
                            selectedBusinessTypes.insert(subType)
                        } else {
                            selectedBusinessTypes.remove(subType)
                        }
                    }
                )) {
                    Text(subType.rawValue)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: Clan
    private func clanSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Clan Tag / Color").font(.headline)
            TextField("Clan Tag", text: $clanTag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            ColorPicker("Choose Clan Color", selection: $clanColor)
        }
        .padding(.vertical, 8)
    }
    
    // MARK: Tag Logic
    private var computedRelevantTags: [String] {
        switch mainAccountCategory {
        case .solo:
            return allSoloTags
        case .community:
            return allCommunityTags
        case .business:
            return allBusinessTags
        }
    }
    
    func tagSectionIfNeeded() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose Tags").font(.headline)
            ForEach(computedRelevantTags, id: \.self) { tag in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedTags.contains(tag) },
                    set: { val in
                        if val {
                            selectedTags.insert(tag)
                        } else {
                            selectedTags.remove(tag)
                        }
                    }
                )) {
                    Text(tag)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: Gaming
    private func gamingAccountsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Gaming Accounts").font(.headline)
            
            ForEach(gamingAccounts.indices, id: \.self) { idx in
                VStack(alignment: .leading) {
                    Text("Username: \(gamingAccounts[idx].username)")
                    let teams = gamingAccounts[idx].teamsOrCommunities
                    if !teams.isEmpty {
                        Text("Teams: \(teams.joined(separator: ", "))")
                    }
                }
            }
            
            TextField("Gaming Username", text: $newGamingUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            VStack(alignment: .leading) {
                Text("New Team(s)")
                ForEach(newGamingTeams, id: \.self) { team in
                    Text(team)
                }
                HStack {
                    TextField("Add Team", text: $newGamingTeamInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Add") {
                        let trimmed = newGamingTeamInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        newGamingTeams.append(trimmed)
                        newGamingTeamInput = ""
                    }
                }
            }
            
            Button("Add Gaming Account") {
                guard !newGamingUsername.isEmpty else { return }
                let newAccount = GamingAccountDetail(
                    id: nil,
                    username: newGamingUsername,
                    teamsOrCommunities: newGamingTeams
                )
                gamingAccounts.append(newAccount)
                newGamingUsername = ""
                newGamingTeams.removeAll()
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: Social Links
    private func socialLinksSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Social Links").font(.headline)
            ForEach(socialLinks, id: \.self) { link in
                Text(link)
            }
            HStack {
                TextField("Add Social Link", text: $newSocialLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    let trimmed = newSocialLink.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    socialLinks.append(trimmed)
                    newSocialLink = ""
                }
            }
        }
        .padding(.vertical, 8)
    }
}
