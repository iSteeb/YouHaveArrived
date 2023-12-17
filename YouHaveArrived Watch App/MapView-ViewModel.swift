//
//  MapView-ViewModel.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import SwiftUI
import MapKit

extension MapView {
    @Observable class ViewModel {
        private(set) var isPlaceSaved: Bool
        private(set) var availableInteractionmModes: MapInteractionModes
        private(set) var pinLocation: CLLocationCoordinate2D?
        private(set) var isAlarmRegionSet: Bool = false
        private(set) var isAlarmSet: Bool = false
        
        var locationManager: LocationManager = LocationManager()
        var position: MapCameraPosition = .userLocation(fallback: .automatic)
        var fenceRadius: Double
        var alarmMinutesFromNow: Int = 30

        init(pinLocation: CLLocationCoordinate2D, fenceRadius: Double) {
            self.availableInteractionmModes = []
            self.pinLocation = pinLocation
            self.fenceRadius = fenceRadius
            self.isPlaceSaved = true
            updateMapCamera(offset: fenceRadius)
        }
        
        init() {
            self.availableInteractionmModes = [.pan, .zoom]
            self.fenceRadius = 250
            self.isPlaceSaved = false
        }
        
        func updateMapCamera(offset: Double) {
            fenceRadius = offset
            position = .region(MKCoordinateRegion(center: pinLocation!, latitudinalMeters: fenceRadius * 3, longitudinalMeters: fenceRadius * 3))
        }
        
        func setPin(screenCoord: CGPoint, reader: MapProxy) {
            if (pinLocation == nil) {
                pinLocation = reader.convert(screenCoord, from: .local)
                availableInteractionmModes = []
                updateMapCamera(offset: fenceRadius)
            }
        }
        
        func unsetPin() {
            pinLocation = nil
            fenceRadius = 250
            availableInteractionmModes = [.pan, .zoom]
            position = .userLocation(fallback: .automatic)
        }
        
        func adjustFenceRadius(dragVal: DragGesture.Value) {
            if (pinLocation != nil) {
                let modifier: CGFloat = log2(CGFloat(fenceRadius)) / 75
                let change = floor(dragVal.translation.width * modifier)
                if (fenceRadius + change >= 50) {
                    fenceRadius += change
                }
            }
        }
        
        func setAlarmRegion() {
            isAlarmRegionSet = true
        }
        
        func unsetAlarmRegion() {
            isAlarmRegionSet = false
            alarmMinutesFromNow = 30
        }
        
        func formatEstimatedArrivalTime() -> String {
            let currentDate = Date()
            let futureDate = Calendar.current.date(byAdding: .minute, value: alarmMinutesFromNow, to: currentDate)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            let timeString = dateFormatter.string(from: futureDate!)
            if let days = Calendar.current.dateComponents([.day], from: Calendar.current.startOfDay(for: currentDate), to: futureDate!).day, days > 0 {
                return "\(timeString) +\(days)"
            } else {
                return timeString
            }
        }
        
        func setAlarm() {
            locationManager.startExtendedRuntimeSession(minutesFromNow: alarmMinutesFromNow)
            locationManager.fencedRegion = CLCircularRegion(center: pinLocation!, radius: CLLocationDistance(fenceRadius), identifier: "Fence")
        }
        
        func unsetAlarm() {
            unsetPin()
            unsetAlarmRegion()
            locationManager.endExtendedRuntimeSession()
        }
        
        func savePlaceFromMapView(to: SavedPlaces) {
            var name: String = "Lat: \(round(pinLocation!.latitude * 1000) / 1000.0), Lon:\(round(pinLocation!.longitude * 1000) / 1000.0)"
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(CLLocation(latitude: pinLocation!.latitude, longitude: pinLocation!.longitude)) {placemarks, error in
                if let placeMark = placemarks?.first {
                    name = placeMark.name!
                    to.addItem(coordinate: self.pinLocation!, fenceRadius: self.fenceRadius, name: name)
                    self.isPlaceSaved = (to.contains(item: self.pinLocation!) != nil)
                    print(name)
                }
            }
        }
        
        func removeFromSavedPlaces(from: SavedPlaces) {
            from.removeItem(item: pinLocation!)
            isPlaceSaved = (from.contains(item: pinLocation!) != nil)
        }
    }
}
