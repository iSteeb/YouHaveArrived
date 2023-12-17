//
//  YouHaveArrivedApp.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 15/11/2023.
//

import SwiftUI

@main
struct YouHaveArrived_Watch_AppApp: App {
    @WKApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
