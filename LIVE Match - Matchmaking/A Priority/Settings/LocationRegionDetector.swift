// MARK: LocationRegionDetector.swift
// iOS 15.6+, macOS 11.5+, visionOS 2.0+
// Detects user location region to guess the local timezone name.

import CoreLocation
import SwiftUI

@available(iOS 15.6, macOS 11.5, visionOS 2.0, *)
public final class LocationRegionDetector: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published public private(set) var authorizationStatus: CLAuthorizationStatus
    @Published public private(set) var detectedTimeZone: String? = nil
    
    public override init() {
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
    }
    
    public func requestLocationPermission() {
        #if os(iOS) || os(visionOS)
        manager.requestWhenInUseAuthorization()
        #endif
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            manager.requestLocation()
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            if let pm = placemarks?.first, let timeZone = pm.timeZone {
                self.detectedTimeZone = timeZone.identifier
            } else {
                self.detectedTimeZone = TimeZone.current.identifier
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.detectedTimeZone = TimeZone.current.identifier
    }
}
