//
//  ShareExtensionView.swift
//  Share from Apple Maps
//
//  Created by Steven Duzevich on 16/1/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct ShareExtensionView: View {
    @State private var latitude: Double?
    @State private var longitude: Double?
    @State private var showExporter = false
    @State private var guideLocations: [[String: Any]] = []
    
    init(latitude: Double?, longitude: Double?) {
        _latitude = State(initialValue: latitude)
        _longitude = State(initialValue: longitude)
    }
    
    var body: some View {
        if (latitude != nil && longitude != nil) {
            VStack {
                Text("A valid location has been shared.")
                HStack {
                    Button(action: {
                        close(message: "proceed")
                    }, label: {
                        Text("Proceed")
                    })
                    Button(action: {
                        close(message: "cancel")
                    }, label: {
                        Text("Cancel")
                    })                    
                }
            }
        } else {
            VStack {
                Text("An invalid location has been shared.")
                Button(action: {
                    close(message: "cancel")
                }, label: {
                    Text("Cancel")
                })
            }
        }
    }
    
    func close(message: String) {
        NotificationCenter.default.post(name: NSNotification.Name(message), object: nil)
    }
}
