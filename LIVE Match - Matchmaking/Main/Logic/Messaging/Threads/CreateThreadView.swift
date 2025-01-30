//
//  CreateThreadView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: CreateThreadView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Allows a user to create a new direct or group chat by specifying participants.

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct CreateThreadView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var isGroup = false
    @State private var groupName = ""
    @State private var participantInput = ""
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
                Section(header: Text("Participants")) {
                    TextField("Enter user ID to add", text: $participantInput)
                    Button("Add Participant") {
                        let trimmed = participantInput.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        if !participants.contains(trimmed) {
                            participants.append(trimmed)
                        }
                        participantInput = ""
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
        }
    }
    
    private func createThread() {
        guard let currentUser = Auth.auth().currentUser else {
            errorMessage = "You must be logged in to create a chat."
            return
        }
        var finalList = participants
        // Ensure current user is in the thread
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