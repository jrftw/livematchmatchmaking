//
//  SignUpMainContent.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  The primary sign-up form that displays all relevant fields based on the chosen category and subtypes,
//  including profile/banner upload, clan color, toggles for tags, etc.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - Enums
public enum MainAccountCategory: String, CaseIterable {
    case solo = "Solo"
    case community = "Community"
    case business = "Business"
}

public enum SoloSubType: String, CaseIterable {
    case viewer = "Viewer"
    case creator = "Creator"
    case gamer = "Gamer"
}

public enum CommunitySubType: String, CaseIterable {
    case community = "Community"
    case group = "Group"
}

public enum BusinessSubType: String, CaseIterable {
    case team = "Team"
    case agency = "Agency"
    case creatornetwork = "Creator Network"
    case scouter = "Scout (Coming Soon)"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SignUpMainContent: View {
    // MARK: Bound Base Fields
    @Binding public var firstName: String
    @Binding public var lastName: String
    @Binding public var username: String
    @Binding public var bio: String
    @Binding public var birthday: Date
    @Binding public var email: String
    @Binding public var confirmEmail: String
    @Binding public var phoneNumber: String
    @Binding public var password: String
    @Binding public var confirmPassword: String
    
    // MARK: Profile & Banner
    @Binding public var profileImage: UIImage?
    @Binding public var showImagePicker: Bool
    @State private var bannerImage: UIImage? = nil
    @State private var showBannerPicker = false
    
    // MARK: Clan Tag & Color
    @Binding public var clanTag: String
    @Binding public var clanColor: Color
    
    // MARK: Main Account Category
    @Binding public var mainAccountCategory: MainAccountCategory
    @Binding public var selectedSoloTypes: Set<SoloSubType>
    @Binding public var selectedCommunityTypes: Set<CommunitySubType>
    @Binding public var selectedBusinessTypes: Set<BusinessSubType>
    
    // MARK: Tags
    @Binding public var selectedTags: Set<String>
    public let allSoloTags: [String]
    public let allCommunityTags: [String]
    public let allBusinessTags: [String]
    
    // MARK: Social
    @Binding public var socialLinks: [String]
    @Binding public var newSocialLink: String
    
    // MARK: Gaming
    @Binding public var gamingAccounts: [GamingAccountDetail]
    @Binding public var newGamingUsername: String
    @Binding public var newGamingTeams: [String]
    @Binding public var newGamingTeamInput: String
    
    // MARK: LIVE Platforms
    @Binding public var toggledLivePlatforms: Set<String>
    @Binding public var livePlatformUsernames: [String: String]
    @Binding public var livePlatformLinks: [String: String]
    @Binding public var favoriteCreators: [String: [String]]
    
    // MARK: Agency / Network
    @Binding public var agencyOrNetworkPlatforms: Set<String>
    @Binding public var agencyOrNetworkNames: [String: String]
    @Binding public var showingAgencySearch: Bool
    @Binding public var agencySearchText: String
    @Binding public var selectedAgencyName: String
    
    // MARK: Team / Community
    @Binding public var selectedTeamName: String
    @Binding public var selectedCommunityName: String
    
    // MARK: Error, Subscription, Terms
    @Binding public var showingError: Bool
    @Binding public var errorMessage: String
    @Binding public var showSubscriptionSheet: Bool
    
    @Binding public var confirmPhonePublicly: Bool
    @Binding public var agreedToTerms: Bool
    
    public let defaultAgencies: [String]
    
    // MARK: Predefined Hashtag Toggles
    private let predefinedTags: [String] = [
        "#LIVEMatch", "#BattleCreator", "#Gamer",
        "#Viewer", "#Agency", "#CreatorNetwork", "#Gifter"
    ]
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                
                // MARK: Profile & Banner at the top
                profileBannerSection()
                
                // MARK: Clan Color
                clanColorSection()
                
                // MARK: Base Fields
                baseFieldsSection()
                
                // MARK: Category & Subtype UI
                if mainAccountCategory == .solo {
                    SoloTogglesSectionView(
                        allSoloTypes: SoloSubType.allCases,
                        selectedSoloTypes: $selectedSoloTypes
                    )
                    if selectedSoloTypes.contains(.viewer) {
                        viewerLivePlatformSection()
                    }
                    if selectedSoloTypes.contains(.creator) {
                        creatorLivePlatformSection()
                    }
                    if selectedSoloTypes.contains(.gamer) {
                        gamerSectionView()
                    }
                    teamCommunitySection()
                }
                else if mainAccountCategory == .community {
                    CommunityTogglesSectionView(
                        allCommunityTypes: CommunitySubType.allCases,
                        selectedCommunityTypes: $selectedCommunityTypes
                    )
                    communityGroupCreationSection()
                }
                else if mainAccountCategory == .business {
                    BusinessTogglesSectionView(
                        allBusinessTypes: BusinessSubType.allCases,
                        selectedBusinessTypes: $selectedBusinessTypes
                    )
                    businessSection()
                }
                
                // MARK: Social & Hashtag Toggles
                socialLinksSection()
                hashtagsToggleSection()
                
                // MARK: Terms
                Toggle("Agree to Terms & Privacy Policy", isOn: $agreedToTerms)
                
                // MARK: Create Account
                Button("Create Account") {
                    signUpAction()
                }
                .font(.headline)
                .padding(.vertical, 8)
            }
            .padding()
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            // Profile Image
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
            // Banner Image
            .sheet(isPresented: $showBannerPicker) {
                ImagePicker(image: $bannerImage)
            }
        }
        .navigationTitle("Sign Up")
    }
}

// MARK: - Private UI Sections
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
private extension SignUpMainContent {
    
    // MARK: Profile & Banner
    func profileBannerSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Profile & Banner Images").font(.headline)
            
            // Profile
            HStack {
                if let img = profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                }
                Button("Select Profile Image") {
                    showImagePicker = true
                }
            }
            
            // Banner
            HStack {
                if let banner = bannerImage {
                    Image(uiImage: banner)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 80)
                }
                Button("Select Banner Image") {
                    showBannerPicker = true
                }
            }
        }
    }
    
    // MARK: Clan Color
    func clanColorSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Clan Color (Optional)").font(.headline)
            ColorPicker("Select Clan Color", selection: $clanColor, supportsOpacity: false)
                .padding(.top, 2)
        }
    }
    
    // MARK: Base Fields
    func baseFieldsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("First Name", text: $firstName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Last Name", text: $lastName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Username (lowercase)", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Bio", text: $bio)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Confirm Email", text: $confirmEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Clan Tag (optional)", text: $clanTag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    // MARK: Social
    func socialLinksSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Social Links").font(.headline)
            ForEach(socialLinks, id: \.self) { link in
                Text(link)
            }
            HStack {
                TextField("Add new social link", text: $newSocialLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    let trimmed = newSocialLink.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    socialLinks.append(trimmed)
                    newSocialLink = ""
                }
            }
        }
    }
    
    // MARK: Hashtags Toggle Section
    func hashtagsToggleSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags (at least one required for Solo)").font(.headline)
            // Predefined tag toggles
            ForEach(predefinedTags, id: \.self) { hash in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedTags.contains(hash) },
                    set: { val in
                        if val {
                            selectedTags.insert(hash)
                        } else {
                            selectedTags.remove(hash)
                        }
                    }
                )) {
                    Text(hash)
                }
            }
            
            // If you want to confirm which tags are selected
            if !selectedTags.isEmpty {
                Text("Selected: \(selectedTags.joined(separator: ", "))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("None selected yet.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
