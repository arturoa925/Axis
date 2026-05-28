import SwiftUI

struct WorkoutHistoryCard: View {
    let workout: CompletedWorkout

    // date formatting
    private var formattedDate: String {
        workout.completedAt.formatted(date: .abbreviated, time: .omitted)
    }

    // time formatting
    private var formattedDuration: String {
        let total = Int(workout.elapsedTime)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        }
        return String(format: "%d:%02d", m, s)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                Text(workout.templateName)
                    .font(.custom("IstokWeb-Regular", size: 20, relativeTo: .title3))
                    .foregroundStyle(AppColors.TextBlue)

                Spacer()

                Text(formattedDate)
                    .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                    .foregroundStyle(AppColors.TextBlue.opacity(0.6))
            }

            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.TextBlue.opacity(0.7))
                    .accessibilityHidden(true)

                Text(formattedDuration)
                    .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                    .foregroundStyle(AppColors.TextBlue.opacity(0.7))
                    .accessibilityLabel("Duration: \(formattedDuration)")
            }

            Divider()
                .overlay(AppColors.TextBlue.opacity(0.15))

            // exercises placed in proper order
            let sorted = workout.exercises.sorted { $0.orderIndex < $1.orderIndex }
            VStack(alignment: .leading, spacing: 6) {
                ForEach(sorted, id: \.id) { exercise in
                    HStack(spacing: 8) {
                        Circle()
                            .fill(AppColors.TextBlue.opacity(0.35))
                            .frame(width: 5, height: 5)
                            .accessibilityHidden(true)

                        Text(exercise.name)
                            .font(.custom("NotoSans-Regular", size: 14, relativeTo: .body))
                            .foregroundStyle(AppColors.TextWhite)
                    }
                }
            }
        }
        .padding(18)
        .background(AppColors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(AppColors.TextBlue.opacity(0.12), lineWidth: 1)
        }
    }
}

#Preview {
    let exercise1 = CompletedExercise(orderIndex: 0, name: "Bench Press", completedSets: 3, targetSets: 3, targetReps: 10, totalRepsCompleted: 30)
    let exercise2 = CompletedExercise(orderIndex: 1, name: "Incline Dumbbell Press", completedSets: 2, targetSets: 3, targetReps: 12, totalRepsCompleted: 24)
    let exercise3 = CompletedExercise(orderIndex: 2, name: "Cable Fly", completedSets: 3, targetSets: 3, targetReps: 15, totalRepsCompleted: 45)

    let workout = CompletedWorkout(
        templateName: "Push Day",
        startedAt: Date().addingTimeInterval(-3720),
        elapsedTime: 3720,
        exercises: [exercise1, exercise2, exercise3]
    )

    WorkoutHistoryCard(workout: workout)
        .padding()
}
