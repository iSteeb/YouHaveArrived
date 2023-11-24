//
//  AppDelegate.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import SwiftUI
import WatchKit
import UserNotifications

class AppDelegate: NSObject, WKApplicationDelegate {
    func applicationDidFinishLaunching() {
        NotificationManager.shared.requestAuthorization()
    }
    
    func applicationDidBecomeActive() {
        NotificationManager.shared.updatePendingNotificationsBool()
    }
}
