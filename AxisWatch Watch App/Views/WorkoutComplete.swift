import SwiftUI

struct WorkoutComplete: View {
    let payload: WatchCompletedWorkoutPayload
    let onDismiss: () -> Void

    @State private var animateCheck = false
    @State private var animateTitle = false
    @State private var animateDuration = false
    @State private var animateButton = false

    var body: some View {
        ZStack {
            WatchColors.background.ignoresSafeArea()

            VStack(spacing: 0) {

                // ── TOP: checkmark + title + subtitle ──────────────────
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(Color(hex: "#315BFF"))
                        .opacity(animateCheck ? 1 : 0)
                        .scaleEffect(animateCheck ? 1 : 0.3)
                        .animation(.spring(response: 0.55, dampingFraction: 0.55), value: animateCheck)
                        .padding(.bottom, 2)

                    Text("Session Complete")
                        .font(.custom("IstokWeb-Regular", size: 20, relativeTo: .headline))
                        .foregroundStyle(WatchColors.textBlack)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 6)

                    Text("Check your progress back on the app")
                        .font(.custom("NotoSans-Regular", size: 14, relativeTo: .caption))
                        .foregroundStyle(WatchColors.textBrown)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 10)
                }
                .opacity(animateTitle ? 1 : 0)
                .offset(y: animateTitle ? 0 : 8)
                .animation(.spring(response: 0.5, dampingFraction: 0.78), value: animateTitle)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Session Complete. Check your progress back on the app. Workout duration: \(spokenDuration).")
                .accessibilityAddTraits(.isHeader)

                // ── MIDDLE: elapsed time ───────────────────────────────
                Text(formattedDuration)
                    .font(.system(.largeTitle, weight: .medium).monospacedDigit())
                    .foregroundStyle(WatchColors.textBlack)
                    .opacity(animateDuration ? 1 : 0)
                    .scaleEffect(animateDuration ? 1 : 0.85)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateDuration)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .padding(.bottom, 6)
                    .accessibilityHidden(true)

                // ── BOTTOM: next button ────────────────────────────────
                Button(action: onDismiss) {
                    Image(systemName: "arrow.right")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 40, height: 40)
                        .glassEffect(in: Circle())
                }
                .buttonStyle(WatchLivelyButtonStyle())
                .opacity(animateButton ? 1 : 0)
                .scaleEffect(animateButton ? 1 : 0.6)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateButton)
                .accessibilityLabel("Done")
                .accessibilityHint("Returns to your routine list")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 10)
            }
        }
        .onAppear {
            animateCheck = true
            animateTitle = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.25)) { animateDuration = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.45)) { animateButton = true }
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

    private var spokenDuration: String {
        let total = Int(max(0, payload.duration))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        var parts: [String] = []
        if h > 0 { parts.append("\(h) hour\(h == 1 ? "" : "s")") }
        if m > 0 { parts.append("\(m) minute\(m == 1 ? "" : "s")") }
        if s > 0 || parts.isEmpty { parts.append("\(s) second\(s == 1 ? "" : "s")") }
        return parts.joined(separator: ", ")
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
