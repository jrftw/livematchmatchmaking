// MARK: - MultiImagePicker.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A standalone multi-image picker returning [UIImage].

import SwiftUI
import PhotosUI

#if os(iOS) || os(visionOS)
@available(iOS 15.0, *)
public struct MultiImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    let selectionLimit: Int
    
    public init(images: Binding<[UIImage]>, selectionLimit: Int = 5) {
        _images = images
        self.selectionLimit = selectionLimit
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = selectionLimit
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: MultiImagePicker
        public init(parent: MultiImagePicker) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            for item in results {
                if item.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    item.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                        guard let self = self, let uiImage = image as? UIImage else { return }
                        DispatchQueue.main.async {
                            self.parent.images.append(uiImage)
                        }
                    }
                }
            }
        }
    }
}
#endif
