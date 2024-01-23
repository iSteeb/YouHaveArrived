//
//  ContentViewViewModel.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 19/1/2024.
//

import Foundation
import SwiftUI
import MapKit
import WatchConnectivity

@Observable class ContentViewViewModel: NSObject {
    private var session: WCSession = .default

    //    @AppStorage("SAVED_GEOFENCES") var savedGeofences: String = "Default Value"
    private(set) var locationManager: LocationManager = LocationManager()

    var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    private(set) var availableInteractionmModes: MapInteractionModes = [.pan, .zoom]
    
    private(set) var pinCoordinate: CLLocationCoordinate2D?
    var geofenceRadius: Double?
    var arrivalTimeDelta: Int?
    private(set) var isAlarmActive: Bool = false
    
    override init() {
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    func setPin(screenCoord: CGPoint, reader: MapProxy) {
        pinCoordinate = reader.convert(screenCoord, from: .local)
        geofenceRadius = 250
        availableInteractionmModes = []
        updateMapCamera(offset: geofenceRadius!)
    }
    
    func proceed() {
        if let _ = arrivalTimeDelta {
            if !isAlarmActive {
                locationManager.fencedRegion = CLCircularRegion(center: pinCoordinate!, radius: CLLocationDistance(geofenceRadius!), identifier: "Geofence")
                locationManager.startExtendedRuntimeSession(minutesFromNow: arrivalTimeDelta! - 30)
                isAlarmActive = true
            }
        } else {
            arrivalTimeDelta = 30
        }
    }
    
    func backtrack() {
        if isAlarmActive {
            locationManager.endExtendedRuntimeSession()
            isAlarmActive = false
            arrivalTimeDelta = nil
            geofenceRadius = nil
            pinCoordinate = nil
            availableInteractionmModes = [.pan, .zoom]
        } else if let _ = arrivalTimeDelta {
            arrivalTimeDelta = nil
        } else {
            geofenceRadius = nil
            pinCoordinate = nil
            availableInteractionmModes = [.pan, .zoom]
        }
    }
    
    func updateMapCamera(offset: Double) {
        geofenceRadius = offset
        cameraPosition = .region(MKCoordinateRegion(center: pinCoordinate!, latitudinalMeters: geofenceRadius! * 3, longitudinalMeters: geofenceRadius! * 3))
    }
    
    func adjustgeofenceRadius(dragVal: DragGesture.Value) {
        if (pinCoordinate != nil) {
            let modifier: CGFloat = log2(CGFloat(geofenceRadius!)) / 75
            let change = floor(dragVal.translation.width * modifier)
            if (geofenceRadius! + change >= 50) {
                geofenceRadius! += change
            }
        }
    }
    
    func formatEstimatedArrivalTime() -> String {
        let currentDate = Date()
        let futureDate = Calendar.current.date(byAdding: .minute, value: arrivalTimeDelta!, to: currentDate)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeString = dateFormatter.string(from: futureDate!)
        if let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: currentDate), to: futureDate!).day, days > 0 {
            return "\(timeString) +\(days)"
        } else {
            return timeString
        }
    }
}

extension ContentViewViewModel: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Error activating WCSession: \(error.localizedDescription)")
        } else {
            print("WCSession activation completed successfully")
        }
    }
    
    internal func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async { [self] in
            if let applicationContext = applicationContext["context"] as? [String : Any] {
                if let latitude = applicationContext["pinCoordinateLatitude"] as? Double, let longitude = applicationContext["pinCoordinateLongitude"] as? Double {
                    self.pinCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                self.geofenceRadius = applicationContext["geofenceRadius"] as? Double
                self.arrivalTimeDelta = applicationContext["arrivalTimeDelta"] as? Int
                print("Updated pinCoordinate to \(String(describing: pinCoordinate)), geofenceRadius to \(String(describing: geofenceRadius)), arrivalTimeDelta to \(String(describing: arrivalTimeDelta))")
            } else {
                print("Malformed message received")
            }
        }
    }
}

extension ContentViewViewModel: WKExtensionDelegate {
    func handle(_ extendedRuntimeSession: WKExtendedRuntimeSession) {
//        TODO: WTF?
        print("handling extended runtime session delayed start")
        self.session.delegate = self
    }
}
