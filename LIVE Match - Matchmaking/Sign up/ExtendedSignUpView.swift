// MARK: File 6: ExtendedSignUpView.swift
// MARK: iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Multi-select account types, user-chosen tags, gaming/live platform details, plus old fields.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

public struct ExtendedSignUpView: View {
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var username = ""
    @State private var bio = ""
    @State private var birthday = Date()
    @State private var email = ""
    @State private var phoneNumber = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false
    
    @State private var clanTag = ""
    @State private var clanColor = Color.blue
    
    // Optional older arrays for social links
    @State private var socialLinks: [String] = []
    @State private var newSocialLink = ""
    
    // Tag selection
    let allTags = ["LIVEMatch", "Battle Creator", "Gamer", "Viewer", "Agency", "Creator Network", "Scouter"]
    @State private var selectedTags: Set<String> = []
    
    // Detailed gaming accounts
    @State private var gamingAccounts: [GamingAccountDetail] = []
    @State private var newGamingUsername = ""
    @State private var newGamingTeams: [String] = []
    @State private var newGamingTeamInput = ""
    
    // Detailed live platforms
    @State private var livePlatforms: [LivePlatformDetail] = []
    @State private var newLiveUsername = ""
    @State private var newLiveLink = ""
    @State private var newLiveAgencyOrNetwork: String? = nil
    @State private var newLiveTeams: [String] = []
    @State private var newLiveTeamInput = ""
    
    // Multi-account types
    @State private var selectedTypes: Set<AccountType> = []
    
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var showSubscriptionSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Create An Account")
                        .font(.largeTitle)
                        .padding(.top, 24)
                    
                    // PROFILE IMAGE PICKER
                    Button {
                        showImagePicker = true
                    } label: {
                        if let img = profileImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    Text("Tap to set\nProfile Picture")
                                        .multilineTextAlignment(.center)
                                )
                        }
                    }
                    
                    // BASIC FIELDS
                    TextField("First Name", text: $firstName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Last Name", text: $lastName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField("Username (Platform)", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Check Availability") {
                        checkUsernameAvailability()
                    }
                    
                    TextEditor(text: $bio)
                        .frame(height: 60)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 1))
                    
                    DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Phone Number", text: $phoneNumber)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    SecureField("Confirm Password", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Multi-account types
                    multiAccountSelectionView()
                    
                    TextField("Clan Tag (Optional)", text: $clanTag)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    ColorPicker("Clan Color", selection: $clanColor)
                    
                    // TAGS
                    tagSelectionView()
                    
                    // DETAILED GAMING ACCOUNTS
                    gamingAccountsSection()
                    
                    // DETAILED LIVE PLATFORMS
                    livePlatformsSection()
                    
                    // OPTIONAL OLD SOCIAL LINKS
                    Section {
                        Text("Social Links")
                            .font(.headline)
                        HStack {
                            TextField("Add Social Link", text: $newSocialLink)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Button("Add") {
                                guard !newSocialLink.isEmpty else { return }
                                socialLinks.append(newSocialLink)
                                newSocialLink = ""
                            }
                        }
                        ForEach(socialLinks, id: \.self) { link in
                            Text(link)
                        }
                    }
                    
                    Button("Create Account") {
                        signUpAction()
                    }
                    .font(.headline)
                    .padding(.vertical, 8)
                    .sheet(isPresented: $showSubscriptionSheet) {
                        StoreKitHelperView(accountTypes: Array(selectedTypes)) {
                            finalizeSignUp()
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .alert(isPresented: $showingError) {
                    Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
                }
            }
            .navigationTitle("Sign Up")
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage)
        }
    }
    
    // MARK: multiAccountSelectionView
    private func multiAccountSelectionView() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Account Types").font(.headline)
            ForEach(AccountType.allCases.filter { $0 != .guest }, id: \.self) { type in
                Toggle(isOn: Binding<Bool>(
                    get: { selectedTypes.contains(type) },
                    set: { newValue in
                        if newValue { selectedTypes.insert(type) }
                        else { selectedTypes.remove(type) }
                    })) {
                    if type == .creatornetwork {
                        Text("Creator Network")
                    } else {
                        Text(type.rawValue.capitalized)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: tagSelectionView
    private func tagSelectionView() -> some View {
        VStack(alignment: .leading) {
            Text("Select Tags:")
                .font(.headline)
            ForEach(allTags, id: \.self) { tag in
                Toggle(tag, isOn: Binding<Bool>(
                    get: { selectedTags.contains(tag) },
                    set: { newValue in
                        if newValue { selectedTags.insert(tag) }
                        else { selectedTags.remove(tag) }
                    }
                ))
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: gamingAccountsSection
    private func gamingAccountsSection() -> some View {
        VStack(alignment: .leading) {
            Text("Gaming Accounts").font(.headline)
            
            ForEach(gamingAccounts) { ga in
                VStack(alignment: .leading) {
                    Text("Username: \(ga.username)")
                    if !ga.teamsOrCommunities.isEmpty {
                        Text("Teams/Communities: \(ga.teamsOrCommunities.joined(separator: ", "))")
                    }
                }
                .padding(6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            TextField("Gaming Username (Required)", text: $newGamingUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            HStack {
                TextField("Team/Community", text: $newGamingTeamInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    guard !newGamingTeamInput.isEmpty else { return }
                    newGamingTeams.append(newGamingTeamInput)
                    newGamingTeamInput = ""
                }
            }
            Text("Current: \(newGamingTeams.joined(separator: ", "))")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button("Add Gaming Account") {
                guard !newGamingUsername.isEmpty else {
                    showError("Gaming username is required.")
                    return
                }
                let detail = GamingAccountDetail(
                    id: nil,
                    username: newGamingUsername,
                    teamsOrCommunities: newGamingTeams
                )
                gamingAccounts.append(detail)
                // Reset fields
                newGamingUsername = ""
                newGamingTeams.removeAll()
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: livePlatformsSection
    private func livePlatformsSection() -> some View {
        VStack(alignment: .leading) {
            Text("LIVE Platforms").font(.headline)
            
            ForEach(livePlatforms) { lp in
                VStack(alignment: .leading) {
                    Text("Username: \(lp.username)")
                    Text("Link: \(lp.link)")
                    if let agency = lp.agencyOrCreatorNetwork {
                        Text("Agency/Network: \(agency)")
                    }
                    if !lp.teamsOrCommunities.isEmpty {
                        Text("Teams/Communities: \(lp.teamsOrCommunities.joined(separator: ", "))")
                    }
                }
                .padding(6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            TextField("LIVE Platform Username (Required)", text: $newLiveUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Link to Profile (Required)", text: $newLiveLink)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Picker("Agency or Creator Network?", selection: Binding<String?>(
                get: { newLiveAgencyOrNetwork },
                set: { newValue in newLiveAgencyOrNetwork = newValue }
            )) {
                Text("None").tag(String?.none)
                Text("Agency").tag(String?.some("Agency"))
                Text("Creator Network").tag(String?.some("Creator Network"))
            }
            .pickerStyle(.segmented)
            
            HStack {
                TextField("Team/Community", text: $newLiveTeamInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    guard !newLiveTeamInput.isEmpty else { return }
                    newLiveTeams.append(newLiveTeamInput)
                    newLiveTeamInput = ""
                }
            }
            Text("Current T/C: \(newLiveTeams.joined(separator: ", "))")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            Button("Add LIVE Platform") {
                guard !newLiveUsername.isEmpty, !newLiveLink.isEmpty else {
                    showError("Live platform username and link are required.")
                    return
                }
                let detail = LivePlatformDetail(
                    id: nil,
                    username: newLiveUsername,
                    link: newLiveLink,
                    agencyOrCreatorNetwork: newLiveAgencyOrNetwork,
                    teamsOrCommunities: newLiveTeams
                )
                livePlatforms.append(detail)
                
                // Reset
                newLiveUsername = ""
                newLiveLink = ""
                newLiveAgencyOrNetwork = nil
                newLiveTeams.removeAll()
            }
            .padding(.top, 4)
        }
    }
    
    // MARK: signUpAction
    private func signUpAction() {
        guard password == confirmPassword, !password.isEmpty else {
            showError("Passwords don't match or are empty.")
            return
        }
        if selectedTypes.contains(.team) ||
           selectedTypes.contains(.agency) ||
           selectedTypes.contains(.scouter) {
            showSubscriptionSheet = true
        } else {
            finalizeSignUp()
        }
    }
    
    // MARK: finalizeSignUp
    public func finalizeSignUp() {
        AuthManager.shared.signUp(email: email, password: password) { result in
            switch result {
            case .failure(let err):
                showError(err.localizedDescription)
            case .success:
                uploadProfileImage { urlString in
                    createProfile(profilePicURL: urlString)
                }
            }
        }
    }
    
    // MARK: createProfile
    private func createProfile(profilePicURL: String?) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        
        let totalPrice = selectedTypes.reduce(0.0) { sum, type in
            switch type {
            case .team: return sum + 1
            case .agency: return sum + 5
            case .scouter: return sum + 50
            default: return sum
            }
        }
        
        let mergedName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        let birthYearString = df.string(from: birthday)
        
        let newProfile = UserProfile(
            id: userID,
            accountTypes: Array(selectedTypes),
            email: email,
            name: username.isEmpty ? mergedName : username,
            bio: bio,
            birthYear: birthYearString,
            phone: phoneNumber,
            profilePictureURL: profilePicURL,
            bannerURL: nil, // If you want a banner, add a second image picker
            clanTag: clanTag.isEmpty ? nil : clanTag,
            tags: Array(selectedTags),
            socialLinks: socialLinks,
            gamingAccounts: [],
            livePlatforms: [],
            gamingAccountDetails: gamingAccounts,
            livePlatformDetails: livePlatforms,
            followers: 0,
            friends: 0,
            isSearching: false,
            wins: 0,
            losses: 0,
            roster: [],
            establishedDate: "",
            subscriptionActive: (totalPrice > 0),
            subscriptionPrice: totalPrice,
            createdAt: Date()
        )
        
        do {
            try FirebaseManager.shared.db.collection("users")
                .document(userID)
                .setData(from: newProfile)
        } catch {
            print("Error creating user profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: checkUsernameAvailability
    private func checkUsernameAvailability() {
        guard !username.isEmpty else {
            showError("Username can't be empty.")
            return
        }
        FirebaseManager.shared.db.collection("users")
            .whereField("name", isEqualTo: username)
            .getDocuments { snap, err in
                if let err = err {
                    showError("Error checking username: \(err.localizedDescription)")
                } else if let docs = snap?.documents, !docs.isEmpty {
                    showError("Username '\(username)' is already taken.")
                } else {
                    showError("Username '\(username)' is available.")
                }
            }
    }
    
    // MARK: uploadProfileImage
    private func uploadProfileImage(completion: @escaping (String?) -> Void) {
        guard let image = profileImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let userID = Auth.auth().currentUser?.uid ?? UUID().uuidString
        let storageRef = Storage.storage().reference().child("profileImages/\(userID).jpg")
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    // MARK: showError
    private func showError(_ msg: String) {
        errorMessage = msg
        showingError = true
    }
}
