//
//  SavedPlacesView.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 25/11/2023.
//

import SwiftUI

struct SavedPlacesView: View {
    @State var viewModel = ViewModel()

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.savedPlaces.savedPlaces) { place in
                    NavigationLink(place.name) {
                        MapView(viewModel: MapView.ViewModel(pinLocation: CLLocationCoordinate2D(latitude: place.latitude, longitude: place.longitude), fenceRadius: place.fenceRadius))
                    }
                }
                .onDelete(perform: { indexSet in
                    viewModel.savedPlaces.removeItem(offsets: indexSet)
                })
            }
        }
    }
}

#Preview {
    SavedPlacesView()
}
