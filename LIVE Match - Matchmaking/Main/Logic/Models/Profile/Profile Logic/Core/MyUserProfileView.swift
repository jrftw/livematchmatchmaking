// MARK: MyUserProfileView.swift
// Uses MyUserProfile to display banner & avatar, stats, etc.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct MyUserProfileView: View {
    public let profile: MyUserProfile
    
    @State private var showingEditSheet = false
    @State private var currentWins: Int
    @State private var currentLosses: Int
    
    private var isCurrentUser: Bool {
        guard let currentUID = Auth.auth().currentUser?.uid else { return false }
        return (profile.id == currentUID)
    }
    
    private let db = Firestore.firestore()
    
    public init(profile: MyUserProfile) {
        self.profile = profile
        _currentWins = State(initialValue: profile.wins)
        _currentLosses = State(initialValue: profile.losses)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                // MARK: - Banner
                ZStack {
                    if let bannerURL = profile.bannerURL,
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
                    } else {
                        Color.gray.opacity(0.3)
                    }
                }
                .frame(height: 220)
                .clipped()
                
                // MARK: - Avatar
                ZStack {
                    Circle().fill(Color.white)
                        .frame(width: 130, height: 130)
                    
                    if let picURL = profile.profilePictureURL,
                       !picURL.isEmpty,
                       let url = URL(string: picURL) {
                        AsyncImage(url: url) { phase in
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
                        .clipShape(Circle())
                    } else {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                }
                .frame(width: 130, height: 130)
                .overlay(Circle().stroke(Color.white, lineWidth: 3))
                .offset(y: -65)
                .padding(.bottom, -65)
                
                // MARK: - Clan Tag + Username
                VStack(spacing: 4) {
                    if let clan = profile.clanTag, !clan.isEmpty {
                        Text("\(clan) @\(profile.username)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    } else {
                        Text("@\(profile.username)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 8)
                
                // MARK: - Bio
                if let b = profile.bio, !b.isEmpty {
                    Text(b)
                        .font(.body)
                        .padding(.top, 4)
                }
                
                // MARK: - Display Name
                Text(profile.displayName.isEmpty ? "Unknown" : profile.displayName)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top, 8)
                
                // MARK: - Followers / Following
                HStack(spacing: 32) {
                    VStack {
                        Text("\(profile.followersCount)")
                            .font(.headline)
                        Text("Followers")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text("\(profile.followingCount)")
                            .font(.headline)
                        Text("Following")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 8)
                
                // MARK: - Win / Lose Stats
                winLoseSection()
                
                // MARK: - Button Row
                buttonRow()
                    .padding(.top, 16)
                
                // MARK: - Additional Info
                extraInfoSection()
                
                // MARK: - Placeholders
                platformTeamsSection()
                feedSection()
                
                Spacer().frame(height: 32)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingEditSheet) {
            EditProfileView(profile: profile)
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Logic / UI
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
extension MyUserProfileView {
    
    // MARK: Win / Lose
    private func winLoseSection() -> some View {
        let ratio = (currentLosses == 0)
            ? (currentWins > 0 ? "∞" : "0.0")
            : String(format: "%.2f", Double(currentWins) / Double(currentLosses))
        
        return VStack(spacing: 8) {
            Text("Win / Lose Stats")
                .font(.headline)
            HStack(spacing: 20) {
                VStack {
                    Text("Wins").font(.subheadline)
                    HStack(spacing: 12) {
                        Button("-") {
                            if currentWins > 0 {
                                currentWins -= 1
                                updateWinsLosses()
                            }
                        }
                        Text("\(currentWins)").font(.headline)
                        Button("+") {
                            currentWins += 1
                            updateWinsLosses()
                        }
                    }
                }
                VStack {
                    Text("Losses").font(.subheadline)
                    HStack(spacing: 12) {
                        Button("-") {
                            if currentLosses > 0 {
                                currentLosses -= 1
                                updateWinsLosses()
                            }
                        }
                        Text("\(currentLosses)").font(.headline)
                        Button("+") {
                            currentLosses += 1
                            updateWinsLosses()
                        }
                    }
                }
            }
            Text("W/L Ratio: \(ratio)")
                .foregroundColor(.secondary)
        }
        .padding(.top, 8)
    }
    
    private func updateWinsLosses() {
        guard let uid = profile.id else { return }
        let docRef = db.collection("users").document(uid)
        docRef.setData(["wins": currentWins,
                        "losses": currentLosses],
                       merge: true)
    }
    
    // MARK: Button Row
    private func buttonRow() -> some View {
        HStack(spacing: 20) {
            if isCurrentUser {
                Button("Edit Profile") {
                    showingEditSheet = true
                }
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Share") {
                    // share logic
                }
                .font(.headline)
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            } else {
                Button("Follow") {
                    // follow logic
                }
                .font(.headline)
                .padding()
                .background(Color.blue.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                
                Button("Message") {
                    // message logic
                }
                .font(.headline)
                .padding()
                .background(Color.green.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
    }
    
    // MARK: Extra Info
    private func extraInfoSection() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            if profile.birthdayPublicly,
               let bday = profile.birthday,
               !bday.isEmpty {
                Text("Birthday: \(bday)").font(.subheadline)
            }
            if profile.emailPublicly,
               let em = profile.email,
               !em.isEmpty {
                Text("Email: \(em)").font(.subheadline)
            }
            if profile.phonePublicly,
               let ph = profile.phoneNumber,
               !ph.isEmpty {
                Text("Phone: \(ph)").font(.subheadline)
            }
            // Tags
            if !profile.tags.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tags:").font(.headline)
                    Text(profile.tags.joined(separator: ", "))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
            }
            // Social
            if !profile.socialLinks.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Social Links:").font(.headline)
                    ForEach(Array(profile.socialLinks.keys), id: \.self) { key in
                        if let link = profile.socialLinks[key], !link.isEmpty {
                            Text("\(key): \(link)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 16)
    }
    
    // MARK: Platform Teams
    private func platformTeamsSection() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Platforms / Agencies / Teams")
                .font(.headline)
            Text("(No Content Yet)")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 20)
    }
    
    // MARK: Feed
    private func feedSection() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Feed / Tournaments")
                .font(.headline)
            Text("(No Content Yet)")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 12)
    }
}
