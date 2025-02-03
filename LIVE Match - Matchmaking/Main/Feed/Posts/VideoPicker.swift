// MARK: - VideoPicker.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// A separate file for picking a single video (URL).

import SwiftUI
import PhotosUI

#if os(iOS) || os(visionOS)
@available(iOS 15.0, *)
public struct VideoPicker: UIViewControllerRepresentable {
    @Binding var videoURL: URL?
    
    public init(videoURL: Binding<URL?>) {
        _videoURL = videoURL
    }
    
    public func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .videos
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: VideoPicker
        
        public init(_ parent: VideoPicker) {
            self.parent = parent
        }
        
        public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard let item = results.first,
                  item.itemProvider.hasItemConformingToTypeIdentifier("public.movie")
            else { return }
            
            item.itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { url, _ in
                guard let url = url else { return }
                // The picker copies the video to a temp location.
                // We store that temp URL:
                DispatchQueue.main.async {
                    self.parent.videoURL = url
                }
            }
        }
    }
}
#endif
