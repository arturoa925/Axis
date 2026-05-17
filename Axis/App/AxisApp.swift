import SwiftUI
import SwiftData

@main
struct AxisApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var connectivityManager = PhoneConnectivityManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .environmentObject(connectivityManager)
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
