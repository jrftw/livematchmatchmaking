//
//  ImagePicker.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+, visionOS 2.0+
//  A simple image picker with editing enabled for iOS/iPadOS and visionOS.
//  For macOS, this file is excluded or you can provide a separate NSOpenPanel approach.
//

import SwiftUI

// MARK: - iOS/iPadOS & visionOS Implementation
// UIKit is only available on iOS and visionOS (which supports UIKit).
// We exclude macOS because macOS does not have UIImagePickerController.

#if os(iOS) || os(visionOS)
import UIKit

public struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    public init(image: Binding<UIImage?>) {
        self._image = image
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // No update logic needed
    }
    
    // MARK: Coordinator
    public final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

// MARK: - macOS Fallback (Optional)
/*
 For macOS, UIKit is unavailable.
 If you need an image picker on macOS, you can implement an NSOpenPanel approach here,
 or simply leave this file out of macOS targets.
 
 #if os(macOS)
 import AppKit

 public struct ImagePicker: View {
     @Binding var image: NSImage?
     ...
     // Use an NSOpenPanel or similar approach
 }
 #endif
*/
