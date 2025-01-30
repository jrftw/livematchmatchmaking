//
//  SignUpLogic.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Shared logic for sign-up, no duplicates.
//
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public extension SignUpMainContent {
    // MARK: - Condition for Gaming Platforms
    func shouldShowGamingPlatforms() -> Bool {
        (mainAccountCategory == .solo && selectedSoloTypes.contains(.gamer))
        || (mainAccountCategory == .business && selectedBusinessTypes.contains(.team))
    }
    
    // MARK: - Main Sign-Up Action
    func signUpAction() {
        username = username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard password == confirmPassword, !password.isEmpty else {
            showError("Passwords don't match or are empty.")
            return
        }
        guard !selectedTags.isEmpty else {
            showError("At least one tag is required.")
            return
        }
        
        if selectedBusinessTypes.contains(.scouter) {
            showSubscriptionSheet = true
        } else {
            finalizeSignUp()
        }
    }
    
    // MARK: - Finalize Sign-Up
    func finalizeSignUp() {
        AuthManager.shared.signUp(email: email, password: password) { result in
            switch result {
            case .failure(let err):
                showError(err.localizedDescription)
            case .success:
                uploadProfileImage { urlString in
                    createProfile(profilePicURL: urlString)
                }
            }
        }
    }
    
    // MARK: - Create Profile
    private func createProfile(profilePicURL: String?) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let chosenAccountTypes = determineAccountTypes()
        let totalPrice = chosenAccountTypes.reduce(0.0) { sum, type in
            switch type {
            case .team: return sum + 1
            case .agency: return sum + 5
            case .scouter: return sum + 10
            default: return sum
            }
        }
        let mergedName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        let birthYearString = df.string(from: birthday)
        
        let newProfile = UserProfile(
            id: userID,
            accountTypes: chosenAccountTypes,
            email: email,
            name: username.isEmpty ? mergedName : username,
            bio: bio,
            birthYear: birthYearString,
            phone: phoneNumber.isEmpty ? nil : phoneNumber,
            profilePictureURL: profilePicURL,
            bannerURL: nil,
            clanTag: clanTag.isEmpty ? nil : clanTag,
            tags: Array(selectedTags),
            socialLinks: socialLinks,
            gamingAccounts: [],
            livePlatforms: [],
            gamingAccountDetails: gamingAccounts,
            livePlatformDetails: [],
            followers: 0,
            friends: 0,
            isSearching: false,
            wins: 0,
            losses: 0,
            roster: [],
            establishedDate: "",
            subscriptionActive: (totalPrice > 0),
            subscriptionPrice: totalPrice,
            createdAt: Date()
        )
        
        do {
            try FirebaseManager.shared.db.collection("users")
                .document(userID)
                .setData(from: newProfile)
        } catch {
            print("Error creating user profile: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Determine Account Types
    func determineAccountTypes() -> [AccountType] {
        var types: [AccountType] = []
        switch mainAccountCategory {
        case .solo:
            if selectedSoloTypes.contains(.viewer) { types.append(.guest) }
            if selectedSoloTypes.contains(.creator) { types.append(.creator) }
            if selectedSoloTypes.contains(.gamer) { types.append(.gamer) }
        case .community:
            if selectedCommunityTypes.contains(.community) { types.append(.agency) }
            if selectedCommunityTypes.contains(.group) { types.append(.team) }
        case .business:
            if selectedBusinessTypes.contains(.team) { types.append(.team) }
            if selectedBusinessTypes.contains(.agency) { types.append(.agency) }
            if selectedBusinessTypes.contains(.creatornetwork) { types.append(.creatornetwork) }
            if selectedBusinessTypes.contains(.scouter) { types.append(.scouter) }
        }
        if types.isEmpty {
            types.append(.guest)
        }
        return types
    }
    
    // MARK: - Upload Profile Image
    func uploadProfileImage(completion: @escaping (String?) -> Void) {
        guard let image = profileImage,
              let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        let userID = Auth.auth().currentUser?.uid ?? UUID().uuidString
        let storageRef = Storage.storage().reference().child("profileImages/\(userID).jpg")
        
        storageRef.putData(imageData, metadata: nil) { _, error in
            if let error = error {
                print("Upload error: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { url, _ in
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    // MARK: - Show Error
    func showError(_ msg: String) {
        errorMessage = msg
        showingError = true
    }
}
