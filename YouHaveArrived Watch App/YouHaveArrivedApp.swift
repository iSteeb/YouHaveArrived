//
//  YouHaveArrivedApp.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 15/11/2023.
//

import SwiftUI

@main
struct YouHaveArrived_Watch_AppApp: App {
    @WKExtensionDelegateAdaptor private var extensionDelegate: ContentViewViewModel
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: extensionDelegate)
        }
    }
}
