//
//  MapView-ViewModel.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import SwiftUI
import MapKit
import UserNotifications

extension MapView {
    @Observable class ViewModel {
        var locationManager: LocationManager = LocationManager()
        var position: MapCameraPosition
        var visibleRegion: MKCoordinateRegion?
        private(set) var availableInteractionmModes: MapInteractionModes
        private(set) var pinLocation: CLLocationCoordinate2D?
        private(set) var fenceRadius: Int64
        var notificationManager = NotificationManager.shared
        private(set) var isPlaceSaved: Bool = false
        private(set) var savedPlaces: SavedPlaces = SavedPlaces(userDefaultsKey: "SAVEDPLACESSTORE")

        init(pinLocation: CLLocationCoordinate2D, fenceRadius: Int64) {
            self.position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pinLocation.latitude, longitude: pinLocation.longitude), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)))
            self.visibleRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pinLocation.latitude, longitude: pinLocation.longitude), span: MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025))
            self.availableInteractionmModes = [.zoom]
            self.pinLocation = pinLocation
            self.fenceRadius = fenceRadius
        }
        
        init() {
            self.position = .userLocation(followsHeading: true, fallback: .automatic)
            self.availableInteractionmModes = [.pan, .zoom]
            self.fenceRadius = 500
        }
        
        func setPin(screenCoord: CGPoint, reader: MapProxy) {
            if (pinLocation == nil) {
                pinLocation = reader.convert(screenCoord, from: .local)
                availableInteractionmModes = [.zoom]
                position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pinLocation!.latitude, longitude: pinLocation!.longitude), span: visibleRegion?.span ?? MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)))
            }
        }
        
        func unsetPin() {
            pinLocation = nil
            fenceRadius = 500
            availableInteractionmModes = [.pan, .zoom]
            position = .userLocation(fallback: .automatic)
        }
        
        func adjustFenceRadius(dragVal: DragGesture.Value) {
            if (pinLocation != nil) {
                let modifier: CGFloat = log2(CGFloat(fenceRadius)) / 75
                //                                    TODO: Fix directional change
                let change = floor(dragVal.translation.width * modifier)
                if (fenceRadius + Int64(change) >= 50) {
                    fenceRadius += Int64(change)
                }
            }
        }
        
        func setNotification() {
            notificationManager.createNotification(c: pinLocation!, r: CLLocationDistance(fenceRadius))
        }
        
        func unsetNotifications() {
            notificationManager.removeNotifications()
            unsetPin()
        }
        
        func savePlaceFromMapView() {
            let placeToSave = SavedPlace(coordinate: pinLocation!, fenceRadius: fenceRadius)
            savedPlaces.addItem(item: placeToSave)
            isPlaceSaved = true
        }
        
        func removeFromSavedPlaces() {
//            TODO: check if in, then remove using removeItem(location: CLLocationCoordinate2D)
            isPlaceSaved = false
        }
    }
}
