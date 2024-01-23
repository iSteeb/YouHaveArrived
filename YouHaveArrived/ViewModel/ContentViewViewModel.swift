//
//  ContentViewViewModel.swift
//  YouHaveArrived
//
//  Created by Steven Duzevich on 19/1/2024.
//

import Foundation
import WatchConnectivity
import MapKit
import SwiftUI

@Observable class ContentViewViewModel: NSObject {
    private var session: WCSession = .default
    
    var cameraPosition: MapCameraPosition = .automatic
    
    private(set) var pinCoordinate: CLLocationCoordinate2D?
    private(set) var geofenceRadius: Double?
    private(set) var arrivalTimeDelta: Int?
    
    override init() {
        super.init()
        self.session.delegate = self
        self.session.activate()
    }
    
    
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "duzieyouhavearrived" else {
            return
        }
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            print("Invalid URL")
            return
        }
        
        guard let action = components.host, action == "set-pin-to-coordinate" else {
            print("Unknown action requested")
            return
        }
        
        guard let latitudeString = components.queryItems?.first(where: { $0.name == "latitude" })?.value else {
            print("No latitude found")
            return
        }
        
        guard let longitudeString = components.queryItems?.first(where: { $0.name == "longitude" })?.value else {
            print("No longitude found")
            return
        }
        
        guard let latitude = Double(latitudeString), let longitude = Double(longitudeString) else {
            print("Invalid coordinates retrieved")
            return
        }
        
        setPinCoordinate(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        print("Pin coordinate updated to \(String(describing: pinCoordinate))")
    }
    
    func adjustAlarmVariable(up: Bool) {
        if let _ = arrivalTimeDelta {
            if up {
                arrivalTimeDelta! += 1
            } else {
                arrivalTimeDelta! -= 1
            }
        } else {
            if up {
                geofenceRadius! += 50
            } else {
                geofenceRadius! -= 50
            }
        }
    }
    
    func proceed() {
        if let _ = arrivalTimeDelta {
            let data = ["arrivalTimeDelta": arrivalTimeDelta!, "geofenceRadius": geofenceRadius!, "pinCoordinateLatitude": pinCoordinate!.latitude, "pinCoordinateLongitude": pinCoordinate!.longitude] as [String: Any]
            updateApplicationContext(data: data)
        } else {
            arrivalTimeDelta = 30
        }
    }
    
    func setPinCoordinate(coordinate: CLLocationCoordinate2D) {
        pinCoordinate = coordinate
        geofenceRadius = 250
        cameraPosition = .automatic
    }
    
    func setPinCoordinateFromURL(input: String) {
        let pattern = "&ll=([-0-9.]+),([-0-9.]+)"
        
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: [])
            let range = NSRange(location: 0, length: input.utf16.count)
            if let match = regex.firstMatch(in: input, options: [], range: range) {
                let latitudeRange = Range(match.range(at: 1), in: input)!
                let longitudeRange = Range(match.range(at: 2), in: input)!
                
                let latitude = Double(input[latitudeRange])!
                let longitude = Double(input[longitudeRange])!
                
                setPinCoordinate(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            }
        } catch {
            print("Error creating regex: \(error.localizedDescription)")
        }
    }
    
    func backtrack() {
        if let _ = arrivalTimeDelta {
            arrivalTimeDelta = nil
        } else {
            geofenceRadius = nil
            pinCoordinate = nil
        }
    }
}

extension ContentViewViewModel: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("The session has completed activation.")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("The session has become inactive.")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("The session has deactivated.")
    }
    
    func updateApplicationContext(data: [String: Any]) {
        
        let context: [String: Any] = ["context": data]
        do {
            print("Attempting to send \(context)")
            try session.updateApplicationContext(context)
        } catch {
            print(error.localizedDescription)
        }
    }
}
