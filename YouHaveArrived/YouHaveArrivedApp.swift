//
//  YouHaveArrivedApp.swift
//  YouHaveArrived
//
//  Created by Steven Duzevich on 15/1/2024.
//

import SwiftUI

@main
struct YouHaveArrivedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: ContentViewViewModel())
        }
    }
}
