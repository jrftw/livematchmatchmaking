// MARK: - UniversalSignUpView.swift
// A universal sign up flow that automatically directs the user to .profile after account creation.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

#if os(iOS) || os(visionOS)
import UIKit
#endif

fileprivate let blockedWords: [String] = [
    "fuck","shit","bitch","asshole","dick","cunt","faggot","nigger","whore"
]

fileprivate func containsBadWords(_ text: String) -> Bool {
    let lower = text.lowercased()
    for word in blockedWords {
        if lower.contains(word) {
            return true
        }
    }
    return false
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct UniversalSignUpView: View {
    // MARK: - Environment / Binding
    @Environment(\.dismiss) private var dismiss
    #if os(iOS) || os(visionOS)
    @Environment(\.presentationMode) private var presentationMode
    #endif
    
    @Binding var selectedScreen: MainScreen  // Binds to your main menu or tab selection
    
    // MARK: - State: Images
    @State private var profileImage: UIImage? = nil
    @State private var bannerImage: UIImage? = nil
    @State private var showingProfilePicker = false
    @State private var showingBannerPicker = false
    
    // MARK: - State: Basic Info
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var displayName: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    
    // MARK: - Birthday
    @State private var birthday = Date()
    @State private var showBirthdayPublicly = false
    
    // MARK: - Email
    @State private var email: String = ""
    @State private var confirmEmail: String = ""
    @State private var showEmailPublicly = false
    
    // MARK: - Phone
    @State private var phoneNumber: String = ""
    @State private var confirmPhone: String = ""
    @State private var showPhonePublicly = false
    
    // MARK: - Password
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // MARK: - Clan
    @State private var clanTag: String = ""
    @State private var clanColor: Color = .blue
    
    // MARK: - Tags
    private let defaultTags: [String] = [
        "#LIVEMatch", "#BattleCreator", "#Gamer",
        "#Agency", "#CreatorNetwork", "#Gifter"
    ]
    @State private var selectedTags: [String] = []
    @State private var newTag: String = ""
    
    // MARK: - Social
    @State private var socialLinks: [String: String] = [:]
    @State private var newSocialPlatform: String = ""
    @State private var newSocialLink: String = ""
    
    // MARK: - Terms
    @State private var agreedToTerms = false
    
    // MARK: - Activity
    @State private var isCreatingAccount = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    // MARK: - Init
    public init(selectedScreen: Binding<MainScreen>) {
        self._selectedScreen = selectedScreen
    }
    
    // MARK: - Body
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    profileBannerSection()
                    basicFieldsSection()
                    emailPhoneSection()
                    passwordSection()
                    clanSection()
                    tagsSection()
                    socialLinksSection()
                    
                    Toggle("Agree To Terms & Privacy Policy", isOn: $agreedToTerms)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(.horizontal)
                    
                    Button(action: {
                        createAccountAction()
                    }) {
                        Text("Create Account")
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isCreatingAccount ? Color.gray : Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(isCreatingAccount)
                    .padding(.horizontal)
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Sign Up")
            .alert(isPresented: $showingErrorAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(errorMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $showingProfilePicker) {
                #if os(iOS) || os(visionOS)
                ImagePicker(image: $profileImage)
                #endif
            }
            .sheet(isPresented: $showingBannerPicker) {
                #if os(iOS) || os(visionOS)
                ImagePicker(image: $bannerImage)
                #endif
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

// MARK: - Subviews
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension UniversalSignUpView {
    private func profileBannerSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Profile & Banner Images")
                .font(.title3)
                .fontWeight(.semibold)
            
            HStack(spacing: 16) {
                if let img = profileImage {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 80, height: 80)
                }
                Button("Select Profile Image") {
                    showingProfilePicker = true
                }
                .buttonStyle(.bordered)
            }
            
            HStack(spacing: 16) {
                if let bImg = bannerImage {
                    Image(uiImage: bImg)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                        .cornerRadius(8)
                        .shadow(radius: 4)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 80)
                        .cornerRadius(8)
                }
                Button("Select Banner Image") {
                    showingBannerPicker = true
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 3)
        .padding(.horizontal)
    }
    
    private func basicFieldsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Basic Info")
                .font(.title3)
                .fontWeight(.semibold)
            
            Group {
                TextField("First Name", text: $firstName)
                TextField("Last Name", text: $lastName)
                TextField("Display Name", text: $displayName)
                VStack(alignment: .leading, spacing: 4) {
                    TextField("@ Username", text: $username)
                    Text("No profanity. Must be unique.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                TextField("Bio", text: $bio)
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            VStack(alignment: .leading, spacing: 4) {
                Toggle("Show Birthday Publicly?", isOn: $showBirthdayPublicly)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                DatePicker("Birthday", selection: $birthday, displayedComponents: .date)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 3)
        .padding(.horizontal)
    }
    
    private func emailPhoneSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Email & Phone")
                .font(.title3)
                .fontWeight(.semibold)
            
            Group {
                TextField("Email", text: $email)
                TextField("Confirm Email", text: $confirmEmail)
                Toggle("Show Email Publicly?", isOn: $showEmailPublicly)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
                
                Divider().padding(.vertical, 4)
                
                TextField("Phone Number", text: $phoneNumber)
                TextField("Confirm Phone Number", text: $confirmPhone)
                Toggle("Show Phone Publicly?", isOn: $showPhonePublicly)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 3)
        .padding(.horizontal)
    }
    
    private func passwordSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Password")
                .font(.title3)
                .fontWeight(.semibold)
            
            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 3)
        .padding(.horizontal)
    }
    
    private func clanSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Clan (Optional)")
                .font(.title3)
                .fontWeight(.semibold)
            
            TextField("Clan Tag", text: $clanTag)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            ColorPicker("Clan Tag Color", selection: $clanColor, supportsOpacity: false)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 3)
        .padding(.horizontal)
    }
    
    private func tagsSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags (Optional, Max 5)")
                .font(.title3)
                .fontWeight(.semibold)
            
            // Default tags with toggles
            ForEach(defaultTags, id: \.self) { tag in
                Toggle(tag, isOn: Binding<Bool>(
                    get: { selectedTags.contains(tag) },
                    set: { val in
                        if val && selectedTags.count < 5 {
                            selectedTags.append(tag)
                        } else {
                            selectedTags.removeAll(where: { $0 == tag })
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            if !selectedTags.isEmpty {
                Text("Selected: \(selectedTags.joined(separator: ", "))")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            
            // Add custom
            HStack {
                TextField("Add custom tag", text: $newTag)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    let trim = newTag.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trim.isEmpty,
                          !containsBadWords(trim),
                          !selectedTags.contains(trim),
                          selectedTags.count < 5 else { return }
                    selectedTags.append(trim)
                    newTag = ""
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 3)
        .padding(.horizontal)
    }
    
    private func socialLinksSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Social Links (Optional)")
                .font(.title3)
                .fontWeight(.semibold)
            
            if !socialLinks.isEmpty {
                ForEach(Array(socialLinks.keys), id: \.self) { key in
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(key): \(socialLinks[key] ?? "")")
                            .font(.subheadline)
                        
                        Button(role: .destructive) {
                            socialLinks.removeValue(forKey: key)
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove")
                            }
                            .foregroundColor(.red)
                        }
                    }
                    Divider()
                }
            }
            
            HStack {
                TextField("Platform", text: $newSocialPlatform)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Link/URL", text: $newSocialLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Add") {
                    let p = newSocialPlatform.trimmingCharacters(in: .whitespacesAndNewlines)
                    let l = newSocialLink.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !p.isEmpty, !l.isEmpty else { return }
                    socialLinks[p] = l
                    newSocialPlatform = ""
                    newSocialLink = ""
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .shadow(radius: 3)
        .padding(.horizontal)
    }
}

// MARK: - Create & Save Logic
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension UniversalSignUpView {
    
    private func createAccountAction() {
        guard !isCreatingAccount else { return }
        
        let cleanUser = username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Basic validations
        if firstName.isEmpty || lastName.isEmpty || displayName.isEmpty || cleanUser.isEmpty {
            showError("Please fill in all required fields.")
            return
        }
        if containsBadWords(cleanUser) || containsBadWords(displayName) || containsBadWords(clanTag) {
            showError("Remove profanity from username, display name, or clan tag.")
            return
        }
        if (!email.isEmpty || !confirmEmail.isEmpty),
           email.lowercased() != confirmEmail.lowercased() {
            showError("Emails do not match.")
            return
        }
        if (!phoneNumber.isEmpty || !confirmPhone.isEmpty),
           phoneNumber != confirmPhone {
            showError("Phone numbers do not match.")
            return
        }
        if password.isEmpty || confirmPassword.isEmpty {
            showError("Password and Confirm Password are required.")
            return
        }
        if password != confirmPassword {
            showError("Passwords do not match.")
            return
        }
        if !agreedToTerms {
            showError("Must agree to Terms & Privacy Policy.")
            return
        }
        
        // Start creating
        isCreatingAccount = true
        checkUsernameAvailability(cleanUser) { available in
            if !available {
                showError("Username is taken or invalid.")
                isCreatingAccount = false
                return
            }
            createFirebaseUser(
                email: email.isEmpty ? "\(UUID().uuidString)@placeholder.com" : email,
                password: password
            ) { success in
                if !success {
                    isCreatingAccount = false
                    return
                }
                uploadImagesThenSaveProfile(cleanUser)
            }
        }
    }
    
    private func checkUsernameAvailability(_ name: String, completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.db.collection("users")
            .whereField("username", isEqualTo: name)
            .getDocuments { snap, err in
                if let _ = err {
                    completion(false)
                    return
                }
                if let docs = snap?.documents, !docs.isEmpty {
                    completion(false)
                } else {
                    completion(true)
                }
            }
    }
    
    private func createFirebaseUser(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { _, error in
            if let e = error {
                showError("Create user error: \(e.localizedDescription)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    private func uploadImagesThenSaveProfile(_ cleanUser: String) {
        let group = DispatchGroup()
        var pURL: String? = nil
        var bURL: String? = nil
        
        if let pImg = profileImage {
            group.enter()
            uploadImage(pImg, "profileImages") { url in
                pURL = url
                group.leave()
            }
        }
        if let bImg = bannerImage {
            group.enter()
            uploadImage(bImg, "bannerImages") { url in
                bURL = url
                group.leave()
            }
        }
        group.notify(queue: .main) {
            saveProfile(cleanUser, pURL, bURL)
        }
    }
    
    private func uploadImage(_ image: UIImage, _ path: String, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let uid = Auth.auth().currentUser?.uid ?? UUID().uuidString
        let ref = Storage.storage().reference().child("\(path)/\(uid)_\(UUID().uuidString).jpg")
        
        ref.putData(data, metadata: nil) { _, err in
            if let e = err {
                showError("Image upload error: \(e.localizedDescription)")
                completion(nil)
            } else {
                ref.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    private func saveProfile(_ cleanUser: String, _ profileURL: String?, _ bannerURL: String?) {
        guard let uid = Auth.auth().currentUser?.uid else {
            showError("Failed to retrieve current user.")
            isCreatingAccount = false
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let birthString = dateFormatter.string(from: birthday)
        
        let clanHex = colorToHex(clanColor)
        
        let newProfile = MyUserProfile(
            id: uid,
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            lastName: lastName.trimmingCharacters(in: .whitespacesAndNewlines),
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            username: cleanUser,
            bio: bio.isEmpty ? nil : bio,
            birthday: birthString,
            birthdayPublicly: showBirthdayPublicly,
            email: email.isEmpty ? nil : email,
            emailPublicly: showEmailPublicly,
            phoneNumber: phoneNumber.isEmpty ? nil : phoneNumber,
            phonePublicly: showPhonePublicly,
            clanTag: clanTag.isEmpty ? nil : clanTag,
            clanColorHex: clanHex,
            tags: selectedTags,
            socialLinks: socialLinks,
            profilePictureURL: profileURL,
            bannerURL: bannerURL,
            createdAt: Date()
        )
        
        do {
            try FirebaseManager.shared.db
                .collection("users")
                .document(uid)
                .setData(from: newProfile) { err in
                    if let e = err {
                        showError(e.localizedDescription)
                    } else {
                        // Automatically switch to Profile tab on success
                        self.selectedScreen = .profile
                        
                        #if os(iOS) || os(visionOS)
                        presentationMode.wrappedValue.dismiss()
                        #else
                        dismiss()
                        #endif
                    }
                    isCreatingAccount = false
                }
        } catch {
            showError("Failed to encode profile: \(error.localizedDescription)")
            isCreatingAccount = false
        }
    }
    
    private func colorToHex(_ color: Color) -> String {
        #if os(iOS) || os(visionOS)
        let uiColor = UIColor(color)
        var rF: CGFloat = 0
        var gF: CGFloat = 0
        var bF: CGFloat = 0
        var aF: CGFloat = 0
        guard uiColor.getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else {
            return "#0000FF"
        }
        let r = Int(rF * 255)
        let g = Int(gF * 255)
        let b = Int(bF * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
        #else
        return "#0000FF"
        #endif
    }
    
    private func showError(_ msg: String) {
        errorMessage = msg
        showingErrorAlert = true
    }
}
