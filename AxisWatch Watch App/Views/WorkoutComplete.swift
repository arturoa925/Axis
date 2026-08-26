import SwiftUI

struct WorkoutComplete: View {
    let payload: WatchCompletedWorkoutPayload
    let onDismiss: () -> Void

    @State private var animateCheck = false
    @State private var animateTitle = false
    @State private var animateDuration = false
    @State private var animateButton = false
    @State private var countStart: Date?

    var body: some View {
        ZStack {
            WatchColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 6)

                // ── TOP: checkmark + title + subtitle ──────────────────
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#315BFF").opacity(0.18))
                            .frame(width: 36, height: 36)
                            .blur(radius: 5)
                            .opacity(animateCheck ? 1 : 0)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color(hex: "#315BFF"))
                    }
                    .opacity(animateCheck ? 1 : 0)
                    .scaleEffect(animateCheck ? 1 : 0.3)
                    .animation(.spring(response: 0.55, dampingFraction: 0.55), value: animateCheck)
                    .padding(.bottom, 2)

                    Text("Session Complete")
                        .font(.custom("IstokWeb-Regular", size: 18, relativeTo: .headline))
                        .foregroundStyle(WatchColors.textBlack)
                        .multilineTextAlignment(.center)
                        .padding(.bottom, 4)

                    Text("Check your progress back on the app")
                        .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                        .foregroundStyle(WatchColors.textBrown)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 10)
                }
                .opacity(animateTitle ? 1 : 0)
                .offset(y: animateTitle ? 0 : 8)
                .animation(.spring(response: 0.5, dampingFraction: 0.78), value: animateTitle)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Session Complete. Check your progress back on the app. Workout duration: \(spokenDuration).")
                .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 6)

                // ── MIDDLE: elapsed time ───────────────────────────────
                TimelineView(.animation) { timeline in
                    let progress: Double = {
                        guard let countStart else { return 0 }
                        return min(1, timeline.date.timeIntervalSince(countStart) / 0.8)
                    }()

                    Text(formattedDuration(payload.duration * easeOut(progress)))
                        .font(.system(.largeTitle, weight: .medium).monospacedDigit())
                        .foregroundStyle(WatchColors.textBlack)
                }
                .opacity(animateDuration ? 1 : 0)
                .scaleEffect(animateDuration ? 1 : 0.85)
                .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animateDuration)
                .accessibilityHidden(true)

                Spacer(minLength: 8)

                // ── BOTTOM: next button ────────────────────────────────
                Button(action: onDismiss) {
                    Image(systemName: "arrow.right")
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(Color(hex: "#315BFF"))
                        .frame(width: 40, height: 40)
                        .glassEffect(in: Circle())
                        .environment(\.colorScheme, WatchThemeManager.shared.isDarkMode ? .dark : .light)
                }
                .buttonStyle(WatchLivelyButtonStyle())
                .opacity(animateButton ? 1 : 0)
                .scaleEffect(animateButton ? 1 : 0.6)
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateButton)
                .accessibilityLabel("Done")
                .accessibilityHint("Returns to your routine list")
                .padding(.bottom, 22)
            }
        }
        .onAppear {
            animateCheck = true
            animateTitle = true
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.25)) { animateDuration = true }
            countStart = Date().addingTimeInterval(0.25)
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.45)) { animateButton = true }
        }
    }

    private func easeOut(_ t: Double) -> Double {
        1 - pow(1 - t, 2)
    }

    private var formattedDuration: String {
        formattedDuration(payload.duration)
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let total = Int(max(0, duration))
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
