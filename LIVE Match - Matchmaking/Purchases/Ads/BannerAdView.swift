//
//  BannerAdView.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//

// MARK: File: BannerAdView.swift
// iOS 15.6+ only
// A SwiftUI wrapper around GADBannerView for a non-intrusive bottom banner ad.

#if canImport(UIKit) // Exclude for macOS/visionOS builds
import SwiftUI
import GoogleMobileAds

@available(iOS 15.6, *)
struct BannerAdView: UIViewRepresentable {
    let adUnitID = "ca-app-pub-6815311336585204/4056526045"
    
    func makeUIView(context: Context) -> GADBannerView {
        let banner = GADBannerView(adSize: GADAdSizeBanner)
        banner.adUnitID = adUnitID
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if let root = scene.windows.first?.rootViewController {
                banner.rootViewController = root
            }
        }
        
        banner.load(GADRequest())
        return banner
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // Update as needed, typically not used for banner ads
    }
}
#endif
