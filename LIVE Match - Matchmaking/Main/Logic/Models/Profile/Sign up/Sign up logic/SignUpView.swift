//
//  SignUpView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - SignUpView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Entry point to choose account category (Solo, Community, Business), then open main sign-up.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SignUpView: View {
    
    // MARK: - Vars
    @State var showSignUpMain = false
    
    @State var firstName = ""
    @State var lastName = ""
    @State var username = ""
    @State var bio = ""
    @State var birthday = Date()
    @State var email = ""
    @State var confirmEmail = ""
    @State var phoneNumber = ""
    @State var password = ""
    @State var confirmPassword = ""
    
    @State var profileImage: UIImage? = nil
    @State var showImagePicker = false
    @State var clanTag = ""
    @State var clanColor = Color.blue
    
    @State var mainAccountCategory: MainAccountCategory = .solo
    @State var selectedSoloTypes: Set<SoloSubType> = []
    @State var selectedCommunityTypes: Set<CommunitySubType> = []
    @State var selectedBusinessTypes: Set<BusinessSubType> = []
    
    @State var selectedTags: Set<String> = []
    let allSoloTags: [String] = []
    let allCommunityTags: [String] = []
    let allBusinessTags: [String] = []
    
    @State var socialLinks: [String] = []
    @State var newSocialLink = ""
    
    @State var gamingAccounts: [GamingAccountDetail] = []
    @State var newGamingUsername = ""
    @State var newGamingTeams: [String] = []
    @State var newGamingTeamInput = ""
    
    @State var toggledLivePlatforms: Set<String> = []
    @State var livePlatformUsernames: [String: String] = [:]
    @State var livePlatformLinks: [String: String] = [:]
    @State var favoriteCreators: [String: [String]] = [:]
    
    @State var agencyOrNetworkPlatforms: Set<String> = []
    @State var agencyOrNetworkNames: [String: String] = [:]
    @State var showingAgencySearch = false
    @State var agencySearchText = ""
    @State var selectedAgencyName = ""
    
    @State var selectedTeamName = ""
    @State var selectedCommunityName = ""
    
    @State var showingError = false
    @State var errorMessage = ""
    @State var showSubscriptionSheet = false
    
    @State var confirmPhonePublicly = false
    @State var agreedToTerms = false
    
    let defaultAgencies: [String] = []
    
    public init() {}
    
    // MARK: - Body
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Account Category")
                    .font(.title2)
                
                Picker("Category", selection: $mainAccountCategory) {
                    Text("Solo").tag(MainAccountCategory.solo)
                    Text("Community").tag(MainAccountCategory.community)
                    Text("Business").tag(MainAccountCategory.business)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    switch mainAccountCategory {
                    case .solo:
                        Text("A Solo account is for individuals. You can select subtypes like Viewer, Creator, or Gamer.")
                            .font(.subheadline)
                    case .community:
                        Text("A Community account is for groups or communities to organize members and events.")
                            .font(.subheadline)
                    case .business:
                        Text("A Business account is for teams, agencies, or networks requiring advanced tools.")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 16)
                
                NavigationLink(
                    destination: SignUpMainContent(
                        firstName: $firstName,
                        lastName: $lastName,
                        username: $username,
                        bio: $bio,
                        birthday: $birthday,
                        email: $email,
                        confirmEmail: $confirmEmail,
                        phoneNumber: $phoneNumber,
                        password: $password,
                        confirmPassword: $confirmPassword,
                        profileImage: $profileImage,
                        showImagePicker: $showImagePicker,
                        clanTag: $clanTag,
                        clanColor: $clanColor,
                        mainAccountCategory: $mainAccountCategory,
                        selectedSoloTypes: $selectedSoloTypes,
                        selectedCommunityTypes: $selectedCommunityTypes,
                        selectedBusinessTypes: $selectedBusinessTypes,
                        selectedTags: $selectedTags,
                        allSoloTags: allSoloTags,
                        allCommunityTags: allCommunityTags,
                        allBusinessTags: allBusinessTags,
                        socialLinks: $socialLinks,
                        newSocialLink: $newSocialLink,
                        gamingAccounts: $gamingAccounts,
                        newGamingUsername: $newGamingUsername,
                        newGamingTeams: $newGamingTeams,
                        newGamingTeamInput: $newGamingTeamInput,
                        toggledLivePlatforms: $toggledLivePlatforms,
                        livePlatformUsernames: $livePlatformUsernames,
                        livePlatformLinks: $livePlatformLinks,
                        favoriteCreators: $favoriteCreators,
                        agencyOrNetworkPlatforms: $agencyOrNetworkPlatforms,
                        agencyOrNetworkNames: $agencyOrNetworkNames,
                        showingAgencySearch: $showingAgencySearch,
                        agencySearchText: $agencySearchText,
                        selectedAgencyName: $selectedAgencyName,
                        selectedTeamName: $selectedTeamName,
                        selectedCommunityName: $selectedCommunityName,
                        showingError: $showingError,
                        errorMessage: $errorMessage,
                        showSubscriptionSheet: $showSubscriptionSheet,
                        confirmPhonePublicly: $confirmPhonePublicly,
                        agreedToTerms: $agreedToTerms,
                        defaultAgencies: defaultAgencies
                    ),
                    isActive: $showSignUpMain
                ) {
                    EmptyView()
                }
                .hidden()
                
                Button("Continue") {
                    showSignUpMain = true
                }
                .padding()
            }
            .navigationTitle("Sign Up")
            .alert(isPresented: $showingError) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
