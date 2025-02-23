//
//  CreateThreadView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Allows a user to create a new direct or group chat by searching all users
//  by username, sorted A-Z. Clicking a user adds them to participants.
//
//  NOTE: This version uses force-unwrap (!) on optional fields to satisfy
//  the requirement "Force-unwrap using '!' to abort execution if the
//  optional value contains 'nil'." Understand that if `id` or `bio` are
//  actually nil, the app will crash.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreateThreadView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isGroup = false
    @State private var groupName = ""
    
    @StateObject private var userSearchVM = ThreadUserSearchViewModel()
    
    @State private var participants: [String] = []
    @State private var errorMessage = ""
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                Section {
                    Toggle("Create Group Chat?", isOn: $isGroup)
                    if isGroup {
                        TextField("Group Name", text: $groupName)
                    }
                }
                
                Section(header: Text("Add Participants")) {
                    TextField("Search by username...", text: $userSearchVM.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Force-unwrap 'id' and 'bio' in the List
                    // If userProfile.id or userProfile.bio might be nil, this will crash at runtime.
                    if !userSearchVM.filteredUsers.isEmpty {
                        List(userSearchVM.filteredUsers, id: \.id!) { userProfile in
                            Button {
                                // Force-unwrap userProfile.id
                                let userID = userProfile.id!
                                
                                if !participants.contains(userID) {
                                    participants.append(userID)
                                }
                            } label: {
                                VStack(alignment: .leading) {
                                    // Force-unwrap 'bio' if you want to check .count
                                    // Alternatively, check for nil if you prefer safe usage
                                    // e.g. "if userProfile.bio != nil && !userProfile.bio!.isEmpty"
                                    Text(userProfile.username)
                                        .font(.headline)
                                    
                                    if userProfile.bio != nil && !userProfile.bio!.isEmpty {
                                        Text(userProfile.bio!)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                        .frame(minHeight: 200, maxHeight: 300)
                    } else {
                        Text("No users found.")
                            .foregroundColor(.secondary)
                    }
                    
                    if !participants.isEmpty {
                        ForEach(participants, id: \.self) { userId in
                            HStack {
                                Text(userId)
                                Spacer()
                                Button("Remove") {
                                    participants.removeAll(where: { $0 == userId })
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                Section {
                    Button("Create Thread") {
                        createThread()
                    }
                    .disabled(participants.isEmpty)
                }
            }
            .navigationTitle("New Chat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                userSearchVM.fetchAllUsers()
            }
        }
    }
    
    private func createThread() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to create a chat."
            return
        }
        var finalList = participants
        if !finalList.contains(currentUser.uid) {
            finalList.append(currentUser.uid)
        }
        ChatThreadService.shared.createThread(
            participants: finalList,
            isGroup: isGroup,
            groupName: isGroup ? groupName : nil
        ) { threadID in
            if threadID == nil {
                errorMessage = "Failed to create thread."
            } else {
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
