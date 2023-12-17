//
//  LocationManager.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import MapKit
import WatchKit



@Observable class LocationManager: NSObject, CLLocationManagerDelegate, WKExtendedRuntimeSessionDelegate {
    private var locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    private var extendedRuntimeSession: WKExtendedRuntimeSession?
    private(set) var isAlarmSet: Bool = false
    var regionLocation: CLCircularRegion?
    
    func requestUserAuthorization() async throws {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startCurrentLocationUpdates() async throws {
        locationManager.startUpdatingLocation()
        for try await locationUpdate in CLLocationUpdate.liveUpdates() {
            guard let location = locationUpdate.location else { return }
            self.currentLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        // Handle the updated location as needed
        print("Updated location: \(location)")
        if((regionLocation?.contains(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))) ?? false) {
            if (extendedRuntimeSession?.state == .running) {
                extendedRuntimeSession?.notifyUser(hapticType: WKHapticType.retry, repeatHandler: { haptic in
                    return 1
                })
            } else {
                WKInterfaceDevice.current().play(.notification)
                endExtendedRuntimeSession()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager did fail with \(error)")
    }
    
    func startExtendedRuntimeSession(minutesFromNow: Int) {
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = self
        
        extendedRuntimeSession?.start(at: Date(timeIntervalSinceNow: TimeInterval(minutesFromNow)))
        print("extended runtime session started now")
    }
    
    func endExtendedRuntimeSession() {
        extendedRuntimeSession?.invalidate()
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        self.isAlarmSet = false
        print("extended runtime session did invalidate with \(reason)")
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        self.isAlarmSet = true
        print("extended runtime session did start")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extended runtime session will expire")
        self.extendedRuntimeSession?.notifyUser(hapticType: WKHapticType.retry, repeatHandler: { haptic in
            return 1
        })
    }
}
