

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
