import SwiftUI

struct StartedWorkout: View {
    let session: WatchWorkoutSession
    let onComplete: (WatchCompletedWorkoutPayload) -> Void

    var body: some View {
        TimelineView(.periodic(from: session.startedAt, by: 1)) { context in
            ZStack {
                WatchColors.background.ignoresSafeArea()

                VStack(spacing: 0) {

                    // ── TOP: elapsed time + exercise name ──────────────────
                    VStack(spacing: 3) {
                        Text(elapsedText(context.date.timeIntervalSince(session.startedAt)))
                            .font(.system(size: 24, weight: .medium, design: .monospaced))
                            .foregroundStyle(WatchColors.textWhite)

                        Text(session.currentExercise?.name ?? "")
                            .font(.custom("IstokWeb-Regular", size: 22, relativeTo: .headline))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .padding(.horizontal, 10)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .padding(.bottom, 14)

                    // ── MIDDLE: rep counter ────────────────────────────────
                    HStack(spacing: 0) {
                        Button(action: { session.decrementRep() }) {
                            Image(systemName: "minus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color(hex: "#315BFF")))
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        Text("\(session.currentExercise?.currentReps ?? 0)")
                            .font(.custom("NotoSans-Regular", size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 66, height: 66)
                            .background(Circle().fill(WatchColors.cardBackground))

                        Spacer()

                        Button(action: { session.incrementRep() }) {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color(hex: "#315BFF")))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                    // ── BOTTOM: complete set + set progress ────────────────
                    HStack {
                        Button(action: { session.completeSet() }) {
                            Image(systemName: "plus")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 40, height: 40)
                                .glassEffect(in: Circle())
                        }
                        .buttonStyle(.plain)

                        Spacer()

                        if isOnFinalSet {
                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .glassEffect(in: Circle())
                        } else if let exercise = session.currentExercise {
                            Text(exercise.setProgressText)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundStyle(.white)
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .padding(.bottom, 10)
                }
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
    StartedWorkout(session: session, onComplete: { _ in })
}
