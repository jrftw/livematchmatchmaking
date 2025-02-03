//
//  ProfileRouterView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/2/25.
//


//
//  ProfileRouterView.swift
//  LIVE Match - Matchmaking
//
//  A small “router” view that decides whether to show MyUserProfileView or PublicProfileView.
//  Usage:
//    1. Pass in the user’s MyUserProfile data and the current user’s ID.
//    2. If the IDs match, you get the MyUserProfileView. Otherwise, PublicProfileView.
//
//  Example:
//    ProfileRouterView(profile: someProfile, currentUserId: Auth.auth().currentUser?.uid)
//
//  This approach ensures that tapping “Profile” can conditionally present the correct UI.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileRouterView: View {
    public let profile: MyUserProfile
    public let currentUserId: String?
    
    public init(profile: MyUserProfile, currentUserId: String?) {
        self.profile = profile
        self.currentUserId = currentUserId
    }
    
    public var body: some View {
        let isOwner = (profile.id == currentUserId)
        
        if isOwner {
            // Show MY profile
            MyUserProfileView(profile: profile)
        } else {
            // Show a public profile
            PublicProfileView(profile: profile, isCurrentUser: false)
        }
    }
}