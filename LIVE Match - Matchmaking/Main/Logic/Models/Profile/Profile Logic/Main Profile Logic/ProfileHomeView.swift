// MARK: - ProfileHomeView.swift
import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ProfileHomeView: View {
    @StateObject private var vm: ProfileHomeViewModel
    @State private var showingEditSheet = false
    
    private var isCurrentUser: Bool {
        guard let currentUID = Auth.auth().currentUser?.uid else { return false }
        return (vm.profile.id == currentUID)
    }
    
    public init(userID: String? = nil) {
        _vm = StateObject(wrappedValue: ProfileHomeViewModel(userID: userID))
    }
    
    public var body: some View {
        Group {
            if vm.isLoading {
                ProgressView("Loading Profile...")
            }
            else if let error = vm.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
            else {
                if isCurrentUser {
                    MyUserProfileView(profile: vm.profile)
                } else {
                    PublicProfileView(profile: vm.profile, isCurrentUser: false)
                }
            }
        }
        .navigationTitle(
            isCurrentUser
                ? "My Profile"
                : vm.profile.displayName.isEmpty
                ? "Unknown"
                : "\(vm.profile.displayName)'s Profile"
        )
    }
}
