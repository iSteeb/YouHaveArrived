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
    private var hapticTimer: Timer?
    private var isAlarmFiring: Bool = false
    
    private(set) var isAlarmSet: Bool = false
    
    var fencedRegion: CLCircularRegion?
    
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
        //        print("Updated location: \(location)")
        if (!isAlarmFiring && fencedRegion?.contains(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) ?? false) {
            if (extendedRuntimeSession?.state == .running) {
                print("triggering extended runtime session alarm")
                isAlarmFiring = true
                extendedRuntimeSession?.notifyUser(hapticType: WKHapticType.retry, repeatHandler: { haptic in
                    return 1
                })
            } else if (extendedRuntimeSession?.state == .scheduled) {
                isAlarmFiring = true
                hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    if strongSelf.isAlarmSet {
                        print("triggering haptic timer alarm")
                        WKInterfaceDevice.current().play(.notification)
                    } else {
                        strongSelf.hapticTimer?.invalidate()
                        strongSelf.hapticTimer = nil
                    }
                }
            }
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("location manager did fail with \(error)")
    }
    
    func startExtendedRuntimeSession(minutesFromNow: Int) {
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = self
        
        extendedRuntimeSession?.start(at: Date(timeIntervalSinceNow: TimeInterval(minutesFromNow - 30)))
        print("extended runtime session started now")
        isAlarmSet = true
    }
    
    func endExtendedRuntimeSession() {
        extendedRuntimeSession?.invalidate()
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        print("extended runtime session did invalidate with \(reason)")
        isAlarmSet = false
        isAlarmFiring = false
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extended runtime session did start")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("extended runtime session will expire")
        self.extendedRuntimeSession?.notifyUser(hapticType: WKHapticType.retry, repeatHandler: { haptic in
            return 2
        })
    }
}
