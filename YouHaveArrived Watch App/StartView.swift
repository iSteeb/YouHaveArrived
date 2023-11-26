//
//  StartView.swift
//  YouHaveArrived Watch App
//
//  Created by Steven Duzevich on 25/11/2023.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack{
            NavigationLink("View Map") {
                MapView()
            }
            NavigationLink("Saved Places") {
                SavedPlacesView()
            }
        }
    }
}

#Preview {
    StartView()
}
