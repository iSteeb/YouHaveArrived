//
//  AppDelegate.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import SwiftUI
import WatchKit

class AppDelegate: NSObject, WKApplicationDelegate, ObservableObject {
    var savedPlaces: SavedPlaces = SavedPlaces(userDefaultsKey: "SAVEDPLACESSTORE")
    
    func applicationDidFinishLaunching() {
        print("application did finish launching")
    }
    
    func applicationDidBecomeActive() {
        print("application did become active")
    }
    
    func applicationWillResignActive() {
        print("application will resign active")
    }
    
    func applicationDidEnterBackground() {
        print("application did enter background")
    }
    
    func applicationWillEnterForeground() {
        print("application will enter foreground")
    }
}
