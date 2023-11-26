//
//  SavedPlacesView-ViewModel.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 26/11/2023.
//

import Foundation
import SwiftUI

extension SavedPlacesView {
    @Observable class ViewModel {
        private(set) var savedPlaces: SavedPlaces = SavedPlaces(userDefaultsKey: "SAVEDPLACESSTORE")
    }
}
