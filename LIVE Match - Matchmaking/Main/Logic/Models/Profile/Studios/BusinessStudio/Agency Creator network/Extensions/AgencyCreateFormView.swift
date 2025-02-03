//
//  AgencyCreateFormView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5, visionOS 2.0+
//  A form to create a new agency/creator network doc in "agencies" collection,
//  with required/optional fields, plus toggles for which platforms the agency supports,
//  now includes "ownerUID" pointing to the current user's UID,
//  and a revised AgencyPlatform that excludes 'id' from coding.
//

import SwiftUI
import Firebase
import FirebaseAuth

// MARK: - AgencyPlatform
// We exclude `id` from coding to silence the “Immutable property…” warning.
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AgencyPlatform: Identifiable, Codable {
    public let id = UUID()
    public let name: String
    public var enabled: Bool = false
    
    public init(name: String, enabled: Bool = false) {
        self.name = name
        self.enabled = enabled
    }
    
    // We only code/encode 'name' and 'enabled'
    enum CodingKeys: String, CodingKey {
        case name
        case enabled
    }
    
    // Custom init to ignore 'id' from decoder
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.enabled = try container.decode(Bool.self, forKey: .enabled)
        // 'id' will be a new random UUID() in memory
    }
    
    // Custom encoder ignoring 'id'
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(enabled, forKey: .enabled)
    }
    
    public func asDictionary() -> [String: Any] {
        [
            "name": name,
            "enabled": enabled
            // We intentionally don't store 'id' in Firestore
        ]
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct AgencyCreateFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    // Required fields
    @State private var agencyName: String
    @State private var foundingDate: Date = Date()
    @State private var founders: String = ""     // e.g. comma-separated
    @State private var email: String = ""
    @State private var phoneNumber: String = ""
    @State private var website: String = ""
    @State private var inviteLink: String = ""
    
    // Optional bio
    @State private var bio: String = ""
    
    // A list of possible platforms for agencies, with toggles
    @State private var agencyPlatforms: [AgencyPlatform] = [
        .init(name: "TikTok"),
        .init(name: "Favorited"),
        .init(name: "Mango"),
        .init(name: "LIVE.Me"),
        .init(name: "YouNow"),
        .init(name: "YouTube"),
        .init(name: "Clapper"),
        .init(name: "Fanbase"),
        .init(name: "Kick"),
        .init(name: "Other")
    ]
    
    private let db = FirebaseManager.shared.db
    
    /// Called on successful creation, passing back the created agency name or ID.
    let onCreated: (String) -> Void
    
    public init(proposedName: String, onCreated: @escaping (String) -> Void) {
        _agencyName = State(initialValue: proposedName)
        self.onCreated = onCreated
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section("Create Agency / Network") {
                    TextField("Agency/Network Name", text: $agencyName)
                    
                    DatePicker("Founding Date", selection: $foundingDate, displayedComponents: .date)
                    
                    TextField("Founder(s) Names", text: $founders)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                    TextField("Phone Number", text: $phoneNumber)
                        .keyboardType(.phonePad)
                    TextField("Website", text: $website)
                        .keyboardType(.URL)
                    TextField("Invite Link", text: $inviteLink)
                        .keyboardType(.URL)
                    
                    TextField("Bio (Optional)", text: $bio)
                }
                
                Section("Supported Platforms") {
                    ForEach($agencyPlatforms.indices, id: \.self) { i in
                        Toggle(agencyPlatforms[i].name, isOn: $agencyPlatforms[i].enabled)
                    }
                }
                
                Button("Create") {
                    createAgency()
                }
                .disabled(
                    agencyName.trimmingCharacters(in: .whitespaces).isEmpty ||
                    email.trimmingCharacters(in: .whitespaces).isEmpty ||
                    phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
                )
            }
            .navigationTitle("New Agency")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    private func createAgency() {
        guard let user = Auth.auth().currentUser else {
            print("Error: No logged-in user. Cannot create agency.")
            return
        }
        let trimmedName = agencyName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let ref = db.collection("agencies").document()
        
        // Convert each platform to a dictionary
        let platformsArray = agencyPlatforms.map { $0.asDictionary() }
        
        let data: [String: Any] = [
            "name": trimmedName,
            "foundingDate": Timestamp(date: foundingDate),
            "founders": founders,
            "email": email,
            "phoneNumber": phoneNumber,
            "website": website,
            "inviteLink": inviteLink,
            "bio": bio,
            "platforms": platformsArray,
            "ownerUID": user.uid // store the owner's UID
        ]
        
        ref.setData(data) { err in
            if let err = err {
                print("Error creating agency: \(err.localizedDescription)")
            } else {
                print("Created agency doc with ownerUID = \(user.uid)")
                onCreated(trimmedName)
                dismiss()
            }
        }
    }
}
