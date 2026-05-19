import SwiftUI

struct ContentView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @AppStorage("hasGreeted") private var hasGreeted = false
    @State private var selectedTemplate: WatchTemplatePayload? = nil
    @State private var session: WatchWorkoutSession? = nil
    @State private var completedPayload: WatchCompletedWorkoutPayload? = nil

    var body: some View {
        if !hasGreeted {
            Greeting {
                hasGreeted = true
            }
        } else if let completedPayload {
            WorkoutComplete(payload: completedPayload) {
                connectivity.sendCompletedWorkout(completedPayload)
                self.completedPayload = nil
                self.session = nil
            }
        } else if let session {
            StartedWorkout(session: session) { payload in
                self.completedPayload = payload
            } onCancel: {
                self.session = nil
            }
        } else if let selectedTemplate {
            SelectingWorkout(template: selectedTemplate) {
                let s = WatchWorkoutSession()
                s.start(template: selectedTemplate)
                self.session = s
                self.selectedTemplate = nil
            } onCancel: {
                self.selectedTemplate = nil
            }
        } else {
            WorkoutSelector(templates: connectivity.templates) { template in
                self.selectedTemplate = template
            }
        }
    }
}
