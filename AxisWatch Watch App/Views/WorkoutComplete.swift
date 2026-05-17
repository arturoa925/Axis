import SwiftUI

struct WorkoutComplete: View {
    let payload: WatchCompletedWorkoutPayload
    let onDismiss: () -> Void

    var body: some View {
        Text("Workout Complete")
    }
}
