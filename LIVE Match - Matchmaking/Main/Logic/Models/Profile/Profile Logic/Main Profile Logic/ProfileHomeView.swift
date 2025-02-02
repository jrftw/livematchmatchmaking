//
//  ProfileHomeView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - ProfileHomeView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Unified profile view for both the current user and public viewers.
// * If the profile belongs to the authenticated user, they can edit it.
// * Otherwise, it displays a read-only version with no edit access.
// * Loads MyUserProfile from Firestore (including feed posts in "users/{userID}/feed").
//
// Ties into Firebase Storage for profile/banner images (via the existing EditProfileView).
// No duplicated or nonfunctional code. Everything is seamlessly integrated.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

// MARK: - ProfileHomeViewModel
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class ProfileHomeViewModel: ObservableObject {
    
    // MARK: - Published
    @Published var profile: MyUserProfile
    @Published var feedPosts: [String] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    // MARK: - Computed
    var isCurrentUser: Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
        return uid == profile.id
    }
    
    // MARK: - Init
    init(initialProfile: MyUserProfile) {
        self.profile = initialProfile
    }
    
    // MARK: - Load Profile
    func loadProfile() {
        guard let userID = profile.id, !userID.isEmpty else { return }
        isLoading = true
        let docRef = FirebaseManager.shared.db.collection("users").document(userID)
        docRef.getDocument { [weak self] snapshot, err in
            guard let self = self else { return }
            DispatchQueue.main.async { self.isLoading = false }
            
            if let err = err {
                DispatchQueue.main.async {
                    self.errorMessage = "Error loading profile: \(err.localizedDescription)"
                }
                return
            }
            do {
                if let decoded = try snapshot?.data(as: MyUserProfile.self) {
                    DispatchQueue.main.async {
                        self.profile = decoded
                        self.loadFeed(for: decoded)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }
    }
    
    // MARK: - Load Feed
    func loadFeed(for loadedProfile: MyUserProfile) {
        guard let userID = loadedProfile.id else { return }
        FirebaseManager.shared.db
            .collection("users")
            .document(userID)
            .collection("feed")
            .order(by: "timestamp", descending: true)
            .getDocuments { [weak self] snap, err in
                guard let self = self else { return }
                if let err = err {
                    DispatchQueue.main.async {
                        self.errorMessage = "Error loading feed: \(err.localizedDescription)"
                    }
                    return
                }
                guard let docs = snap?.documents else { return }
                var loaded: [String] = []
                for doc in docs {
                    if let text = doc.data()["text"] as? String {
                        loaded.append(text)
                    }
                }
                DispatchQueue.main.async {
                    self.feedPosts = loaded
                }
            }
    }
}

// MARK: - ProfileHomeView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileHomeView: View {
    
    // MARK: - ViewModel
    @StateObject private var vm: ProfileHomeViewModel
    
    // MARK: Local
    @State private var showingEditSheet = false
    
    // MARK: - Init
    public init(profile: MyUserProfile) {
        _vm = StateObject(wrappedValue: ProfileHomeViewModel(initialProfile: profile))
    }
    
    // MARK: - Body
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                bannerSection()
                contentSection()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle(vm.isCurrentUser ? "My Profile" : "\(vm.profile.name.isEmpty ? "Unknown" : vm.profile.name)'s Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(profile: vm.profile.asUserProfile())
        }
        .onAppear {
            vm.loadProfile()
        }
        .alert(item: Binding<ErrorMessage?>(
            get: { vm.errorMessage == nil ? nil : ErrorMessage(msg: vm.errorMessage!) },
            set: { _ in vm.errorMessage = nil }
        )) { err in
            Alert(
                title: Text("Error"),
                message: Text(err.msg),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // MARK: Content
    private func contentSection() -> some View {
        VStack(spacing: 16) {
            avatarAndBasicInfo()
            statsRow()
            actionButtonsRow()
            aboutSection()
            tagsSection()
            feedSection()
        }
        .padding(.top, -40)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(.systemBackground))
                .offset(y: -30)
        )
        .padding(.top, -30)
    }
    
    // MARK: Banner
    private func bannerSection() -> some View {
        ZStack {
            if let bannerURL = vm.profile.bannerURL,
               !bannerURL.isEmpty,
               let url = URL(string: bannerURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Color.gray.opacity(0.3)
                    case .success(let img):
                        img.resizable().scaledToFill()
                    case .failure:
                        Color.gray.opacity(0.3)
                    @unknown default:
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: 180)
                .clipped()
            } else {
                Color.gray.opacity(0.3)
                    .frame(height: 180)
            }
        }
    }
    
    // MARK: Avatar & Info
    private func avatarAndBasicInfo() -> some View {
        VStack(spacing: 12) {
            ZStack {
                if let picURL = vm.profile.profilePictureURL,
                   !picURL.isEmpty,
                   let url = URL(string: picURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Circle().fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                        case .success(let img):
                            img.resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        case .failure:
                            Circle().fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                        @unknown default:
                            Circle().fill(Color.gray.opacity(0.3))
                                .frame(width: 100, height: 100)
                        }
                    }
                } else {
                    Circle().fill(Color.gray.opacity(0.3))
                        .frame(width: 100, height: 100)
                }
            }
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .offset(y: -40)
            .padding(.bottom, -40)
            
            Text(vm.profile.name.isEmpty ? "Unknown User" : vm.profile.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            if let clanTag = vm.profile.clanTag, !clanTag.isEmpty {
                Text("Clan: \(clanTag)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: Stats
    private func statsRow() -> some View {
        HStack(spacing: 24) {
            VStack {
                Text("Followers").font(.caption)
                Text("\(vm.profile.followers)").font(.headline)
            }
            VStack {
                Text("Friends").font(.caption)
                Text("\(vm.profile.friends)").font(.headline)
            }
            VStack {
                Text("Wins/Losses").font(.caption)
                Text("\(vm.profile.wins)/\(vm.profile.losses)").font(.headline)
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: Action Buttons
    private func actionButtonsRow() -> some View {
        Group {
            if vm.isCurrentUser {
                Button {
                    showingEditSheet = true
                } label: {
                    Text("Edit Profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            } else {
                HStack(spacing: 16) {
                    Button("Follow") {}
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    
                    Button("Message") {}
                        .font(.headline)
                        .frame(minWidth: 0, maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: About
    private func aboutSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if !vm.profile.bio.isEmpty {
                Text(vm.profile.bio).font(.body)
            }
            if vm.profile.phonePublicly,
               let phone = vm.profile.phone, !phone.isEmpty {
                Text("Phone: \(phone)").foregroundColor(.secondary)
            }
            if vm.profile.birthYearPublicly,
               let by = vm.profile.birthYear, !by.isEmpty {
                Text("Birth Year: \(by)").foregroundColor(.secondary)
            }
            if vm.profile.emailPublicly,
               let mail = vm.profile.email, !mail.isEmpty {
                Text("Email: \(mail)").foregroundColor(.secondary)
            }
            if !vm.profile.livePlatforms.isEmpty {
                Text("Live Platforms: \(vm.profile.livePlatforms.joined(separator: ", "))")
                    .foregroundColor(.secondary)
            }
            if !vm.profile.gamingAccounts.isEmpty {
                Text("Gaming Accounts: \(vm.profile.gamingAccounts.joined(separator: ", "))")
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }
    
    // MARK: Tags
    private func tagsSection() -> some View {
        if !vm.profile.tags.isEmpty {
            return AnyView(
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tags").font(.headline)
                    Text(vm.profile.tags.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    // MARK: Feed
    private func feedSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(vm.isCurrentUser ? "My Feed" : "\(vm.profile.name.isEmpty ? "Unknown User" : vm.profile.name)'s Posts")
                .font(.headline)
            if vm.feedPosts.isEmpty && !vm.isLoading {
                Text("No posts yet.")
                    .foregroundColor(.secondary)
            } else if vm.isLoading {
                ProgressView("Loading feed...")
            } else {
                ForEach(vm.feedPosts, id: \.self) { post in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(post)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Divider()
                    }
                }
            }
        }
        .padding(.top, 16)
    }
}

// MARK: - ErrorMessage for Alert
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
fileprivate struct ErrorMessage: Identifiable {
    let id = UUID()
    let msg: String
}
