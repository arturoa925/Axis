//
//  ExerciseCard.swift
//  Axis
//
//  Created by Arturo Ayala on 5/7/26.
//

import SwiftUI
import SwiftData

struct ExerciseCard: View {
    let exercise: TemplateExercise
    @Binding var expandedExerciseID: UUID?
    let equipmentTitle: (String) -> String
    let targetControl: (String, Binding<Int>, ClosedRange<Int>) -> AnyView

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(exercise.exercise.name)
                        .font(.custom("NotoSans-Regular", size: 16, relativeTo: .body))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(equipmentTitle(exercise.exercise.equipment))
                        .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                        .foregroundStyle(.white.opacity(0.64))
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 8) {
                    Button {
                        withAnimation(.smooth(duration: 0.28)) {
                            expandedExerciseID = expandedExerciseID == exercise.id ? nil : exercise.id
                        }
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppColors.TextBlue)
                            .frame(width: 36, height: 36)
                            .background(expandedExerciseID == exercise.id ? AppColors.TextBlue.opacity(0.18) : .white.opacity(0.08))
                            .clipShape(Circle())
                            .overlay {
                                Circle()
                                    .stroke(expandedExerciseID == exercise.id ? AppColors.TextBlue.opacity(0.32) : .white.opacity(0.08), lineWidth: 1)
                            }
                    }
                    .buttonStyle(.plain)

                    Text("\(exercise.targetSets) × \(exercise.targetReps)")
                        .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                        .foregroundStyle(.white.opacity(0.9))
                }
            }

            if expandedExerciseID == exercise.id {
                HStack(spacing: 12) {
                    targetControl(
                        "Sets",
                        Binding(
                            get: { exercise.targetSets },
                            set: { exercise.targetSets = $0 }
                        ),
                        1...10
                    )

                    targetControl(
                        "Reps",
                        Binding(
                            get: { exercise.targetReps },
                            set: { exercise.targetReps = $0 }
                        ),
                        1...50
                    )
                }
                .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
            }
        }
        .padding(14)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .stroke(.white.opacity(0.10), lineWidth: 1)
        }
        .animation(.smooth(duration: 0.28), value: expandedExerciseID)
    }
}
