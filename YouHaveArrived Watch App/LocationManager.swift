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
        if (!isAlarmFiring && fencedRegion?.contains(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) ?? false) {
            if (extendedRuntimeSession?.state == .running) {
                print("Triggering ExtendedRuntimeSession alarm")
                isAlarmFiring = true
                extendedRuntimeSession?.notifyUser(hapticType: WKHapticType.retry, repeatHandler: { haptic in
                    return 1
                })
            } else if (extendedRuntimeSession?.state == .scheduled) {
                isAlarmFiring = true
                hapticTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                    guard let strongSelf = self else { return }
                    if strongSelf.isAlarmSet {
                        print("Triggering haptic timer alarm")
                        strongSelf.endExtendedRuntimeSession()
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
        print("LocationManager failed with error: \(error)")
    }
    
    func startExtendedRuntimeSession(minutesFromNow: Int) {
        extendedRuntimeSession = WKExtendedRuntimeSession()
        extendedRuntimeSession?.delegate = self
        let startTime = Date.now + Double(minutesFromNow * 60)
        extendedRuntimeSession?.start(at: startTime)
        print("ExtendedRuntimeSession scheduled for \(startTime)")
        isAlarmSet = true
    }
    
    func endExtendedRuntimeSession() {
        extendedRuntimeSession?.invalidate()
    }
    
    func extendedRuntimeSession(_ extendedRuntimeSession: WKExtendedRuntimeSession, didInvalidateWith reason: WKExtendedRuntimeSessionInvalidationReason, error: Error?) {
        print("ExtendedRuntimeSession invalidated with reason: \(reason)")
        isAlarmSet = false
        isAlarmFiring = false
    }
    
    func extendedRuntimeSessionDidStart(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("ExtendedRuntimeSession started")
    }
    
    func extendedRuntimeSessionWillExpire(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
        print("ExtendedRuntimeSession expiring")
        self.extendedRuntimeSession?.notifyUser(hapticType: WKHapticType.retry, repeatHandler: { haptic in
            return 2
        })
    }
}
