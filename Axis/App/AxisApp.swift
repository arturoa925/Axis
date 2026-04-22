//
//  AxisApp.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import SwiftUI

@main
struct AxisApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }
}
