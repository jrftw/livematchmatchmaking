//
//  ThreadListView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/30/25.
//


// MARK: ThreadListView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Displays all threads for the current user. Allows creating group or direct threads.

import SwiftUI
import FirebaseAuth

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ThreadListView: View {
    @StateObject private var vm = ThreadListViewModel()
    @State private var showingCreateThread = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack {
                if vm.threads.isEmpty {
                    Text("No chats available.")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(vm.threads) { thread in
                        NavigationLink {
                            ThreadView(
                                threadID: thread.id ?? "",
                                threadName: thread.isGroup ? thread.name : "Direct Chat",
                                isGroup: thread.isGroup
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                if thread.isGroup {
                                    Text(thread.name ?? "Group Chat")
                                        .font(.headline)
                                } else {
                                    Text("Direct Chat")
                                        .font(.headline)
                                }
                                Text("Last Updated: \(thread.lastUpdated, style: .time)")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                
                Button {
                    showingCreateThread = true
                } label: {
                    Text("New Chat")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Chats")
            .sheet(isPresented: $showingCreateThread) {
                CreateThreadView()
            }
        }
        .onAppear {
            vm.startListening()
        }
        .onDisappear {
            vm.stopListening()
        }
    }
}