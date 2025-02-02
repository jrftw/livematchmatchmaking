//
//  ImagePicker.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 2/1/25.
//
// MARK: - ImagePicker.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Simple image picker for iOS/visionOS. macOS fallback not implemented here.

#if os(iOS) || os(visionOS)
import SwiftUI
import UIKit

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public struct ImagePicker: UIViewControllerRepresentable {
    
    // MARK: - Binding
    @Binding var image: UIImage?
    
    // MARK: - Init
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    // MARK: - Coordinator
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - UIViewControllerRepresentable
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    // MARK: - Coordinator Class
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        public init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let edited = info[.editedImage] as? UIImage {
                parent.image = edited
            } else if let original = info[.originalImage] as? UIImage {
                parent.image = original
            }
            picker.dismiss(animated: true)
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
#endif
