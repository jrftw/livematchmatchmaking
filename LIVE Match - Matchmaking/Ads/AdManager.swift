//
//  AdManager.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, visionOS 2.0+ only
//  Manages AdMob initialization, banner ads, and interstitials.
//

import SwiftUI

#if os(iOS) || os(visionOS)
import GoogleMobileAds
import UIKit

@available(iOS 15.6, *)
final class AdManager: ObservableObject {
    static let shared = AdManager()
    private init() {}
    
    // Replace with *your* real Ad Unit IDs
    private let bannerAdUnitID = "ca-app-pub-6815311336585204/4056526045"
    private let interstitialAdUnitID = "ca-app-pub-6815311336585204/5400832657"
    
    @Published var interstitial: GADInterstitialAd?
    
    func configureAdMob() {
        GADMobileAds.sharedInstance().start { status in
            print("[AdManager] AdMob started: \(status.adapterStatusesByClassName)")
        }
        loadInterstitial()
    }
    
    func loadInterstitial() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: interstitialAdUnitID, request: request) { [weak self] ad, error in
            if let error = error {
                print("[AdManager] Failed to load interstitial: \(error.localizedDescription)")
                return
            }
            self?.interstitial = ad
            print("[AdManager] Interstitial loaded.")
        }
    }
    
    func showInterstitial(from root: UIViewController) {
        guard let interstitial = interstitial else {
            print("[AdManager] No interstitial ready. Loading new one.")
            loadInterstitial()
            return
        }
        interstitial.present(fromRootViewController: root)
        loadInterstitial()
    }
}

#else

// MARK: - macOS / other platforms fallback
@available(macOS 11.5, *)
final class AdManager: ObservableObject {
    static let shared = AdManager()
    private init() {}
    
    // Provide no-op implementations for non-iOS
    func configureAdMob() {}
    func loadInterstitial() {}
    func showInterstitial(from: Any) {}
}

#endif
