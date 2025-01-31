//
//  EditProfileView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Allows editing of a user profile in a form.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileHomeViewModel
    @State var profile: UserProfile
    
    @State private var clanTagColor: Color = .blue
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Group {
                    Text("Profile Picture URL")
                    TextField("https://...", text: Binding(
                        get: { profile.profilePictureURL ?? "" },
                        set: { profile.profilePictureURL = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Banner Picture URL")
                    TextField("https://...", text: Binding(
                        get: { profile.bannerURL ?? "" },
                        set: { profile.bannerURL = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Group {
                    Text("Username")
                    TextField("Enter display name", text: $profile.username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Bio")
                    TextField("Enter a short bio", text: $profile.bio)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Phone Number")
                    TextField("Enter phone number", text: Binding(
                        get: { profile.phone ?? "" },
                        set: { profile.phone = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Birth Year")
                    TextField("Enter birth year", text: Binding(
                        get: { profile.birthYear ?? "" },
                        set: { profile.birthYear = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Group {
                    Text("Clan Tag")
                    TextField("Enter clan tag", text: Binding(
                        get: { profile.clanTag ?? "" },
                        set: { profile.clanTag = $0 }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Social Links (comma separated)")
                    TextField("e.g. twitter.com/xyz, twitch.tv/xyz", text: Binding(
                        get: { profile.socialLinks.joined(separator: ", ") },
                        set: {
                            let arr = $0.components(separatedBy: ", ").filter { !$0.isEmpty }
                            profile.socialLinks = arr
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Gaming Accounts (comma separated)")
                    TextField("e.g. PSN:User, Xbox:User", text: Binding(
                        get: { profile.gamingAccounts.joined(separator: ", ") },
                        set: {
                            let arr = $0.components(separatedBy: ", ").filter { !$0.isEmpty }
                            profile.gamingAccounts = arr
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Live Platforms (comma separated)")
                    TextField("e.g. Twitch, YouTube", text: Binding(
                        get: { profile.livePlatforms.joined(separator: ", ") },
                        set: {
                            let arr = $0.components(separatedBy: ", ").filter { !$0.isEmpty }
                            profile.livePlatforms = arr
                        }
                    ))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Group {
                    Text("Followers: \(profile.followers)")
                    Text("Friends: \(profile.friends)")
                    
                    Text("Wins")
                    TextField("Number of wins", value: $profile.wins, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Text("Losses")
                    TextField("Number of losses", value: $profile.losses, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button("Save Changes") {
                    viewModel.updateProfile(profile)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 20)
            }
            .padding()
        }
        .navigationTitle("Edit Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}
