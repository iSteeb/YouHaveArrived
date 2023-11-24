//
//  ContentView-ViewModel.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import SwiftUI
import MapKit
import UserNotifications

extension ContentView {
    @Observable class ViewModel {
        var locationManager = LocationManager()
        var position: MapCameraPosition = .userLocation(followsHeading: true, fallback: .automatic)
        var visibleRegion: MKCoordinateRegion?
        
        private(set) var availableInteractionmModes:MapInteractionModes = [.pan, .zoom]

        private(set) var pinLocation :CLLocationCoordinate2D? = nil
        private(set) var circleRadius: Int64  = 500
        
        func setPin(screenCoord: CGPoint, reader: MapProxy) {
            if (pinLocation == nil) {
                pinLocation = reader.convert(screenCoord, from: .local)
                availableInteractionmModes = [.zoom]
                position = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pinLocation!.latitude, longitude: pinLocation!.longitude), span: visibleRegion?.span ?? MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)))
            }
        }
        
        func removePin() {
            pinLocation = nil
            circleRadius = 500
            availableInteractionmModes = [.pan, .zoom]
            position = .userLocation(fallback: .automatic)
        }
        
        func setFence(dragVal: DragGesture.Value) {
            if (pinLocation != nil) {
                //                                    TODO: Make the change speed grow as the size grows
                //                                    TODO: Fix directional change
                let change = floor(dragVal.translation.width / 10)
                if (circleRadius + Int64(change) >= 50) {
                    circleRadius += Int64(change)
                }
            }
        }
        
        func setNotification() {
            NotificationManager.shared.createNotification(c: pinLocation!, r: CLLocationDistance(circleRadius))
        }
        
        func unsetNotifications() {
            NotificationManager.shared.removeNotifications()
            removePin()
        }
    }
}
