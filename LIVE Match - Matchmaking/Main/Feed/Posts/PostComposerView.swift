// MARK: - PostComposerView.swift
// iOS 15.6+, macOS 11.5, visionOS 2.0+
// A "Facebook-style" post composer for text, images, video, user mentions.

import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PostComposerView: View {
    @Environment(\.dismiss) private var dismiss
    
    // MARK: User Input
    @State private var postText = ""
    @State private var selectedImages: [UIImage] = []
    @State private var selectedVideoURL: URL? = nil
    @State private var taggedUsers: [String] = []
    
    public let onPost: (String, [UIImage], URL?, [String]) -> Void
    
    // MARK: - Picker States
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var showingUserSearch = false
    @State private var potentialUsers: [String] = []
    
    public init(onPost: @escaping (String, [UIImage], URL?, [String]) -> Void) {
        self.onPost = onPost
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Post Text
                    TextEditor(text: $postText)
                        .frame(minHeight: 120)
                        .padding(.horizontal, 4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                        )
                        .onChange(of: postText) { newValue in
                            // Show mention UI if last char is '@'
                            if newValue.last == "@" {
                                showingUserSearch = true
                            }
                        }
                    
                    // Attached Images
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
                    
                    // Attached Video
                    if let vidURL = selectedVideoURL {
                        Text("Attached Video: \(vidURL.lastPathComponent)")
                            .font(.subheadline)
                            .foregroundColor(.blue)
                    }
                    
                    // Tagged Users
                    if !taggedUsers.isEmpty {
                        Text("Tagged: \(taggedUsers.joined(separator: ", "))")
                            .font(.footnote)
                            .foregroundColor(.blue)
                    }
                    
                    // Action Buttons
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
                    
                    // Post Button
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
            // Image picker
            .sheet(isPresented: $showingImagePicker) {
                MultiImagePicker(images: $selectedImages, selectionLimit: 5)
            }
            // Video picker
            .sheet(isPresented: $showingVideoPicker) {
                VideoPicker(videoURL: $selectedVideoURL)
            }
            // Mention user search
            .sheet(isPresented: $showingUserSearch) {
                UserSearchView(
                    potentialUsers: potentialUsers,
                    onSelect: { user in
                        if !postText.hasSuffix("@") {
                            postText.append(" @\(user)")
                        } else {
                            postText.append("\(user)")
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
}

// MARK: - UserSearchView
@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
fileprivate struct UserSearchView: View {
    let potentialUsers: [String]
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
            return potentialUsers
        }
        return potentialUsers.filter { $0.localizedCaseInsensitiveContains(query) }
    }
}
