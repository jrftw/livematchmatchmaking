//
//  ChatMessageRow.swift
//  LIVE Match - Matchmaking
//
//  A single message row: user avatar + clanTag + @username + text bubble.
//  Tapping the avatar presents the user's ProfileHomeView in a sheet.
//

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChatMessageRow: View {
    public let message: ChatMessage
    public let userProfile: MyUserProfile?
    
    @State private var showingProfile = false
    
    public init(message: ChatMessage, userProfile: MyUserProfile?) {
        self.message = message
        self.userProfile = userProfile
    }
    
    public var body: some View {
        HStack(alignment: .top, spacing: 8) {
            userAvatar
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .onTapGesture {
                    showingProfile = true
                }
                .sheet(isPresented: $showingProfile) {
                    if let uid = userProfile?.id {
                        NavigationView {
                            ProfileHomeView(userID: uid)
                        }
                    } else {
                        Text("No profile found.").padding()
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                // e.g. "FTW @someusername"
                if let profile = userProfile {
                    HStack(spacing: 4) {
                        if let clan = profile.clanTag, !clan.isEmpty {
                            Text(clan)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        Text("@\(profile.username)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Loading user...")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Text(message.text)
                    .padding(8)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(8)
            }
            Spacer()
        }
    }
    
    // MARK: - userAvatar
    @ViewBuilder
    private var userAvatar: some View {
        if let profile = userProfile,
           let picURL = profile.profilePictureURL,
           !picURL.isEmpty,
           let remote = URL(string: picURL) {
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
        } else {
            Circle().fill(Color.gray.opacity(0.3))
        }
    }
}
