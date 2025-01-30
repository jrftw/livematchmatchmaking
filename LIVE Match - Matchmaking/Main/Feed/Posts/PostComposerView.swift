// MARK: PostComposerView.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct PostComposerView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var postText = ""
    @State private var imageURL: String = ""
    @State private var videoURL: String = ""
    
    public let onPost: (String, String, String) -> Void
    
    public init(onPost: @escaping (String, String, String) -> Void) {
        self.onPost = onPost
    }
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Text")) {
                    TextEditor(text: $postText)
                        .frame(height: 100)
                }
                Section(header: Text("Media")) {
                    TextField("Image URL", text: $imageURL)
                    TextField("Video URL", text: $videoURL)
                }
                Section {
                    Button("Post") {
                        onPost(postText, imageURL, videoURL)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(
                        postText.trimmingCharacters(in: .whitespaces).isEmpty
                        && imageURL.isEmpty
                        && videoURL.isEmpty
                    )
                }
            }
            .navigationTitle("Create Post")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
