//
//  ContentView.swift
//  YouHaveArrived
//
//  Created by Steven Duzevich on 15/1/2024.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import MapKit
import WatchConnectivity

struct ContentView: View {
    @State var viewModel: ContentViewViewModel
    var body: some View {
        VStack {
            Text("Title")
                .onOpenURL { incomingURL in
                    print("App was opened via URL: \(incomingURL)")
                    viewModel.handleIncomingURL(incomingURL)
                }
            if viewModel.pinCoordinate != nil {
                MapReader{ reader in
                    Map(position: $viewModel.cameraPosition, interactionModes: [.pan, .zoom])
                    {
                        if let _ = viewModel.pinCoordinate {
                            Marker("\(viewModel.geofenceRadius!)", coordinate: viewModel.pinCoordinate!)
                        }
                        if let _ = viewModel.pinCoordinate {
                            MapCircle(center: viewModel.pinCoordinate!, radius: CLLocationDistance(integerLiteral: viewModel.geofenceRadius!))
                                .foregroundStyle(.blue.opacity(0.3))
                                .stroke(.blue, lineWidth: 1.0)
                        }
                    }
                }
                HStack {
                    Button(action: {
                        viewModel.backtrack()
                    }, label: {
                        Image(systemName: "multiply")
                    })
                    Button(action: {
                        viewModel.adjustAlarmVariable(up: true)
                    }, label: {
                        Image(systemName: "plus")
                    })
                    Button(action: {
                        viewModel.adjustAlarmVariable(up: false)
                    }, label: {
                        Image(systemName: "minus")
                    })
                    Button(action: {
                        viewModel.proceed()
                    }, label: {
                        Image(systemName: "checkmark")
                    })
                    Text("\(viewModel.pinCoordinate?.latitude ?? 0)")
                    if viewModel.arrivalTimeDelta != nil {
                        Text("\(viewModel.arrivalTimeDelta!)")
                    }
                }
            } else {
                PasteButton(payloadType: URL.self) { urls in
                    guard let first = urls.first else { return }
                    let mapURL = first.absoluteString
                    viewModel.setPinCoordinateFromURL(input: mapURL)
                }
            }
        }
    }
}

#Preview {
    ContentView(viewModel: ContentViewViewModel())
}
