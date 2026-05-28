import SwiftUI

struct WorkoutComplete: View {
    let payload: WatchCompletedWorkoutPayload
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            WatchColors.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── TOP: title + subtitle ──────────────────────────────
                VStack(spacing: 5) {
                    Text("Session Complete")
                        .font(.custom("IstokWeb-Regular", size: 20, relativeTo: .headline))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 10)

                    Text("Check your progress back on the app")
                        .font(.custom("NotoSans-Regular", size: 14))
                        .foregroundStyle(WatchColors.textBrown)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 10)
                .padding(.bottom, 10)

                // ── MIDDLE: elapsed time ───────────────────────────────
                Text(formattedDuration)
                    .font(.system(size: 34, weight: .medium, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom, 6)
                    .accessibilityLabel("Workout duration: \(formattedDuration)")

                // ── BOTTOM: next button ────────────────────────────────
                Button(action: onDismiss) {
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassEffect(in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Done")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 10)
            }
        }
    }

    private var formattedDuration: String {
        let total = Int(max(0, payload.duration))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}

#Preview {
    WorkoutComplete(
        payload: WatchCompletedWorkoutPayload(
            templateName: "Push Day",
            templateID: "1",
            startedAt: Date().addingTimeInterval(-2730),
            duration: 2730,
            exercises: [
                WatchCompletedExercisePayload(name: "Bench Press", completedSets: 3, targetSets: 3, targetReps: 8, orderIndex: 0),
                WatchCompletedExercisePayload(name: "Shoulder Press", completedSets: 3, targetSets: 3, targetReps: 10, orderIndex: 1)
            ]
        ),
        onDismiss: {}
    )
}
