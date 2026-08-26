import SwiftUI

struct StartedWorkout: View {
    let session: WatchWorkoutSession
    let onComplete: (WatchCompletedWorkoutPayload) -> Void
    let onCancel: () -> Void

    @Environment(\.scenePhase) private var scenePhase
    @State private var showingEndAlert = false

    var body: some View {
        TimelineView(.periodic(from: session.startedAt, by: 1)) { context in
            ZStack {
                WatchColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer(minLength: 10)

                    // ── TOP: elapsed time + exercise name ──────────────────
                    VStack(spacing: 3) {
                        Text(elapsedText(context.date.timeIntervalSince(session.startedAt)))
                            .font(.system(.title2, weight: .medium).monospacedDigit())
                            .foregroundStyle(WatchColors.textBlack.opacity(0.6))
                            .accessibilityHidden(true)

                        Text(session.currentExercise?.name ?? "")
                            .font(.custom("IstokWeb-Regular", size: 22, relativeTo: .headline))
                            .foregroundStyle(WatchColors.textBlack)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                            .contentTransition(.opacity)
                            .id(session.currentExercise?.name)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: session.currentExercise?.name)
                            .accessibilityAddTraits(.isHeader)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.bottom, 14)

                    // ── MIDDLE: rep counter ────────────────────────────────
                    HStack(spacing: 0) {
                        Button(action: { session.decrementRep() }) {
                            Image(systemName: "minus")
                                .font(.system(.body, weight: .bold))
                                .foregroundStyle(WatchColors.textBlack.opacity(0.75))
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(.white))
                        }
                        .buttonStyle(WatchLivelyButtonStyle())
                        .accessibilityLabel("Decrease rep count")

                        Spacer()

                        Text("\(session.currentExercise?.currentReps ?? 0)")
                            .font(.custom("NotoSans-Regular", size: 32, relativeTo: .largeTitle))
                            .foregroundStyle(WatchColors.textBlack)
                            .frame(width: 66, height: 66)
                            .background(
                                Circle()
                                    .fill(WatchColors.cardBackground)
                                    .overlay(Circle().stroke(.white.opacity(0.5), lineWidth: 1))
                                    .shadow(color: .black.opacity(0.10), radius: 4, x: 0, y: 2)
                            )
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: session.currentExercise?.currentReps)
                            .accessibilityLabel("\(session.currentExercise?.currentReps ?? 0) reps")

                        Spacer()

                        Button(action: { session.incrementRep() }) {
                            Image(systemName: "plus")
                                .font(.system(.body, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 34, height: 34)
                                .background(Circle().fill(Color(hex: "#315BFF")))
                        }
                        .buttonStyle(WatchLivelyButtonStyle())
                        .accessibilityLabel("Increase rep count")
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                    // ── BOTTOM: complete set + set progress ────────────────
                    HStack {
                        Button(action: { session.completeSet() }) {
                            Image(systemName: "plus")
                                .font(.system(.footnote, weight: .semibold))
                                .foregroundStyle(Color(hex: "#315BFF"))
                                .frame(width: 40, height: 40)
                                .glassEffect(in: Circle())
                                .environment(\.colorScheme, .light)
                        }
                        .buttonStyle(WatchLivelyButtonStyle())
                        .accessibilityLabel("Complete set")
                        .accessibilityHint("Logs your reps and moves to the next set")

                        Spacer()

                        if isOnFinalSet {
                            Button(action: { session.completeSet() }) {
                                Image(systemName: "checkmark")
                                    .font(.system(.body, weight: .semibold))
                                    .foregroundStyle(Color(hex: "#315BFF"))
                                    .frame(width: 36, height: 36)
                                    .glassEffect(in: Circle())
                                    .environment(\.colorScheme, .light)
                            }
                            .buttonStyle(WatchLivelyButtonStyle())
                            .transition(.scale.combined(with: .opacity))
                            .animation(.spring(response: 0.45, dampingFraction: 0.65), value: isOnFinalSet)
                            .accessibilityLabel("Complete workout")
                            .accessibilityHint("Ends and saves your session")
                        } else if let exercise = session.currentExercise {
                            SetProgressDots(completed: exercise.completedSets, total: exercise.targetSets)
                                .transition(.opacity)
                                .animation(.easeOut(duration: 0.3), value: exercise.completedSets)
                        }
                    }
                    .padding(.horizontal, 22)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 20)
                }
            }
        }
        .alert("Workout Paused", isPresented: $showingEndAlert) {
            Button("Resume", role: .cancel) {}
            Button("End Workout") { onComplete(session.buildPayload()) }
            Button("Cancel Workout", role: .destructive) { onCancel() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .inactive && !session.isComplete {
                showingEndAlert = true
            }
        }
        .onChange(of: session.isComplete) { _, complete in
            if complete { onComplete(session.buildPayload()) }
        }
    }

    private var isOnFinalSet: Bool {
        guard let exercise = session.currentExercise else { return false }
        return session.isOnLastExercise && exercise.completedSets >= exercise.targetSets - 1
    }

    private func elapsedText(_ interval: TimeInterval) -> String {
        let total = Int(max(0, interval))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%02d:%02d", m, s)
    }
}

private struct SetProgressDots: View {
    let completed: Int
    let total: Int

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(index < completed ? Color(hex: "#315BFF") : WatchColors.textBlack.opacity(0.15))
                    .frame(width: 6, height: 6)
                    .scaleEffect(index < completed ? 1 : 0.85)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: completed)
            }
        }
        .accessibilityHidden(true)
    }
}

#Preview {
    let session = WatchWorkoutSession()
    let _ = session.start(template: WatchTemplatePayload(
        id: "1",
        name: "Push Day",
        exercises: [
            WatchExercisePayload(name: "Bench Press", targetSets: 3, targetReps: 8, orderIndex: 0),
            WatchExercisePayload(name: "Shoulder Press", targetSets: 3, targetReps: 10, orderIndex: 1),
        ]
    ))
    StartedWorkout(session: session, onComplete: { _ in }, onCancel: {})
}
