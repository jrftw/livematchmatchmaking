//
//  AdManager.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//
// MARK: AdManager.swift
// iOS 15.6+, visionOS 2.0+ only
// Manages AdMob initialization, banner ads, and interstitials.
// AdMob is not supported on macOS in the same manner. For macOS, either omit ads or provide a no-op fallback.

import SwiftUI

#if os(iOS) || os(visionOS)
import GoogleMobileAds
import UIKit

@available(iOS 15.6, *)
final class AdManager: ObservableObject {
    static let shared = AdManager()
    private init() {}
    
    // Ad Unit IDs (example IDs, replace with real ones in production)
    private let bannerAdUnitID = "ca-app-pub-6815311336585204/4056526045"
    private let interstitialAdUnitID = "ca-app-pub-6815311336585204/5400832657"
    
    @Published var interstitial: GADInterstitialAd?
    
    func configureAdMob() {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        loadInterstitial()
    }
    
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID,
                               request: request) { [weak self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
        }
    }
    
    func showInterstitial(from root: UIViewController) {
        guard let interstitial = interstitial else {
            print("No interstitial is ready, loading a new one…")
            loadInterstitial()
            return
        }
        interstitial.present(fromRootViewController: root)
        loadInterstitial()
    }
}

#else

// MARK: macOS / other platforms fallback
// Provide a no-op manager or do nothing.

@available(macOS 11.5, *)
final class AdManager: ObservableObject {
    static let shared = AdManager()
    private init() {}
    
    // Do nothing
    func configureAdMob() {}
    func loadInterstitial() {}
    func showInterstitial(from: Any) {}
}

#endif
