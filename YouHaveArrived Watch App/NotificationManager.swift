//
//  NotificationManager.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 24/11/2023.
//

import Foundation
import UserNotifications
import MapKit

@Observable class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    private(set) var isPendingNotifications = false
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }

    // Handle the scenario when a notification is received while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
        updatePendingNotificationsBool()
    }
    
    func updatePendingNotificationsBool() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            self.isPendingNotifications = requests.isEmpty ? false : true
        }
    }
    
    func getPendingNotificationsBool() -> Bool {
        print("checking")
        updatePendingNotificationsBool()
        return isPendingNotifications
    }
    
    func createNotification(c: CLLocationCoordinate2D, r: CLLocationDistance) {
        let center = UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "You are arriving!"
        content.sound = UNNotificationSound.default
        let region = CLCircularRegion(center: c, radius: r, identifier: "GeoFence")
        region.notifyOnEntry = true
        region.notifyOnExit = false
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        let request = UNNotificationRequest(identifier: "ArrivalAlarm", content: content, trigger: trigger)
        center.add(request) { error in
            if let error = error {
                print(error)
            } else {
                print("Notification added")
            }
        }
        updatePendingNotificationsBool()
    }
    
    func removeNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        updatePendingNotificationsBool()
    }
}
