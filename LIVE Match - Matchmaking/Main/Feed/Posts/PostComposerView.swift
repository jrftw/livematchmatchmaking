// MARK: - PostComposerView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// A "Facebook-style" post composer for text, images, video, user mentions.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PostComposerView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var postText = ""
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURL: URL? = nil
    @State private var taggedUsers: [String] = []
    
    @State private var potentialUsers: [String] = []
    @State private var showingUserSearch = false
    
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    
    public let onPost: (String, [UIImage], URL?, [String]) -> Void
    
    public init(onPost: @escaping (String, [UIImage], URL?, [String]) -> Void) {
        self.onPost = onPost
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    TextEditor(text: $postText)
                        .frame(minHeight: 120)
                        .padding(.horizontal, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: postText) { newValue in
                            if newValue.last == "@" {
                                showingUserSearch = true
                            }
                        }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(selectedImages, id: \.self) { img in
                                    Image(uiImage: img)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                    }
                    
                    if let vidURL = selectedVideoURL {
                        Text("Attached Video: \(vidURL.lastPathComponent)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    if !taggedUsers.isEmpty {
                        Text("Tagged: \(taggedUsers.joined(separator: ", "))")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    
                    HStack(spacing: 16) {
                        Button {
                            showingImagePicker = true
                        } label: {
                            Label("Photo", systemImage: "photo")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            showingVideoPicker = true
                        } label: {
                            Label("Video", systemImage: "video")
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            showingUserSearch = true
                        } label: {
                            Label("Tag People", systemImage: "at")
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button {
                        onPost(postText, selectedImages, selectedVideoURL, taggedUsers)
                        dismiss()
                    } label: {
                        Text("Post")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(postText.trimmingCharacters(in: .whitespaces).isEmpty
                              && selectedImages.isEmpty
                              && selectedVideoURL == nil)
                }
                .padding()
            }
            .navigationTitle("Create Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                fetchAllUsernames()
            }
            .sheet(isPresented: $showingImagePicker) {
                #if os(iOS) || os(visionOS)
                MultiImagePicker(images: $selectedImages, selectionLimit: 5)
                #endif
            }
            .sheet(isPresented: $showingVideoPicker) {
                #if os(iOS) || os(visionOS)
                VideoPicker(videoURL: $selectedVideoURL)
                #endif
            }
            .sheet(isPresented: $showingUserSearch) {
                UserSearchView(
                    users: potentialUsers,
                    onSelect: { user in
                        if !postText.hasSuffix("@") {
                            postText.append(" @\(user)")
                        } else {
                            postText.append(user)
                        }
                        taggedUsers.append(user)
                    }
                )
            }
        }
        #if os(iOS) || os(visionOS)
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
    private func fetchAllUsernames() {
        FirebaseManager.shared.db.collection("users")
            .getDocuments { snap, err in
                guard let docs = snap?.documents, err == nil else { return }
                self.potentialUsers = docs.compactMap { $0.data()["username"] as? String }
            }
    }
}

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
fileprivate struct UserSearchView: View {
    let users: [String]
    let onSelect: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var query = ""
    
    var body: some View {
        NavigationView {
            List(filteredResults, id: \.self) { user in
                Button(user) {
                    onSelect(user)
                    dismiss()
                }
            }
            .searchable(text: $query)
            .navigationTitle("Tag a User")
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
    
    private var filteredResults: [String] {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return users
        }
        return users.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}
