//
//  SavedPlace.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 25/11/2023.
//

import Foundation
import MapKit

class SavedPlaces {
    var savedPlaces: [SavedPlace] = []
    private var KEY: String
    
    init(userDefaultsKey: String) {
        self.KEY = userDefaultsKey
        getFromUserDefaults()
    }
    
    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        do {
            let encodedData = try JSONEncoder().encode(savedPlaces)
            defaults.set(encodedData, forKey: KEY)
        } catch {
            print("Failed to save to UserDefaults")
        }
    }
    
    func getFromUserDefaults() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: KEY) as? Data {
            do{
                savedPlaces = try JSONDecoder().decode([SavedPlace].self, from: savedData)
            } catch {
                print("Failed to get from UserDefaults")
            }
        }
    }
    
    func removeItem(offsets: IndexSet) {
        savedPlaces.remove(atOffsets: offsets)
        saveToUserDefaults()
    }
    
    func removeItem(location: CLLocationCoordinate2D) {
        
    }
    
    func addItem(item: SavedPlace) {
        savedPlaces.append(item)
        saveToUserDefaults()
    }
    
    
}

struct SavedPlace: Codable, Equatable, Identifiable {
    static func == (lhs: SavedPlace, rhs: SavedPlace) -> Bool {
        return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
    }
    var id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var fenceRadius: Int64
    
    init(coordinate: CLLocationCoordinate2D, fenceRadius: Int64) {
        let geocoder = CLGeocoder()
        var name: String?
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, error in
            guard let placeMark = placemarks?.first else { return }
            // Country
            if let country = placeMark.country {
                name = country
            }
            // City
            if let city = placeMark.locality {
                name = city
            }
            // Street address
            if let street = placeMark.thoroughfare {
                name = street
            }
            if let locationName = placeMark.name {
                name = locationName
            }
        }
        self.name = name ?? "Latitude: \(coordinate.latitude) Longitude: \(coordinate.longitude)"
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.fenceRadius = fenceRadius
    }
}
