import SwiftUI
import SwiftData

@main
struct AxisApp: App {
    // 2 long lived objets
    @StateObject private var appState = AppState()
    @StateObject private var connectivityManager = PhoneConnectivityManager()

    var body: some Scene {
        WindowGroup {
            RootView()
            // shared across app
                .environmentObject(appState)
                .environmentObject(connectivityManager)
            // all persistent models
                .modelContainer(for: [
                    Exercise.self,
                    TemplateExercise.self,
                    WorkoutTemplate.self,
                    CompletedExercise.self,
                    CompletedWorkout.self
                ])
        }
    }
}
