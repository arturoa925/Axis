import SwiftUI

struct ContentView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @AppStorage("hasGreeted") private var hasGreeted = false
    @State private var selectedTemplate: WatchTemplatePayload? = nil
    @State private var session: WatchWorkoutSession? = nil
    @State private var completedPayload: WatchCompletedWorkoutPayload? = nil

    private static let transition: AnyTransition = .opacity.combined(
        with: .scale(scale: 0.94, anchor: .center)
    )

    var body: some View {
        ZStack {
            WatchColors.background.ignoresSafeArea()
            if !hasGreeted {
                Greeting {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        hasGreeted = true
                    }
                }
                .transition(Self.transition)
            } else if let completedPayload {
                WorkoutComplete(payload: completedPayload) {
                    connectivity.sendCompletedWorkout(completedPayload)
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self.completedPayload = nil
                        self.session = nil
                    }
                }
                .transition(Self.transition)
            } else if let session {
                StartedWorkout(session: session) { payload in
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self.completedPayload = payload
                    }
                } onCancel: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self.session = nil
                    }
                }
                .transition(Self.transition)
            } else if let selectedTemplate {
                SelectingWorkout(template: selectedTemplate) {
                    let s = WatchWorkoutSession()
                    s.start(template: selectedTemplate)
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self.session = s
                        self.selectedTemplate = nil
                    }
                } onCancel: {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self.selectedTemplate = nil
                    }
                }
                .transition(Self.transition)
            } else {
                WorkoutSelector(templates: connectivity.templates) { template in
                    withAnimation(.easeInOut(duration: 0.35)) {
                        self.selectedTemplate = template
                    }
                }
                .transition(Self.transition)
            }
        }
    }
}
