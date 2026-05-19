import SwiftUI

struct WorkoutSelector: View {
    let templates: [WatchTemplatePayload]
    let onStart: (WatchTemplatePayload) -> Void

    var body: some View {
        if templates.isEmpty {
            VStack(spacing: 8) {
                Text("No Routines")
                    .font(.custom("IstokWeb-Regular", size: 16, relativeTo: .headline))
                    .foregroundStyle(WatchColors.textBrown)
                Text("Create routines\non your iPhone")
                    .font(.system(size: 11))
                    .foregroundStyle(WatchColors.textBrown.opacity(0.65))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(WatchColors.background.ignoresSafeArea())
        } else {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(templates) { template in
                        RoutineCard(template: template) {
                            onStart(template)
                        }
                    }
                    Color.clear.frame(height: 20)
                }
                .padding(.horizontal, 6)
            }
            .background(WatchColors.background.ignoresSafeArea())
        }
    }
}

private struct RoutineCard: View {
    let template: WatchTemplatePayload
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                Text(template.name)
                    .font(.custom("IstokWeb-Regular", size: 18, relativeTo: .headline))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Text("\(template.exercises.count) exercises")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .bottomLeading)
            .padding(14)
            .frame(height: 90)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(WatchColors.cardBackground)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    let sampleTemplates = [
        WatchTemplatePayload(id: "1", name: "Push Day", exercises: [
            WatchExercisePayload(name: "Bench Press", targetSets: 4, targetReps: 8, orderIndex: 0),
            WatchExercisePayload(name: "Shoulder Press", targetSets: 3, targetReps: 10, orderIndex: 1),
            WatchExercisePayload(name: "Tricep Dips", targetSets: 3, targetReps: 12, orderIndex: 2),
        ]),
        WatchTemplatePayload(id: "2", name: "Pull Day", exercises: [
            WatchExercisePayload(name: "Pull Ups", targetSets: 4, targetReps: 8, orderIndex: 0),
            WatchExercisePayload(name: "Barbell Row", targetSets: 3, targetReps: 10, orderIndex: 1),
        ]),
        WatchTemplatePayload(id: "3", name: "Leg Day", exercises: [
            WatchExercisePayload(name: "Squat", targetSets: 5, targetReps: 5, orderIndex: 0),
            WatchExercisePayload(name: "Leg Press", targetSets: 4, targetReps: 10, orderIndex: 1),
            WatchExercisePayload(name: "Leg Curl", targetSets: 3, targetReps: 12, orderIndex: 2),
            WatchExercisePayload(name: "Calf Raise", targetSets: 4, targetReps: 15, orderIndex: 3),
        ]),
    ]

    WorkoutSelector(templates: sampleTemplates) { _ in }
}
