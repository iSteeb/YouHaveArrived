//
//  LocationManager.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import MapKit


@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    var location: CLLocation? = nil
    
    func requestUserAuthorization() async throws {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() async throws {
        for try await locationUpdate in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdate.location else { return }

            self.location = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        // Handle the updated location as needed
        print("Updated location: \(location)")
    }
}
