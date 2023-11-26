//
//  MapView.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 15/11/2023.
//

import SwiftUI
import UserNotifications
import MapKit

struct MapView: View {
    @State var viewModel = ViewModel()
    
    var body: some View {
        if (viewModel.notificationManager.isPendingNotifications) {
            VStack {
                Spacer()
                Text("Notification Pending")
                Button(action: {
                    viewModel.unsetNotifications()
                }, label: {
                    Image(systemName: "multiply")
                })
                Spacer()
            }
        } else {
            ZStack {
                MapReader{ reader in
                    Map(position: $viewModel.position, interactionModes: viewModel.availableInteractionmModes)
                    {
                        if let pl = viewModel.pinLocation {
                            Marker("\(viewModel.fenceRadius)m", coordinate: pl)
                        }
                        if let pl = viewModel.pinLocation {
                            MapCircle(center: pl, radius: CLLocationDistance(integerLiteral: viewModel.fenceRadius))
                                .foregroundStyle(.blue.opacity(0.3))
                                .stroke(.blue, lineWidth: 1.0)
                        }
                    }
                    .task {
                        try? await viewModel.locationManager.requestUserAuthorization()
                        try? await viewModel.locationManager.startCurrentLocationUpdates()
                    }
                    .onMapCameraChange { context in
                        viewModel.visibleRegion = context.region
                    }
                    .onTapGesture(perform: { screenCoord in
                        viewModel.setPin(screenCoord: screenCoord, reader: reader)
                    })
                    .gesture(
                        DragGesture(minimumDistance: 0.0)
                            .onChanged { dval in
                                viewModel.adjustFenceRadius(dragVal: dval)
                            }
                    )
                }
                
                if (viewModel.pinLocation != nil) {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.unsetPin()
                            }, label: {
                                Image(systemName: "multiply")
                            })
                            Spacer()
                            Button(action: {
                                viewModel.setNotification()
                            }, label: {
                                Image(systemName: "checkmark")
                            })
                            Spacer()
                            if(viewModel.isPlaceSaved) {
                                Button(action: {
                                    viewModel.removeFromSavedPlaces()
                                }, label: {
                                    Image(systemName: "minus.circle")
                                })
                            } else {
                                Button(action: {
                                    viewModel.savePlaceFromMapView()
                                }, label: {
                                    Image(systemName: "plus.circle")
                                })
                            }
                            Spacer()
                        }
                    }
                    .safeAreaPadding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MapView()
}
