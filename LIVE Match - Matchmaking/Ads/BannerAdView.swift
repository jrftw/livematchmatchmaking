//
//  BannerAdView.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+ only
//  A SwiftUI wrapper around GADBannerView for a bottom banner ad.
//

#if canImport(UIKit)
import SwiftUI
import GoogleMobileAds

@available(iOS 15.6, *)
struct BannerAdView: UIViewRepresentable {
    // Replace with your actual banner ID
    let adUnitID = "ca-app-pub-6815311336585204/4056526045"
    
    func makeUIView(context: Context) -> GADBannerView {
        let bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.adUnitID = adUnitID
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = scene.windows.first,
           let rootVC = window.rootViewController {
            bannerView.rootViewController = rootVC
        }
        
        bannerView.load(GADRequest())
        return bannerView
    }
    
    func updateUIView(_ uiView: GADBannerView, context: Context) {
        // Typically no update needed for banner ads
    }
}
#endif
