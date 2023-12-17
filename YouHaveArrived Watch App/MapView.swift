//
//  MapView.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 15/11/2023.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var appDelegate: AppDelegate
    
    @State var viewModel = ViewModel()
    
    @FocusState private var pinSetFocused: Bool
    
    var body: some View {
        if (viewModel.locationManager.isAlarmSet) {
            VStack {
                Spacer()
                Text("Alarm Pending")
                Button(action: {
                    viewModel.unsetAlarm()
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
//                        if let pl = viewModel.pinLocation {
//                            Marker("\(Int(viewModel.fenceRadius))m", coordinate: pl)
//                        }
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
//                    .onMapCameraChange { context in
//                        viewModel.visibleRegion = context.region
//                    }
                    .onTapGesture(perform: { screenCoord in
                        viewModel.setPin(screenCoord: screenCoord, reader: reader)
                        pinSetFocused = true
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
                        
                        if (!viewModel.isAlarmRegionSet) {
                            Text("DtD: \(Int(viewModel.fenceRadius))m")
                                .focusable()
                                .focused($pinSetFocused)
                                .onChange(of: pinSetFocused, { oldValue, newValue in
                                    if(viewModel.pinLocation != nil) {
                                        pinSetFocused = true
                                    }
                                })
                                .digitalCrownRotation(detent: $viewModel.fenceRadius, from: 250, through: 10000, by: 50, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true) { crownEvent in
                                    viewModel.updateMapCamera(offset: crownEvent.offset)
                                }
                        } else {
                            Text("EAT: \(viewModel.alarmMinutesFromNow) mins (\(viewModel.formatEstimatedArrivalTime()))")
                                .focusable()
                                .focused($pinSetFocused)
                                .onChange(of: pinSetFocused, { oldValue, newValue in
                                    if(viewModel.pinLocation != nil) {
                                        pinSetFocused = true
                                    }
                                })
                                .digitalCrownRotation(detent: $viewModel.alarmMinutesFromNow, from: 30, through: 1440, by: 1, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
                        }
                        
                        HStack {
                            Spacer()
                            
                            if (!viewModel.isAlarmRegionSet) {
                                Button(action: {
                                    viewModel.unsetPin()
                                }, label: {
                                    Image(systemName: "multiply")
                                })
                            } else {
                                Button(action: {
                                    viewModel.unsetAlarmRegion()
                                }, label: {
                                    Image(systemName: "multiply")
                                })
                            }
                            
                            Spacer()
                            
                            if (!viewModel.isAlarmRegionSet) {
                                Button(action: {
                                    viewModel.setAlarmRegion()
                                }, label: {
                                    Image(systemName: "checkmark")
                                })
                            } else {
                                Button(action: {
                                    viewModel.setAlarm()
                                }, label: {
                                    Image(systemName: "checkmark")
                                })
                            }
                            
                            Spacer()
                            if(appDelegate.savedPlaces.contains(item: viewModel.pinLocation!) != nil) {
                                Button(action: {
                                    viewModel.removeFromSavedPlaces(from: appDelegate.savedPlaces)
                                }, label: {
                                    Image(systemName: "minus.circle")
                                })
                            } else {
                                Button(action: {
                                    viewModel.savePlaceFromMapView(to: appDelegate.savedPlaces)
                                }, label: {
                                    Image(systemName: "plus.circle")
                                })
                            }
                            Spacer()
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MapView()
}
