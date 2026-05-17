import SwiftUI

struct WorkoutSelector: View {
    let templates: [WatchTemplatePayload]
    let onStart: (WatchTemplatePayload) -> Void

    var body: some View {
        Text("Workout Selector")
    }
}

#Preview {
    WorkoutSelector(templates: []) { _ in }
}
