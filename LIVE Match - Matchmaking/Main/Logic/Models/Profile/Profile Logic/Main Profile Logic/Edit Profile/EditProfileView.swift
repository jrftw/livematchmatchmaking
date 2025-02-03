// MARK: EditProfileView.swift

//
//  EditProfileView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//

import SwiftUI
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

#if os(iOS) || os(visionOS)
import UIKit
#endif

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var profile: MyUserProfile
    @State private var savingInProgress = false
    
    @State private var newProfileImage: UIImage? = nil
    @State private var newBannerImage: UIImage? = nil
    @State private var showingProfilePicker = false
    @State private var showingBannerPicker = false
    
    @State private var showFirstNamePublicly = false
    @State private var showLastNamePublicly = false
    
    @State private var showingPasswordChange = false
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    
    // LM Studio sections
    @State private var showingViewerStudio = false
    @State private var showingCreatorStudio = false
    @State private var showingGamerStudio = false
    @State private var showingCommunityStudio = false
    
    // Business Studio sections
    @State private var showingTeamStudio = false
    @State private var showingAgencyCreatorNetworkStudio = false
    
    // Country picker (Location) in alphabetical order
    private let countries = [
        "Canada",
        "China",
        "England",
        "Other",
        "United Kingdom",
        "United States"
    ]
    
    public init(profile: MyUserProfile) {
        self._profile = State(initialValue: profile)
    }
    
    public var body: some View {
        NavigationView {
            Form {
                profileBannerSection()
                basicInfoSection()
                
                Section("Location") {
                    Picker("Select Country", selection: bindingForOptional(\.location)) {
                        ForEach(countries, id: \.self) { c in
                            Text(c).tag(c as String?)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                bioSection()
                birthdaySection()
                emailSection()
                phoneSection()
                
                Section("Availability & TimeZone") {
                    NavigationLink("Configure Availability") {
                        CreatorAvailabilityView()
                    }
                }
                
                passwordSection()
                clanSection()
                tagsSection()
                socialLinksSection()
                
                Section("Wins / Losses") {
                    Stepper("Wins: \(profile.wins)", value: bindingForInt(\.wins), in: 0...9999)
                    Stepper("Losses: \(profile.losses)", value: bindingForInt(\.losses), in: 0...9999)
                }
                
                lmStudioSection()
                businessStudioSection()
                
                Section {
                    Button("Save Changes") {
                        saveProfile()
                    }
                    .disabled(savingInProgress)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .sheet(isPresented: $showingProfilePicker) {
                #if os(iOS) || os(visionOS)
                ImagePicker(image: $newProfileImage)
                #endif
            }
            .sheet(isPresented: $showingBannerPicker) {
                #if os(iOS) || os(visionOS)
                ImagePicker(image: $newBannerImage)
                #endif
            }
            .sheet(isPresented: $showingPasswordChange) {
                passwordChangeSheet()
            }
            .sheet(isPresented: $showingViewerStudio) {
                ViewerStudioView()
            }
            .sheet(isPresented: $showingCreatorStudio) {
                CreatorStudioView()
            }
            .sheet(isPresented: $showingGamerStudio) {
                GamerStudioView()
            }
            .sheet(isPresented: $showingCommunityStudio) {
                CommunityStudioView()
            }
            .sheet(isPresented: $showingTeamStudio) {
                TeamStudioView()
            }
            .sheet(isPresented: $showingAgencyCreatorNetworkStudio) {
                AgencyCreatorNetworkStudioView()
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

// MARK: - Private Subviews
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
private extension EditProfileView {
    func profileBannerSection() -> some View {
        Section("Profile & Banner") {
            HStack {
                if let pImg = newProfileImage {
                    Image(uiImage: pImg)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } else if let urlStr = profile.profilePictureURL,
                          !urlStr.isEmpty,
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
                    showingProfilePicker = true
                }
            }
            
            HStack {
                if let bImg = newBannerImage {
                    Image(uiImage: bImg)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 60)
                        .cornerRadius(8)
                } else if let urlStr = profile.bannerURL,
                          !urlStr.isEmpty,
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
                    showingBannerPicker = true
                }
            }
        }
    }
    
    func basicInfoSection() -> some View {
        Section("Basic Info") {
            TextField("First Name", text: bindingForNonOptional(\.firstName))
            Toggle("Show First Name Publicly", isOn: $showFirstNamePublicly)
            
            TextField("Last Name", text: bindingForNonOptional(\.lastName))
            Toggle("Show Last Name Publicly", isOn: $showLastNamePublicly)
            
            TextField("Display Name", text: bindingForNonOptional(\.displayName))
            
            VStack(alignment: .leading, spacing: 4) {
                TextField("@ Username", text: bindingForNonOptional(\.username))
                Text("Can only change once every 30 days.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            Button("Request Verification") {}
        }
    }
    
    func bioSection() -> some View {
        Section("Bio") {
            TextField("Bio", text: bindingForOptional(\.bio))
        }
    }
    
    func birthdaySection() -> some View {
        Section("Birthday") {
            TextField("Birthday (YYYY-MM-DD)", text: bindingForOptional(\.birthday))
            Toggle("Show Birthday Publicly", isOn: $profile.birthdayPublicly)
        }
    }
    
    func emailSection() -> some View {
        Section("Email") {
            TextField("Email", text: bindingForOptional(\.email))
            Toggle("Show Email Publicly", isOn: $profile.emailPublicly)
        }
    }
    
    func phoneSection() -> some View {
        Section("Phone") {
            TextField("Phone Number", text: bindingForOptional(\.phoneNumber))
            Toggle("Show Phone Publicly", isOn: $profile.phonePublicly)
        }
    }
    
    func passwordSection() -> some View {
        Section("Change Password") {
            Button("Change Password") {
                showingPasswordChange = true
            }
            .disabled(savingInProgress)
        }
    }
    
    func clanSection() -> some View {
        Section("Clan") {
            TextField("Clan Tag", text: bindingForOptional(\.clanTag))
            ColorPicker("Clan Color", selection: clanColorBinding, supportsOpacity: false)
        }
    }
    
    func tagsSection() -> some View {
        Section("Tags") {
            TextField("Tags (comma separated)", text: Binding<String>(
                get: { profile.tags.joined(separator: ", ") },
                set: {
                    let arr = $0.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                    profile.tags = arr.filter { !$0.isEmpty }
                }
            ))
        }
    }
    
    func socialLinksSection() -> some View {
        Section("Social Network Links") {
            ForEach(Array(profile.socialLinks.keys), id: \.self) { key in
                HStack {
                    Text(key)
                    Spacer()
                    Text(profile.socialLinks[key] ?? "")
                        .foregroundColor(.secondary)
                }
            }
            Button("Add Link") {}
        }
    }
    
    func lmStudioSection() -> some View {
        Section("LM Studio") {
            Button("Viewer Section") { showingViewerStudio = true }
            Button("Creator Section") { showingCreatorStudio = true }
            Button("Gamer Section") { showingGamerStudio = true }
            Button("Community Section") { showingCommunityStudio = true }
        }
    }
    
    func businessStudioSection() -> some View {
        Section("Business Studio") {
            Button("Team Section") { showingTeamStudio = true }
            Button("Agency / Creator Network Section") { showingAgencyCreatorNetworkStudio = true }
            Button("Scouter Section (Coming Soon)") {}
            .disabled(true)
        }
    }
}

// MARK: - Save & Password
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
private extension EditProfileView {
    
    func passwordChangeSheet() -> some View {
        NavigationView {
            Form {
                Section(header: Text("Enter New Password")) {
                    SecureField("New Password", text: $newPassword)
                    SecureField("Confirm New Password", text: $confirmNewPassword)
                }
                Section {
                    Button("Update Password") {
                        // Implement actual password change logic
                        showingPasswordChange = false
                    }
                }
            }
            .navigationTitle("Change Password")
            .navigationBarItems(trailing: Button("Done") {
                showingPasswordChange = false
            })
        }
    }
    
    func saveProfile() {
        savingInProgress = true
        
        if let newPic = newProfileImage {
            uploadImage(newPic, path: "profileImages") { url in
                profile.profilePictureURL = url
                if let newBan = newBannerImage {
                    uploadImage(newBan, path: "bannerImages") { bUrl in
                        profile.bannerURL = bUrl
                        finalizeSave()
                    }
                } else {
                    finalizeSave()
                }
            }
        } else if let newBan = newBannerImage {
            uploadImage(newBan, path: "bannerImages") { bUrl in
                profile.bannerURL = bUrl
                finalizeSave()
            }
        } else {
            finalizeSave()
        }
    }
    
    func finalizeSave() {
        guard let uid = Auth.auth().currentUser?.uid else {
            savingInProgress = false
            dismiss()
            return
        }
        let ref = Firestore.firestore().collection("users").document(uid)
        
        do {
            try ref.setData(from: profile, merge: true) { _ in
                savingInProgress = false
                dismiss()
            }
        } catch {
            savingInProgress = false
            dismiss()
        }
    }
    
    func uploadImage(_ image: UIImage, path: String, completion: @escaping (String?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(nil)
            return
        }
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let ref = Storage.storage().reference().child("\(path)/\(uid)_\(UUID().uuidString).jpg")
        ref.putData(data, metadata: nil) { _, error in
            if let error = error {
                print("Error uploading image: \(error.localizedDescription)")
                completion(nil)
            } else {
                ref.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    }
}

// MARK: - Helpers & Bindings
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
private extension EditProfileView {
    
    func bindingForNonOptional(_ keyPath: WritableKeyPath<MyUserProfile, String>) -> Binding<String> {
        Binding<String>(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }
    
    func bindingForOptional(_ keyPath: WritableKeyPath<MyUserProfile, String?>) -> Binding<String> {
        Binding<String>(
            get: { profile[keyPath: keyPath] ?? "" },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }
    
    func bindingForInt(_ keyPath: WritableKeyPath<MyUserProfile, Int>) -> Binding<Int> {
        Binding<Int>(
            get: { profile[keyPath: keyPath] },
            set: { profile[keyPath: keyPath] = $0 }
        )
    }
    
    #if os(iOS) || os(visionOS)
    var clanColorBinding: Binding<Color> {
        Binding<Color>(
            get: {
                guard let hex = profile.clanColorHex else { return .blue }
                return Color(uiColorFromHex(hex) ?? .blue)
            },
            set: { newVal in
                profile.clanColorHex = hexFromColor(newVal)
            }
        )
    }
    
    func uiColorFromHex(_ hex: String) -> UIColor? {
        var h = hex
        if h.hasPrefix("#") { h.removeFirst() }
        if h.count == 3 {
            h = h.map { "\($0)\($0)" }.joined()
        }
        guard h.count == 6 else { return nil }
        
        var num: UInt64 = 0
        let scanner = Scanner(string: h)
        guard scanner.scanHexInt64(&num) else { return nil }
        
        let r = (num & 0xFF0000) >> 16
        let g = (num & 0x00FF00) >> 8
        let b = (num & 0x0000FF)
        
        return UIColor(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
    
    func hexFromColor(_ color: Color) -> String {
        let ui = UIColor(color)
        var rF: CGFloat = 0, gF: CGFloat = 0, bF: CGFloat = 0, aF: CGFloat = 0
        guard ui.getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else { return "#0000FF" }
        
        let r = Int(rF * 255)
        let g = Int(gF * 255)
        let b = Int(bF * 255)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    #else
    var clanColorBinding: Binding<Color> {
        .constant(.blue)
    }
    #endif
}
