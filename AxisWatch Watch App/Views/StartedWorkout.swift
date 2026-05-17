import SwiftUI

struct StartedWorkout: View {
    let session: WatchWorkoutSession
    let onComplete: (WatchCompletedWorkoutPayload) -> Void

    var body: some View {
        Text("Started Workout")
    }
}
