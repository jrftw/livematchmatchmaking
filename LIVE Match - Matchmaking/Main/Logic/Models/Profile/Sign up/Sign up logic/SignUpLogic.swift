//
//  SignUpLogic.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - SignUpLogic.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Contains sign-up logic for finalizing account creation, bridging to Firestore, etc.
// Also includes a small extension to convert a SwiftUI Color to a hex string
// via UIColor on iOS/visionOS. Removes references to `.wrappedValue`
// and resolves "Initializer for conditional binding" issues.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

#if os(iOS) || os(visionOS)
import UIKit
#endif

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public extension SignUpMainContent {
    
    // MARK: - Should Show Gaming
    func shouldShowGamingPlatforms() -> Bool {
        (mainAccountCategory == .solo && selectedSoloTypes.contains(.gamer))
        || (mainAccountCategory == .business && selectedBusinessTypes.contains(.team))
    }
    
    // MARK: - Sign Up Action
    func signUpAction() {
        username = username.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard password == confirmPassword, !password.isEmpty else {
            showError("Passwords don't match or are empty.")
            return
        }
        guard !selectedTags.isEmpty || mainAccountCategory != .solo else {
            showError("At least one tag is required for Solo accounts.")
            return
        }
        guard agreedToTerms else {
            showError("You must agree to the Terms & Privacy Policy.")
            return
        }
        
        if selectedBusinessTypes.contains(.scouter) {
            showSubscriptionSheet = true
        } else {
            finalizeSignUp()
        }
    }
    
    // MARK: - Finalize Sign Up
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
        
        // Example "subscription price" logic
        let totalPrice = chosenAccountTypes.reduce(0.0) { sum, nextType in
            switch nextType {
            case .team: return sum + 1
            case .agency: return sum + 5
            case .scouter: return sum + 10
            default: return sum
            }
        }
        
        let mergedName = "\(firstName) \(lastName)".trimmingCharacters(in: .whitespacesAndNewlines)
        let df = DateFormatter()
        df.dateFormat = "yyyy"
        let birthYearString = df.string(from: birthday)
        
        // Use the bridging function clanColorHex(clanColor) rather than clanColor.wrappedValue
        let colorHex = clanColorHex(clanColor)
        
        let newProfile = UserProfile(
            id: userID,
            username: username.isEmpty ? mergedName : username,
            bio: bio,
            phone: phoneNumber.isEmpty ? nil : phoneNumber,
            phonePublicly: confirmPhonePublicly,
            birthYear: birthYearString,
            birthYearPublicly: false,
            email: email,
            emailPublicly: false,
            clanTag: clanTag.isEmpty ? nil : clanTag,
            clanColorHex: colorHex,
            profilePictureURL: profilePicURL,
            bannerURL: nil,
            followers: 0,
            friends: 0,
            wins: 0,
            losses: 0,
            livePlatforms: [],
            livePlatformLinks: [],
            agencies: [],
            creatorNetworks: [],
            teams: [],
            communities: [],
            tags: Array(selectedTags),
            socialLinks: socialLinks,
            gamingAccounts: [],
            gamingAccountDetails: gamingAccounts,
            livePlatformDetails: [],
            accountTypes: chosenAccountTypes,
            isSearching: false,
            roster: [],
            establishedDate: "",
            subscriptionActive: (totalPrice > 0),
            subscriptionPrice: totalPrice,
            createdAt: Date(),
            hasCommunityMembership: false,
            isCommunityAdmin: false,
            hasGroupMembership: false,
            isGroupAdmin: false,
            hasTeamMembership: false,
            isTeamAdmin: false,
            hasAgencyMembership: false,
            isAgencyAdmin: false,
            hasCreatorNetworkMembership: false,
            isCreatorNetworkAdmin: false
        )
        
        do {
            try FirebaseManager.shared.db
                .collection("users")
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
            if selectedSoloTypes.contains(.viewer) { types.append(.viewer) }
            if selectedSoloTypes.contains(.creator) { types.append(.creator) }
            if selectedSoloTypes.contains(.gamer) { types.append(.gamer) }
            if types.isEmpty { types.append(.guest) }
        case .community:
            if selectedCommunityTypes.contains(.community) { types.append(.agency) }
            if selectedCommunityTypes.contains(.group) { types.append(.team) }
            if types.isEmpty { types.append(.guest) }
        case .business:
            if selectedBusinessTypes.contains(.team) { types.append(.team) }
            if selectedBusinessTypes.contains(.agency) { types.append(.agency) }
            if selectedBusinessTypes.contains(.creatornetwork) { types.append(.creatornetwork) }
            if selectedBusinessTypes.contains(.scouter) { types.append(.scouter) }
            if types.isEmpty { types.append(.guest) }
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

// MARK: - Bridging: Color -> Hex
#if os(iOS) || os(visionOS)
import UIKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public extension SignUpMainContent {
    func clanColorHex(_ color: Color) -> String {
        // Convert SwiftUI Color -> UIColor -> hex,
        // returning a default if anything fails
        let uiColor = UIColor(color)
        return uiColor.toHex() ?? "#0000FF"
    }
}

fileprivate extension UIColor {
    func toHex() -> String? {
        var rF: CGFloat = 0
        var gF: CGFloat = 0
        var bF: CGFloat = 0
        var aF: CGFloat = 0
        guard getRed(&rF, green: &gF, blue: &bF, alpha: &aF) else {
            return nil
        }
        let r = Int(rF * 255)
        let g = Int(gF * 255)
        let b = Int(bF * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
#endif
