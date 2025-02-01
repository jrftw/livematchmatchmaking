//
//  LocationRegionDetector.swift
//  LIVE Match - Matchmaking
//
//  Created by Kevin Doyle Jr. on 1/31/25.
//


//
//  LocationRegionDetector.swift
//  LIVE Match - Matchmaking
//
//  iOS 15.6+, macOS 11.5+
//  Detects user location region to guess local timezone name. 
//  Minimal example: you might add real region logic or just fallback to TimeZone.current.
//

import CoreLocation
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
final class LocationRegionDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var detectedTimeZone: String? = nil
    
    override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }
    
    func requestLocationPermission() {
        #if os(iOS) || os(visionOS)
        manager.requestWhenInUseAuthorization()
        #endif
    }
    
    // MARK: Delegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedWhenInUse ||
           authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Example: Reverse-geocode the region or rely on .current for timezone
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let pm = placemarks?.first, let timeZone = pm.timeZone {
                // e.g. store the official identifier
                self.detectedTimeZone = timeZone.identifier
            } else {
                // fallback
                self.detectedTimeZone = TimeZone.current.identifier
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
        self.detectedTimeZone = TimeZone.current.identifier
    }
}