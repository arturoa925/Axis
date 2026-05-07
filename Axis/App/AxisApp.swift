import SwiftUI
import SwiftData

@main
struct AxisApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
                .modelContainer(for: [
                    Exercise.self,
                    TemplateExercise.self,
                    WorkoutTemplate.self,
                    ActiveExercise.self,
                    ActiveWorkout.self,
                    CompletedExercise.self,
                    CompletedWorkout.self
                ])
        }
    }
}
