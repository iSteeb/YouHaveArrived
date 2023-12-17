//
//  SavedPlace.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 25/11/2023.
//

import Foundation
import MapKit

@Observable class SavedPlaces {
    var items: [SavedPlace] = []
    private var KEY: String
    
    init(userDefaultsKey: String) {
        self.KEY = userDefaultsKey
        getFromUserDefaults()
    }
    
    private func saveToUserDefaults() {
        let defaults = UserDefaults.standard
        do {
            let encodedData = try JSONEncoder().encode(items)
            defaults.set(encodedData, forKey: KEY)
        } catch {
            print("Failed to save to UserDefaults")
        }
    }
    
    func getFromUserDefaults() {
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: KEY) as? Data {
            do{
                items = try JSONDecoder().decode([SavedPlace].self, from: savedData)
            } catch {
                print("Failed to get from UserDefaults")
            }
        }
    }
    
    func removeItem(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        saveToUserDefaults()
    }
    
    func removeItem(item: CLLocationCoordinate2D) {
        let index = self.contains(item: item)
        if(index != nil) {
            items.remove(at: index!)
        }
        saveToUserDefaults()
    }
    
    func addItem(coordinate: CLLocationCoordinate2D, fenceRadius: Double, name: String) {
        let item = SavedPlace(coordinate: coordinate, fenceRadius: fenceRadius, name: name)
        items.append(item)
        saveToUserDefaults()
    }
    
    func contains(item: CLLocationCoordinate2D) -> Int? {
        let searchItem = SavedPlace(coordinate: item, fenceRadius: 0.0, name: "")
        return items.firstIndex(of: searchItem)
    }
}

@Observable class SavedPlace: Codable, Equatable, Identifiable {
    static func == (lhs: SavedPlace, rhs: SavedPlace) -> Bool {
        return lhs.longitude == rhs.longitude && lhs.latitude == rhs.latitude
    }
    var id = UUID()
    var name: String
    var latitude: Double
    var longitude: Double
    var fenceRadius: Double
    
    init(coordinate: CLLocationCoordinate2D, fenceRadius: Double, name: String) {
        self.name = name
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.fenceRadius = fenceRadius
    }
}
