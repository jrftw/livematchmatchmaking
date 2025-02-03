//
//  ProfileHomeView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//
//  Fetches the user's MyUserProfile from Firestore (using the provided userID) and displays
//  the real fields instead of any placeholder. If no userID is provided, it shows the logged-in
//  user's profile.
//
//  Dependencies:
//    - MyUserProfile model
//    - AuthManager for current user
//    - Firebase Firestore
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

// MARK: - ProfileHomeViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class ProfileHomeViewModel: ObservableObject {
    @Published var profile: MyUserProfile = MyUserProfile(
        id: nil,
        firstName: "",
        lastName: "",
        displayName: "",
        username: "",
        tags: [],
        socialLinks: [:],
        createdAt: Date()
    )
    @Published var isLoading = true
    @Published var errorMessage: String? = nil
    
    private var userID: String?
    
    init(userID: String? = nil) {
        self.userID = userID
        print("[ProfileHomeViewModel] init called. userID: \(userID ?? "nil")")
        
        fetchProfile()
    }
    
    /// Fetch the MyUserProfile from Firestore using userID, or currentUser if nil.
    private func fetchProfile() {
        let db = Firestore.firestore()
        
        // If no userID passed in, try currentUser
        let finalUserID: String
        if let uid = userID {
            finalUserID = uid
        } else if let currentUID = Auth.auth().currentUser?.uid {
            finalUserID = currentUID
        } else {
            self.errorMessage = "No userID and no current user."
            self.isLoading = false
            return
        }
        
        print("[ProfileHomeViewModel] fetchProfile => userID: \(finalUserID)")
        
        db.collection("users").document(finalUserID).getDocument { docSnap, err in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let err = err {
                    print("[ProfileHomeViewModel] Error => \(err.localizedDescription)")
                    self.errorMessage = err.localizedDescription
                    return
                }
                guard let data = docSnap?.data() else {
                    self.errorMessage = "No profile found for userID \(finalUserID)."
                    return
                }
                
                do {
                    // decode Firestore data to MyUserProfile
                    let decoded = try Firestore.Decoder().decode(MyUserProfile.self, from: data)
                    self.profile = decoded
                    print("[ProfileHomeViewModel] Profile fetched => \(decoded.displayName)")
                    
                    // If docSnap has an ID, set it as well
                    self.profile.id = docSnap?.documentID
                } catch {
                    print("[ProfileHomeViewModel] decode error => \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}

// MARK: - ProfileHomeView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileHomeView: View {
    @StateObject private var vm: ProfileHomeViewModel
    @State private var showingEditSheet = false
    
    // Determine if this is the current user or a different user.
    private var isCurrentUser: Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return uid == vm.profile.id
    }
    
    /// If you have a known userID, pass it in. If nil, we show the current user's profile.
    public init(userID: String? = nil) {
        _vm = StateObject(wrappedValue: ProfileHomeViewModel(userID: userID))
    }
    
    public var body: some View {
        Group {
            if vm.isLoading {
                ProgressView("Loading Profile...")
            } else if let error = vm.errorMessage {
                Text("Error: \(error)").foregroundColor(.red)
            } else {
                profileContent
            }
        }
        .navigationTitle(
            isCurrentUser
            ? "My Profile"
            : vm.profile.displayName.isEmpty ? "Unknown" : "\(vm.profile.displayName)'s Profile"
        )
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(profile: vm.profile)
        }
    }
    
    // MARK: - Profile Content
    private var profileContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                bannerSection()
                headerSection()
                aboutSection()
                tagsSection()
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Banner
    private func bannerSection() -> some View {
        Group {
            if let urlStr = vm.profile.bannerURL,
               !urlStr.isEmpty,
               let remote = URL(string: urlStr) {
                AsyncImage(url: remote) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let img):
                        img.resizable().scaledToFit()
                    case .failure:
                        Color.gray.opacity(0.3)
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(maxHeight: 180)
            } else {
                Color.gray.opacity(0.3).frame(maxHeight: 180)
            }
        }
    }
    
    // MARK: - Header
    private func headerSection() -> some View {
        HStack(spacing: 16) {
            if let pic = vm.profile.profilePictureURL,
               !pic.isEmpty,
               let remote = URL(string: pic) {
                AsyncImage(url: remote) { phase in
                    switch phase {
                    case .empty:
                        Circle().fill(Color.gray.opacity(0.3))
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Circle().fill(Color.gray.opacity(0.3))
                    @unknown default:
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 80, height: 80)
                .clipShape(Circle())
            } else {
                Circle().fill(Color.gray.opacity(0.3))
                    .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(vm.profile.displayName.isEmpty ? "Unknown" : vm.profile.displayName)
                    .font(.headline)
                
                if let clan = vm.profile.clanTag, !clan.isEmpty {
                    Text("Clan: \(clan)").font(.subheadline)
                }
            }
            Spacer()
            
            if isCurrentUser {
                Menu {
                    Button("Edit Profile") {
                        showingEditSheet = true
                    }
                    Button("Share Profile") {
                        // Implementation if needed
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                        .rotationEffect(.degrees(90))
                }
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - About
    private func aboutSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let b = vm.profile.bio, !b.isEmpty {
                Text("Bio: \(b)")
            }
            if vm.profile.birthdayPublicly,
               let bday = vm.profile.birthday, !bday.isEmpty {
                Text("Birthday: \(bday)")
            }
            if vm.profile.emailPublicly,
               let em = vm.profile.email, !em.isEmpty {
                Text("Email: \(em)")
            }
            if vm.profile.phonePublicly,
               let ph = vm.profile.phoneNumber, !ph.isEmpty {
                Text("Phone: \(ph)")
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Tags
    @ViewBuilder
    private func tagsSection() -> some View {
        if !vm.profile.tags.isEmpty {
            VStack(alignment: .leading, spacing: 6) {
                Text("Tags").font(.headline)
                Text(vm.profile.tags.joined(separator: ", "))
                    .font(.subheadline)
            }
            .padding(.vertical, 8)
        }
    }
}
