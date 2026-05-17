//
//  AxisWatchApp.swift
//  AxisWatch Watch App
//
//  Created by Arturo Ayala on 5/15/26.
//

import SwiftUI

@main
struct AxisWatch_Watch_AppApp: App {
    @State private var connectivity = WatchConnectivityManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(connectivity)
        }
    }
}
