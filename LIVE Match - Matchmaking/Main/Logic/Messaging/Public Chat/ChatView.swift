//
//  ChatView.swift
//  LIVE Match - Matchmaking
//
//  Displays a scrolling list of messages from ChatViewModel,
//  and a text field for composing new messages.
//

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ChatView: View {
    @StateObject private var vm = ChatViewModel()
    @State private var messageText = ""
    
    public init() {}
    
    public var body: some View {
        VStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(vm.messages) { msg in
                            ChatMessageRow(
                                message: msg,
                                userProfile: vm.userProfiles[msg.senderUID]
                            )
                            .id(msg.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: vm.messages.count) { _ in
                    if let lastID = vm.messages.last?.id {
                        withAnimation {
                            scrollProxy.scrollTo(lastID, anchor: .bottom)
                        }
                    }
                }
            }
            
            Divider()
            
            HStack {
                TextField("Message...", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Send") {
                    vm.sendMessage(text: messageText)
                    messageText = ""
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .navigationTitle("Community Chat")
        .onAppear {
            vm.fetchMessages()
        }
    }
}
