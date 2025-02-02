//
//  EditProfileView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - EditProfileView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Allows editing of UserProfile fields, including phone/email toggles,
// clan color selection, agencies, networks, teams, communities, live platforms,
// plus profile & banner image uploads to Firebase Storage. Saves to Firestore.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct EditProfileView: View {
    // MARK: - Environment
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    @State private var profile: UserProfile
    @State private var savingInProgress = false
    
    @State private var newProfileImage: UIImage? = nil
    @State private var showingProfilePicker = false
    
    @State private var newBannerImage: UIImage? = nil
    @State private var showingBannerPicker = false
    
    // MARK: - Init
    public init(profile: UserProfile) {
        print("[EditProfileView] init => Initializing with given UserProfile.")
        self._profile = State(initialValue: profile)
    }
    
    // MARK: - Body
    public var body: some View {
        let _ = print("[EditProfileView] body invoked. Building form for profile editing.")
        
        NavigationView {
            Form {
                // Wrap all sections in Groups to avoid 'buildExpression' errors
                Group {
                    profileAndBannerSection()
                    basicInfoSection()
                    clanSection()
                    statsSection()
                }
                
                Group {
                    livePlatformsSection()
                    agenciesSection()
                    networksSection()
                    teamsSection()
                    communitiesSection()
                    tagsSection()
                }
                
                Section {
                    Button("Save Changes") {
                        print("[EditProfileView] 'Save Changes' tapped => saveProfile()")
                        saveProfile()
                    }
                    .disabled(savingInProgress)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(leading: Button("Cancel") {
                print("[EditProfileView] 'Cancel' tapped => dismissing view.")
                dismiss()
            })
            .sheet(isPresented: $showingProfilePicker) {
                // Removed logging for ImagePicker for profile
                ImagePicker(image: $newProfileImage)
            }
            .sheet(isPresented: $showingBannerPicker) {
                // Removed logging for ImagePicker for banner
                ImagePicker(image: $newBannerImage)
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    // MARK: - Profile & Banner Section
    private func profileAndBannerSection() -> some View {
        print("[EditProfileView] Building 'Profile & Banner' section.")
        return Section("Profile & Banner") {
            HStack {
                if let img = newProfileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else if let urlStr = profile.profilePictureURL,
                          let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color.gray.opacity(0.3))
                        case .success(let loaded):
                            loaded.resizable().scaledToFill()
                        case .failure:
                            Circle().fill(Color.gray.opacity(0.3))
                        @unknown default:
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                } else {
                    Circle().fill(Color.gray.opacity(0.3))
                        .frame(width: 70, height: 70)
                }
                Spacer()
                Button("Change Photo") {
                    print("[EditProfileView] 'Change Photo' tapped => showingProfilePicker = true.")
                    showingProfilePicker = true
                }
            }
            
            HStack {
                if let banner = newBannerImage {
                    Image(uiImage: banner)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 60)
                        .cornerRadius(8)
                } else if let urlStr = profile.bannerURL,
                          let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Color.gray.opacity(0.3)
                        case .success(let loaded):
                            loaded.resizable().scaledToFill()
                        case .failure:
                            Color.gray.opacity(0.3)
                        @unknown default:
                            Color.gray.opacity(0.3)
                        }
                    }
                    .frame(height: 60)
                    .cornerRadius(8)
                } else {
                    Color.gray.opacity(0.3)
                        .frame(height: 60)
                        .cornerRadius(8)
                }
                Spacer()
                Button("Change Banner") {
                    print("[EditProfileView] 'Change Banner' tapped => showingBannerPicker = true.")
                    showingBannerPicker = true
                }
            }
        }
    }
    
    // MARK: - Basic Info Section
    private func basicInfoSection() -> some View {
        print("[EditProfileView] Building 'Basic Info' section.")
        return Section("Basic Info") {
            TextField("Username", text: $profile.username)
            TextField("Bio", text: $profile.bio)
            
            TextField("Phone Number", text: bindingFor(\.phone))
            Toggle("Show Phone Publicly", isOn: $profile.phonePublicly)
            
            TextField("Birth Year", text: bindingFor(\.birthYear))
            Toggle("Show Birth Year Publicly", isOn: $profile.birthYearPublicly)
            
            TextField("Email", text: bindingFor(\.email))
            Toggle("Show Email Publicly", isOn: $profile.emailPublicly)
        }
    }
    
    // MARK: - Clan Section
    private func clanSection() -> some View {
        print("[EditProfileView] Building 'Clan' section.")
        return Section("Clan") {
            TextField("Clan Tag", text: bindingFor(\.clanTag))
            ColorPicker("Clan Color", selection: clanColorBinding, supportsOpacity: false)
        }
    }
    
    // MARK: - Stats Section
    private func statsSection() -> some View {
        print("[EditProfileView] Building 'Stats' section.")
        return Section("Stats") {
            Text("Followers: \(profile.followers)")
            Text("Friends: \(profile.friends)")
            Stepper("Wins: \(profile.wins)", value: $profile.wins, in: 0...999999)
            Stepper("Losses: \(profile.losses)", value: $profile.losses, in: 0...999999)
        }
    }
    
    // MARK: - Live Platforms Section
    private func livePlatformsSection() -> some View {
        print("[EditProfileView] Building 'Live Platforms' section.")
        return Section("Live Platforms") {
            if profile.livePlatforms.isEmpty {
                Text("No platforms. Add one below.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(profile.livePlatforms.indices, id: \.self) { idx in
                    VStack(alignment: .leading) {
                        TextField(
                            "Platform name",
                            text: Binding<String>(
                                get: { profile.livePlatforms[idx] },
                                set: { profile.livePlatforms[idx] = $0 }
                            )
                        )
                        TextField(
                            "Platform link",
                            text: Binding<String>(
                                get: {
                                    if profile.livePlatformLinks.indices.contains(idx) {
                                        return profile.livePlatformLinks[idx]
                                    }
                                    return ""
                                },
                                set: {
                                    if profile.livePlatformLinks.indices.contains(idx) {
                                        profile.livePlatformLinks[idx] = $0
                                    }
                                }
                            )
                        )
                    }
                }
                .onDelete { indexSet in
                    for i in indexSet {
                        print("[EditProfileView] Deleting platform at index => \(i).")
                        profile.livePlatforms.remove(at: i)
                        if profile.livePlatformLinks.indices.contains(i) {
                            profile.livePlatformLinks.remove(at: i)
                        }
                    }
                }
            }
            Button("Add Platform") {
                print("[EditProfileView] 'Add Platform' tapped => appending blank entries.")
                profile.livePlatforms.append("")
                profile.livePlatformLinks.append("")
            }
        }
    }
    
    // MARK: - Agencies Section
    private func agenciesSection() -> some View {
        print("[EditProfileView] Building 'Agencies' section.")
        return Section("Agencies") {
            editableStringList($profile.agencies, label: "Agency")
        }
    }
    
    // MARK: - Networks Section
    private func networksSection() -> some View {
        print("[EditProfileView] Building 'Creator Networks' section.")
        return Section("Creator Networks") {
            editableStringList($profile.creatorNetworks, label: "Network")
        }
    }
    
    // MARK: - Teams Section
    private func teamsSection() -> some View {
        print("[EditProfileView] Building 'Teams' section.")
        return Section("Teams") {
            editableStringList($profile.teams, label: "Team")
        }
    }
    
    // MARK: - Communities Section
    private func communitiesSection() -> some View {
        print("[EditProfileView] Building 'Communities' section.")
        return Section("Communities") {
            editableStringList($profile.communities, label: "Community")
        }
    }
    
    // MARK: - Tags Section
    private func tagsSection() -> some View {
        print("[EditProfileView] Building 'Tags' section.")
        return Section("Tags") {
            TextField("Tags (comma separated)", text: Binding<String>(
                get: {
                    profile.tags.joined(separator: ", ")
                },
                set: {
                    let arr = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    profile.tags = arr.filter { !$0.isEmpty }
                }
            ))
        }
    }
    
    // MARK: - Save Profile
    private func saveProfile() {
        print("[EditProfileView] saveProfile called.")
        savingInProgress = true
        
        if let newPic = newProfileImage {
            print("[EditProfileView] Detected new profile image => uploading.")
            uploadImage(newPic, path: "profileImages") { picURL in
                profile.profilePictureURL = picURL
                if let newBanner = newBannerImage {
                    print("[EditProfileView] Detected new banner image => uploading.")
                    uploadImage(newBanner, path: "bannerImages") { bannerURL in
                        profile.bannerURL = bannerURL
                        finalizeSave()
                    }
                } else {
                    finalizeSave()
                }
            }
        } else if let newBanner = newBannerImage {
            print("[EditProfileView] Only new banner image => uploading.")
            uploadImage(newBanner, path: "bannerImages") { bannerURL in
                profile.bannerURL = bannerURL
                finalizeSave()
            }
        } else {
            print("[EditProfileView] No new images => finalizing save.")
            finalizeSave()
        }
    }
    
    // MARK: - Finalize Save
    private func finalizeSave() {
        print("[EditProfileView] finalizeSave called.")
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[EditProfileView] No currentUser UID => aborting save.")
            savingInProgress = false
            dismiss()
            return
        }
        
        let docRef = FirebaseManager.shared.db.collection("users").document(uid)
        do {
            print("[EditProfileView] Attempting docRef.setData(from: profile).")
            try docRef.setData(from: profile, merge: true) { err in
                savingInProgress = false
                if let e = err {
                    print("[EditProfileView] Error saving profile => \(e.localizedDescription)")
                } else {
                    print("[EditProfileView] Profile saved successfully.")
                }
                dismiss()
            }
        } catch {
            print("[EditProfileView] Encoding error => \(error.localizedDescription)")
            savingInProgress = false
            dismiss()
        }
    }
    
    // MARK: - Upload Image
    private func uploadImage(_ image: UIImage, path: String, completion: @escaping (String?) -> Void) {
        print("[EditProfileView] uploadImage called => path: \(path).")
        guard let uid = Auth.auth().currentUser?.uid else {
            print("[EditProfileView] No currentUser UID => returning nil.")
            completion(nil)
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("[EditProfileView] Could not convert UIImage to JPEG => returning nil.")
            completion(nil)
            return
        }
        let storageRef = Storage.storage().reference().child("\(path)/\(uid).jpg")
        print("[EditProfileView] Uploading image data to => \(storageRef).")
        storageRef.putData(data, metadata: nil) { _, error in
            if let e = error {
                print("[EditProfileView] Image upload error => \(e.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, _ in
                    print("[EditProfileView] DownloadURL => \(url?.absoluteString ?? "nil").")
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    // MARK: - KeyPath Bindings
    private func bindingFor(_ keyPath: WritableKeyPath<UserProfile, String?>) -> Binding<String> {
        Binding<String>(
            get: { profile[keyPath: keyPath] ?? "" },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }
    
    // MARK: - Clan Color Binding
    private var clanColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                guard let hex = profile.clanColorHex, let uiColor = UIColor(hex: hex) else { return .blue }
                return Color(uiColor)
            },
            set: { newColor in
                profile.clanColorHex = UIColor(newColor).toHex() ?? "#0000FF"
            }
        )
    }
    
    // MARK: - Editable String List
    private func editableStringList(_ list: Binding<[String]>, label: String) -> some View {
        print("[EditProfileView] Building editable string list for \(label).")
        return VStack(alignment: .leading) {
            if list.wrappedValue.isEmpty {
                Text("No \(label.lowercased())s. Add one below.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(list.wrappedValue.indices, id: \.self) { idx in
                    HStack {
                        TextField(label, text: Binding<String>(
                            get: { list.wrappedValue[idx] },
                            set: { list.wrappedValue[idx] = $0 }
                        ))
                        Spacer()
                        Button(role: .destructive) {
                            print("[EditProfileView] Removing \(label) at index \(idx).")
                            list.wrappedValue.remove(at: idx)
                        } label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            Button("Add \(label)") {
                print("[EditProfileView] Adding new blank \(label).")
                list.wrappedValue.append("")
            }
        }
    }
}

// MARK: - UIColor <-> HEX Bridging
fileprivate extension UIColor {
    convenience init?(hex: String) {
        var string = hex.hasPrefix("#") ? String(hex.dropFirst()) : hex
        if string.count == 3 {
            // Expand shorthand like #ABC -> #AABBCC
            string = string.map { "\($0)\($0)" }.joined()
        }
        guard string.count == 6 else { return nil }
        let scanner = Scanner(string: string)
        var hexNumber: UInt64 = 0
        if scanner.scanHexInt64(&hexNumber) {
            let r = (hexNumber & 0xFF0000) >> 16
            let g = (hexNumber & 0x00FF00) >> 8
            let b = (hexNumber & 0x0000FF)
            self.init(
                red: CGFloat(r) / 255,
                green: CGFloat(g) / 255,
                blue: CGFloat(b) / 255,
                alpha: 1.0
            )
            return
        }
        return nil
    }
    
    func toHex() -> String? {
        var rF: CGFloat = 0, gF: CGFloat = 0, bF: CGFloat = 0, aF: CGFloat = 0
        guard getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else { return nil }
        let r = Int(rF * 255), g = Int(gF * 255), b = Int(bF * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
