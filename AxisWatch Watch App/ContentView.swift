import SwiftUI

struct ContentView: View {
    @Environment(WatchConnectivityManager.self) private var connectivity
    @ObservedObject private var themeManager = WatchThemeManager.shared
    @Environment(\.scenePhase) private var scenePhase
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
        // forces the subtree to rebuild when day/night flips, so every
        // static WatchColors lookup re-evaluates against the new theme
        .id(themeManager.isDarkMode)
        // system-adaptive elements (Materials, etc.) follow the watch's actual
        // appearance setting unless told otherwise — pin them to our custom theme
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                themeManager.refresh()
            }
        }
    }
}
