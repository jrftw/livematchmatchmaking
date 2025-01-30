//
//  ThreadView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  Displays messages in a single thread. Allows sending text/images/videos, replying, reacting.

import SwiftUI
import AVKit
import FirebaseAuth  // Ensure FirebaseAuth is imported to use 'Auth'

// MARK: - ThreadView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ThreadView: View {
    
    // MARK: - State
    @StateObject private var vm = ThreadViewModel()
    
    public let threadID: String
    public let threadName: String?
    public let isGroup: Bool
    
    @State private var messageText = ""
    @State private var imageLink = ""
    @State private var videoLink = ""
    @State private var replyTo: String? = nil
    
    // MARK: - Initializer
    public init(threadID: String, threadName: String? = nil, isGroup: Bool) {
        self.threadID = threadID
        self.threadName = threadName
        self.isGroup = isGroup
    }
    
    // MARK: - Body
    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(vm.messages) { msg in
                            messageBubble(msg)
                                .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.count) { _ in
                    withAnimation {
                        if let lastID = vm.messages.last?.id {
                            scrollProxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            // MARK: Compose Area
            VStack(spacing: 8) {
                TextField("Image URL (optional)", text: $imageLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Video URL (optional)", text: $videoLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    TextField("Message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button("Send") {
                        ThreadMessageService.shared.sendMessage(
                            threadID: threadID,
                            text: messageText,
                            imageURL: imageLink.isEmpty ? nil : imageLink,
                            videoURL: videoLink.isEmpty ? nil : videoLink,
                            replyTo: replyTo
                        )
                        messageText = ""
                        imageLink = ""
                        videoLink = ""
                        replyTo = nil
                    }
                    .disabled(
                        messageText.trimmingCharacters(in: .whitespaces).isEmpty
                        && imageLink.isEmpty
                        && videoLink.isEmpty
                    )
                }
            }
            .padding()
        }
        .navigationTitle(isGroup ? (threadName ?? "Group Chat") : (threadName ?? "Direct Chat"))
        .onAppear {
            vm.startListening(threadID: threadID)
        }
        .onDisappear {
            vm.stopListening()
        }
    }
    
    // MARK: - Message Bubble
    private func messageBubble(_ msg: ThreadMessage) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .top) {
                let isMe = msg.senderID == Auth.auth().currentUser?.uid
                if !isMe { Spacer() }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(msg.senderName)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if let rID = msg.replyTo, !rID.isEmpty {
                        Text("Reply to: \(rID.prefix(8))...")
                            .font(.caption2)
                            .foregroundColor(.purple)
                            .padding(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color.purple, lineWidth: 1)
                            )
                    }
                    
                    if !msg.text.isEmpty {
                        Text(msg.text)
                            .font(.body)
                            .padding(6)
                    }
                    
                    if let img = msg.imageURL, !img.isEmpty, let url = URL(string: img) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(height: 150)
                            case .success(let image):
                                image.resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                            case .failure(_):
                                Color.red.frame(height: 150)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .cornerRadius(8)
                    }
                    
                    if let vid = msg.videoURL, !vid.isEmpty, let vURL = URL(string: vid) {
                        VideoPlayer(player: AVPlayer(url: vURL))
                            .frame(height: 200)
                            .cornerRadius(8)
                    }
                    
                    if !msg.reactions.isEmpty {
                        HStack(spacing: 8) {
                            ForEach(msg.reactions.keys.sorted(), id: \.self) { reactionKey in
                                if let users = msg.reactions[reactionKey], !users.isEmpty {
                                    Text("\(reactionKey) \(users.count)")
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    HStack(spacing: 20) {
                        Menu("React") {
                            Button("👍 Like") {
                                if let msgId = msg.id {
                                    ThreadMessageService.shared.addReaction(
                                        threadID: threadID,
                                        messageID: msgId,
                                        reaction: "👍"
                                    )
                                }
                            }
                            Button("❤️ Love") {
                                if let msgId = msg.id {
                                    ThreadMessageService.shared.addReaction(
                                        threadID: threadID,
                                        messageID: msgId,
                                        reaction: "❤️"
                                    )
                                }
                            }
                            Button("😆 Haha") {
                                if let msgId = msg.id {
                                    ThreadMessageService.shared.addReaction(
                                        threadID: threadID,
                                        messageID: msgId,
                                        reaction: "😆"
                                    )
                                }
                            }
                        }
                        Button("Reply") {
                            replyTo = msg.id
                        }
                    }
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.top, 4)
                }
                .background(isMe ? Color.blue.opacity(0.15) : Color.gray.opacity(0.2))
                .cornerRadius(8)
                
                if isMe { Spacer() }
            }
            
            Text("\(msg.timestamp, style: .time) • \(msg.timestamp, style: .date)")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 2)
        .id(msg.id)
    }
}
