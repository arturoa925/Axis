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
#Preview {
    @Previewable @State var expandedExerciseID: UUID? = nil
    
    // Create sample exercises
    let benchPress = Exercise(name: "Bench Press", equipment: "barbell")
    let squat = Exercise(name: "Back Squat", equipment: "barbell")
    let bicepCurl = Exercise(name: "Bicep Curl", equipment: "dumbbell")
    
    let sampleExercises = [
        TemplateExercise(orderIndex: 0, exercise: benchPress, targetSets: 4, targetReps: 8),
        TemplateExercise(orderIndex: 1, exercise: squat, targetSets: 3, targetReps: 12),
        TemplateExercise(orderIndex: 2, exercise: bicepCurl, targetSets: 3, targetReps: 10)
    ]
    
    // Equipment title formatter
    let equipmentFormatter: (String) -> String = { equipment in
        equipment.capitalized
    }
    
    // Target control builder
    let targetControlBuilder: (String, Binding<Int>, ClosedRange<Int>) -> AnyView = { label, binding, range in
        AnyView(
            VStack(spacing: 6) {
                Text(label)
                    .font(.custom("NotoSans-Regular", size: 12, relativeTo: .caption2))
                    .foregroundStyle(.white.opacity(0.64))
                
                Stepper(
                    value: binding,
                    in: range,
                    step: 1
                ) {
                    Text("\(binding.wrappedValue)")
                        .font(.custom("NotoSans-Regular", size: 18, relativeTo: .body))
                        .foregroundStyle(.white)
                        .frame(minWidth: 40)
                }
                .labelsHidden()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        )
    }
    
    return ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 12) {
                ForEach(sampleExercises, id: \.id) { exercise in
                    ExerciseCard(
                        exercise: exercise,
                        expandedExerciseID: $expandedExerciseID,
                        equipmentTitle: equipmentFormatter,
                        targetControl: targetControlBuilder
                    )
                }
            }
            .padding()
        }
    }
}

