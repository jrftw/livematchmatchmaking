//
//  SignUpView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Base container showing category selection, then navigates to SignUpMainContent.
//
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
    case scouter = "Scouter"
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct SignUpView: View {
    // MARK: - State Properties
    @State private var showSignUpMain = false
    
    @State var firstName = ""
    @State var lastName = ""
    @State var username = ""
    @State var bio = ""
    @State var birthday = Date()
    @State var email = ""
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
    let allSoloTags = ["#LIVEMatch", "#BattleCreator", "#Gamer", "#Viewer", "#Agency", "#CreatorNetwork", "#Gifter"]
    let allCommunityTags = ["#Community", "#Group", "#Viewer", "#Agency", "#CreatorNetwork", "#Gifter"]
    let allBusinessTags = ["#LIVEMatch", "#BattleCreator", "#Gamer", "#Viewer", "#Agency", "#CreatorNetwork", "#Gifter", "#Business"]
    
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
    
    let defaultAgencies: [String] = [
        "AFM Agency","Agence Purty","Alta Talent","Amplify TalentRX_US (ATRX)",
        "Avenue of Stars_US","Avery_US","Bandalabs_US","Bang Productions Television_US",
        "BavaMedia_US","BEE Social","Block","Blue Shift Creative_US","Buzz Social_US","Carnival_US",
        "Carter Pulse_US","Cataleya Media","CreatorREV_US","Diamond Leauge Agency","Diffraction_US",
        "Digital Star","Dream Social","Elev8 Agency","Era_US","Esque_US","Famfluence Talent Management_US",
        "Forest Dream Oriental Studios INC_US","FTTV_US","Galactic LIGHT_US","Galictic light","Global Variety",
        "GravitasQ","GravitasQ_UK","Greenwood mcn_US","High Up Agency_US","Hota_US","Hypernova Digital Entertainment LLC_US",
        "iLIVE Agency","Infinitum_US","Influential Talent Agency_US","JAAAH Media","JOY MEDIA_US","JSI Global","Kabootar",
        "L.O.E The Agency","LB STAR_US","LB_US","Levalz_UK+","Lion King Amusement","LiveVibes_US","Livewave INC_US","mago",
        "Mango King Entertainment","MARS","Mega Star_US","MF_US","Mirrorcle","Moxy Management","Mystik Live Creator Network",
        "New Beginnings Creator Network_US","NewStar_US","Notorious Agency","Nova Media","NY Generation","ONW","Ordient Entertainment",
        "OS International Inc_US","Perfect Society","PIER.E_MEDIA","Prime Picks","Quantum Agency","Rain_US",
        "Recapture Live Stream_US","Rezarved","Rockstars Agency_US","RoyaltyTalent_US","Shine","SHINING_US","Sky Dweller Agency_US",
        "skyywave","SPARK OLOGY_US","SparkAgency","Starlight Dreamworks","StarSync Collective","Superfun_US","Swave Social Talent_US",
        "TABOOST","Talenture Agency_US","TCE_US","TELEPATHY LIVE","Teleport","Tenacity_US","The Brigade","The Shark Tank",
        "The Vault Creator Agency_US","Thundrr_US","Timeless Legacy Agency","TIMES INFINITY_US","TTM_Agency_US","UGO",
        "ugo.media_us","Unicorn Media","Uprise Talent","Velez Managment Services LLC dba Diamond Creator Agency_US","Vibra Check Media_US",
        "Visionaries","We live LIVE","WOL LIVE","WWR Media_US","Zonic_US"
    ].sorted()
    
    public init() {}
    
    // MARK: - Body
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Choose Account Category")
                    .font(.title2)
                
                // Category Picker
                Picker("Category", selection: $mainAccountCategory) {
                    Text("Solo").tag(MainAccountCategory.solo)
                    Text("Community").tag(MainAccountCategory.community)
                    Text("Business").tag(MainAccountCategory.business)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Explanation text about categories
                VStack(alignment: .leading, spacing: 8) {
                    switch mainAccountCategory {
                    case .solo:
                        Text("A Solo account is for individuals. You can select subtypes like Viewer, Creator, or Gamer.")
                            .font(.subheadline)
                    case .community:
                        Text("A Community account is for groups or communities to organize members and events.")
                            .font(.subheadline)
                    case .business:
                        Text("A Business account is for teams, agencies, or scouters requiring advanced tools.")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal, 16)
                
                // NavigationLink to go to SignUpMainContent
                NavigationLink(
                    destination: SignUpMainContent(
                        firstName: $firstName,
                        lastName: $lastName,
                        username: $username,
                        bio: $bio,
                        birthday: $birthday,
                        email: $email,
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
                        defaultAgencies: defaultAgencies
                    ),
                    isActive: $showSignUpMain
                ) {
                    EmptyView()
                }
                .hidden()
                
                // Continue Button triggers the navigation
                Button("Continue") {
                    showSignUpMain = true
                }
                .padding()
            }
            .navigationTitle("Sign Up")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
