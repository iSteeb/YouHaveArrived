//
//  SavedPlacesView.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 25/11/2023.
//

import SwiftUI

struct SavedPlacesView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(appDelegate.savedPlaces.items) { place in
                    NavigationLink(place.name) {
                        MapView(viewModel: MapView.ViewModel(pinLocation: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), fenceRadius: place.fenceRadius))
                    }
                }
                .onDelete(perform: { indexSet in
                    appDelegate.savedPlaces.removeItem(offsets: indexSet)
                })
            }
        }
    }
}

#Preview {
    SavedPlacesView()
}
