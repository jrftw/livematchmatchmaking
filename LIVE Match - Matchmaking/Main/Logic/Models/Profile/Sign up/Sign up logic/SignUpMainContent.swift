// MARK: SignUpMainContent.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// UI for sign-up. Removed duplicate logic definitions to avoid invalid redeclarations.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

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
    
    @Binding public var confirmPhonePublicly: Bool
    @Binding public var agreedToTerms: Bool
    
    public let defaultAgencies: [String]
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Complete Your Profile")
                    .font(.largeTitle)
                    .padding(.top, 24)
                
                baseFieldsSection()
                
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
                
                socialLinksSection()
                tagsSection()
                
                Toggle("Agree to Terms & Privacy Policy", isOn: $agreedToTerms)
                
                // Call signUpAction() from SignUpLogic.swift extension
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
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage)
            }
        }
        .navigationTitle("Sign Up")
    }
    
    private func baseFieldsSection() -> some View {
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
    
    private func socialLinksSection() -> some View {
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
    
    private func tagsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Tags (at least one required for Solo)").font(.headline)
            Text("Selected Tags: \(selectedTags.joined(separator: ", "))")
        }
    }
}
