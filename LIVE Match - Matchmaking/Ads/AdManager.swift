//
//  AdManager.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/28/25.
//


// MARK: File: AdManager.swift
// iOS 15.6+ only (AdMob doesn’t support macOS/visionOS in the same manner)
// Manages AdMob initialization, banner ads, and interstitials.

import SwiftUI
import GoogleMobileAds

@available(iOS 15.6, *)
final class AdManager: ObservableObject {
    static let shared = AdManager()
    private init() {}
    
    // Banner & interstitial IDs
    private let bannerAdUnitID = "ca-app-pub-6815311336585204/4056526045"
    private let interstitialAdUnitID = "ca-app-pub-6815311336585204/5400832657"
    
    @Published var interstitial: GADInterstitialAd?
    
    func configureAdMob() {
        // GoogleMobileAds SDK initialization
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
        // After presenting, load another
        loadInterstitial()
    }
}