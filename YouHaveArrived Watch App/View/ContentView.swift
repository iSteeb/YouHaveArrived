//
//  ContentView.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 19/1/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State var viewModel: ContentViewViewModel
    
    @FocusState private var pinSetFocused: Bool
    
    var body: some View {
        if (viewModel.isAlarmActive) {
            VStack {
                Spacer()
                Text("Alarm Pending")
                Button(action: {
                    viewModel.backtrack()
                }, label: {
                    Image(systemName: "multiply")
                })
                Spacer()
            }
        } else {
            ZStack {
                MapReader { reader in
                    Map(position: $viewModel.cameraPosition, interactionModes: viewModel.availableInteractionmModes)
                    {
                        if let _ = viewModel.pinCoordinate {
                            Marker("\(viewModel.geofenceRadius!)", coordinate: viewModel.pinCoordinate!)
                        }
                        if let _ = viewModel.pinCoordinate {
                            MapCircle(center: viewModel.pinCoordinate!, radius: CLLocationDistance(integerLiteral: viewModel.geofenceRadius!))
                                .foregroundStyle(.blue.opacity(0.3))
                                .stroke(.blue, lineWidth: 1.0)
                        }
                        UserAnnotation()
                    }
                    .task {
                        try? await viewModel.locationManager.requestUserAuthorization()
                        try? await viewModel.locationManager.startCurrentLocationUpdates()
                    }
                    .onTapGesture(perform: { screenCoord in
                        viewModel.setPin(screenCoord: screenCoord, reader: reader)
                        pinSetFocused = true
                    })
                }
                
                if let _ = viewModel.pinCoordinate {
                    VStack {
                        Spacer()
                        if let _ = viewModel.arrivalTimeDelta {
                            Text("EAT: \(viewModel.arrivalTimeDelta!) mins (\(viewModel.formatEstimatedArrivalTime()))")
                                .focusable()
                                .focused($pinSetFocused)
                                .onChange(of: pinSetFocused, { oldValue, newValue in
                                    if(viewModel.pinCoordinate != nil) {
                                        pinSetFocused = true
                                    }
                                })
                                .digitalCrownRotation(detent: Binding(
                                    get: {
                                        // Convert optional Int? to non-optional Double
                                        viewModel.arrivalTimeDelta.map(Double.init) ?? 0.0
                                    },
                                    set: {
                                        // Convert Double back to optional Int?
                                        viewModel.arrivalTimeDelta = Int($0)
                                    }
                                ), from: 30, through: 1440, by: 1, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
                        } else {
                            Text("")
                                .focusable()
                                .focused($pinSetFocused)
                                .onChange(of: pinSetFocused, { oldValue, newValue in
                                    if(viewModel.pinCoordinate != nil) {
                                        pinSetFocused = true
                                    }
                                })
                                .digitalCrownRotation(detent: Binding(
                                    get: {
                                        // Convert optional Double? to non-optional Double
                                        viewModel.geofenceRadius ?? 0.0
                                    },
                                    set: {
                                        // Update viewModel.geofenceRadius with the optional Double
                                        viewModel.geofenceRadius = $0
                                    }
                                ), from: 250, through: 10000, by: 50, sensitivity: .high, isContinuous: false, isHapticFeedbackEnabled: true) { crownEvent in
                                    viewModel.updateMapCamera(offset: crownEvent.offset)
                                }
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                viewModel.backtrack()
                            }, label: {
                                Image(systemName: "multiply")
                            })
                            Spacer()
                            Button(action: {
                                viewModel.proceed()
                            }, label: {
                                Image(systemName: "checkmark")
                            })
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
    ContentView(viewModel: ContentViewViewModel())
}
