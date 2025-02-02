//
//  LocationRegionDetector.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//
// MARK: - LocationRegionDetector.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Detects user location region to guess the local timezone name.
// Minimal example: you might add real region logic or just fallback to TimeZone.current.

import CoreLocation
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class LocationRegionDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Properties
    private let manager = CLLocationManager()
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus
    @Published public private(set) var detectedTimeZone: String? = nil
    
    // MARK: - Init
    public override init() {
        print("[LocationRegionDetector] init called. Setting authorizationStatus from manager.")
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        
        print("[LocationRegionDetector] Setting delegate to self.")
        manager.delegate = self
    }
    
    // MARK: - Request Location Permission
    public func requestLocationPermission() {
        print("[LocationRegionDetector] requestLocationPermission called.")
        #if os(iOS) || os(visionOS)
        print("[LocationRegionDetector] iOS or visionOS environment => requesting whenInUse authorization.")
        manager.requestWhenInUseAuthorization()
        #else
        print("[LocationRegionDetector] macOS => No direct requestWhenInUseAuthorization call.")
        #endif
    }
    
    // MARK: - CLLocationManagerDelegate
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("[LocationRegionDetector] locationManagerDidChangeAuthorization triggered.")
        authorizationStatus = manager.authorizationStatus
        print("[LocationRegionDetector] Updated authorizationStatus => \(authorizationStatus.rawValue).")
        
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            print("[LocationRegionDetector] Authorization granted => requesting location.")
            manager.requestLocation()
        } else {
            print("[LocationRegionDetector] Authorization not granted => no location request.")
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("[LocationRegionDetector] didUpdateLocations => received locations count: \(locations.count).")
        guard let location = locations.last else {
            print("[LocationRegionDetector] No valid location found in locations array.")
            return
        }
        print("[LocationRegionDetector] Using location => \(location.coordinate.latitude), \(location.coordinate.longitude).")
        
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            print("[LocationRegionDetector] reverseGeocodeLocation completion. error: \(error?.localizedDescription ?? "none").")
            
            if let pm = placemarks?.first, let timeZone = pm.timeZone {
                self.detectedTimeZone = timeZone.identifier
                print("[LocationRegionDetector] Detected timeZone from placemark => \(timeZone.identifier).")
            } else {
                let fallback = TimeZone.current.identifier
                self.detectedTimeZone = fallback
                print("[LocationRegionDetector] Failed to get placemark timeZone. Fallback => \(fallback).")
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("[LocationRegionDetector] didFailWithError => \(error.localizedDescription)")
        let fallback = TimeZone.current.identifier
        self.detectedTimeZone = fallback
        print("[LocationRegionDetector] Setting detectedTimeZone to fallback => \(fallback).")
    }
}
