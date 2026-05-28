//
//  CreateRoutineSheet.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import SwiftUI
import SwiftData

struct CreateRoutine: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var routineName = ""
    // starts as default selected option
    @State private var selectedEquipment: EquipmentType = .barbell
    @State private var exerciseSearchText = ""
    // the list of chosen exercises
    @State private var selectedExercises: [SelectedExerciseDraft] = []

    private let exerciseOptions = ExerciseOptionLibrary.all

    // filter by equipment selected
    private var filteredExercises: [ExerciseOption] {
        exerciseOptions
            .filter { $0.equipment == selectedEquipment }
            .filter { option in
                exerciseSearchText.isEmpty || option.name.localizedCaseInsensitiveContains(exerciseSearchText)
            }
    }

    // a name needs to be given and a exercise needs to be selected for routine to save
    private var canSaveRoutine: Bool {
        !routineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !selectedExercises.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                Form {
                    Section {
                        Text("Creating your new routine")
                            .font(AppTypography.title)
                            .foregroundStyle(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .multilineTextAlignment(.center)
                            .listRowBackground(Color.clear)
                    }

                    Section("Routine") {
                        TextField("Push Day", text: $routineName)
                            .textInputAutocapitalization(.words)
                    }


                    Section {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("Find an exercise")
                                    .font(AppTypography.body)
                                    .foregroundStyle(.white)

                                Text("Search by movement, then filter by equipment.")
                                    .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                                    .foregroundStyle(.white.opacity(0.8))
                            }

                            HStack(spacing: 10) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(.secondary)
                                    .accessibilityHidden(true)

                                TextField("Search exercises", text: $exerciseSearchText)
                                    .font(.custom("NotoSans-Regular", size: 15, relativeTo: .body))
                                    .textInputAutocapitalization(.words)
                                    .submitLabel(.search)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(.white.opacity(0.12), lineWidth: 1)
                            }

                            // equipment categories
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(EquipmentType.allCases) { equipment in
                                        Button {
                                            withAnimation(.smooth(duration: 0.22)) {
                                                selectedEquipment = equipment
                                            }
                                        } label: {
                                            Text(equipment.title)
                                                .font(.custom("NotoSans-Regular", size: 14, relativeTo: .body))
                                                .foregroundStyle(selectedEquipment == equipment ? AppColors.background : .white.opacity(0.82))
                                                .padding(.horizontal, 13)
                                                .padding(.vertical, 8)
                                                .background(selectedEquipment == equipment ? Color.white : Color.white.opacity(0.08))
                                                .clipShape(Capsule())
                                                .overlay {
                                                    Capsule()
                                                        .stroke(.white.opacity(selectedEquipment == equipment ? 0 : 0.12), lineWidth: 1)
                                                }
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityAddTraits(selectedEquipment == equipment ? .isSelected : [])
                                    }
                                }
                                .padding(.vertical, 2)
                            }

                            // exercises after filter or equipment selected
                            if filteredExercises.isEmpty {
                                ContentUnavailableView(
                                    "No exercises found",
                                    systemImage: "figure.strengthtraining.traditional",
                                    description: Text("Try a different search or equipment filter.")
                                )
                                .font(.custom("NotoSans-Regular", size: 14, relativeTo: .body))
                                .foregroundStyle(.white.opacity(0.72))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                            } else {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                                    ForEach(filteredExercises) { exercise in
                                        let isSelected = selectedExercises.contains(where: { $0.option.name == exercise.name })
                                        Button {
                                            toggleExerciseSelection(exercise)
                                        } label: {
                                            HStack(spacing: 10) {
                                                Image(systemName: isSelected ? "checkmark.circle.fill" : "plus.circle.fill")
                                                    .font(.system(size: 18, weight: .semibold))
                                                    .foregroundStyle(isSelected ? .green : AppColors.TextBlue)
                                                    .accessibilityHidden(true)

                                                Text(exercise.name)
                                                    .font(.custom("NotoSans-Regular", size: 14, relativeTo: .body))
                                                    .foregroundStyle(.white)
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.82)

                                                Spacer(minLength: 0)
                                            }
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 12)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(.thinMaterial)
                                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            .overlay {
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .stroke(.white.opacity(0.10), lineWidth: 1)
                                            }
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel(isSelected ? "Remove \(exercise.name)" : "Add \(exercise.name)")
                                        .accessibilityAddTraits(isSelected ? .isSelected : [])
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                        .listRowBackground(Color.clear)
                    }

                    // after exercises are selected
                    if !selectedExercises.isEmpty {
                        Section {
                            VStack(alignment: .leading, spacing: 14) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Selected exercises")
                                        .font(AppTypography.body)
                                        .foregroundStyle(.white)

                                    Text("Tap a card to adjust targets before saving.")
                                    .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                                    .foregroundStyle(.white.opacity(0.96))
                                }

                                ForEach($selectedExercises) { $exercise in
                                    VStack(alignment: .leading, spacing: 14) {
                                        Button {
                                            withAnimation(.smooth(duration: 0.28)) {
                                                exercise.isExpanded.toggle()
                                            }
                                        } label: {
                                            HStack(spacing: 12) {
                                                ZStack {
                                                    Circle()
                                                        .fill(AppColors.TextBlue.opacity(0.18))
                                                        .frame(width: 36, height: 36)

                                                    Image(systemName: "checkmark")
                                                        .font(.system(size: 15, weight: .bold))
                                                        .foregroundStyle(AppColors.TextBlue)
                                                }
                                                .accessibilityHidden(true)

                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(exercise.option.name)
                                                        .font(.custom("NotoSans-Regular", size: 16, relativeTo: .body))
                                                        .foregroundStyle(.white)
                                                        .lineLimit(1)

                                                    Text("\(exercise.targetSets) sets • \(exercise.targetReps) reps")
                                                        .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                                                        .foregroundStyle(.white.opacity(0.8))
                                                }

                                                Spacer()

                                                Image(systemName: exercise.isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                                                    .font(.system(size: 22, weight: .semibold))
                                                    .foregroundStyle(.white.opacity(0.38))
                                                    .accessibilityHidden(true)
                                            }
                                            .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel("\(exercise.option.name), \(exercise.targetSets) sets, \(exercise.targetReps) reps. \(exercise.isExpanded ? "Collapse" : "Expand") targets")

                                        if exercise.isExpanded {
                                            VStack(spacing: 12) {
                                                HStack(spacing: 12) {
                                                    targetControl(
                                                        title: "Sets",
                                                        value: $exercise.targetSets,
                                                        range: 1...10
                                                    )

                                                    targetControl(
                                                        title: "Reps",
                                                        value: $exercise.targetReps,
                                                        range: 1...50
                                                    )
                                                }

                                                Button(role: .destructive) {
                                                    removeExercise(exercise)
                                                } label: {
                                                    HStack(spacing: 8) {
                                                        Image(systemName: "trash")
                                                        Text("Remove exercise")
                                                    }
                                                    .font(.custom("NotoSans-Regular", size: 14, relativeTo: .body))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 10)
                                                }
                                                .buttonStyle(.plain)
                                                .foregroundStyle(.red.opacity(0.92))
                                                .background(.red.opacity(0.10))
                                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                                .accessibilityLabel("Delete exercise")
                                            }
                                            .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .top)))
                                        }
                                    }
                                    .padding(14)
                                    .background(.thinMaterial)
                                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .stroke(.white.opacity(0.10), lineWidth: 1)
                                    }
                                    .animation(.smooth(duration: 0.28), value: exercise.isExpanded)
                                }
                            }
                            .padding(.vertical, 6)
                            .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                            .listRowBackground(Color.clear)
                        }
                        Section {
                            Button {
                                saveRoutine()
                            } label: {
                                // create / save routine btn
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Routine")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 2)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .buttonBorderShape(.capsule)
                            .tint(.blue)
                            .disabled(!canSaveRoutine)
                            .listRowBackground(Color.clear)
                        }
                    }
                }
                .scrollContentBackground(.hidden)

            }
            // cancel btn top left
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.red)
                    }
                    .accessibilityLabel("Cancel")
                }
            }
        }
    }

    // controls & sets the number of reps and sets
    private func targetControl(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                .foregroundStyle(.white.opacity(0.9))

            HStack(spacing: 12) {
                Button {
                    guard value.wrappedValue > range.lowerBound else { return }
                    withAnimation(.smooth(duration: 0.18)) {
                        value.wrappedValue -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.10))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white.opacity(value.wrappedValue > range.lowerBound ? 0.86 : 0.28))
                .disabled(value.wrappedValue <= range.lowerBound)

                Text("\(value.wrappedValue)")
                    .font(.custom("NotoSans-Regular", size: 22, relativeTo: .title3))
                    .foregroundStyle(.white)
                    .frame(minWidth: 28)
                    .contentTransition(.numericText())

                Button {
                    guard value.wrappedValue < range.upperBound else { return }
                    withAnimation(.smooth(duration: 0.18)) {
                        value.wrappedValue += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 13, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(AppColors.TextBlue.opacity(0.18))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColors.TextBlue)
                .disabled(value.wrappedValue >= range.upperBound)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.08), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(value.wrappedValue)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                guard value.wrappedValue < range.upperBound else { return }
                withAnimation(.smooth(duration: 0.18)) { value.wrappedValue += 1 }
            case .decrement:
                guard value.wrappedValue > range.lowerBound else { return }
                withAnimation(.smooth(duration: 0.18)) { value.wrappedValue -= 1 }
            @unknown default:
                break
            }
        }
    }

    private func toggleExerciseSelection(_ exercise: ExerciseOption) {
        withAnimation(.smooth(duration: 0.28)) {
            if let existingExercise = selectedExercises.first(where: { $0.option.name == exercise.name }) {
                removeExercise(existingExercise)
            } else {
                selectedExercises.append(SelectedExerciseDraft(option: exercise))
            }
        }
    }

    private func addExercise(_ exercise: ExerciseOption) {
        guard !selectedExercises.contains(where: { $0.option.name == exercise.name }) else { return }
        withAnimation(.smooth(duration: 0.28)) {
            selectedExercises.append(SelectedExerciseDraft(option: exercise))
        }
    }

    private func removeExercise(_ exercise: SelectedExerciseDraft) {
        withAnimation(.smooth(duration: 0.28)) {
            selectedExercises.removeAll { $0.id == exercise.id }
        }
    }

    private func saveRoutine() {
        let cleanedName = routineName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty, !selectedExercises.isEmpty else { return }

        let templateExercises = selectedExercises.enumerated().map { index, selectedExercise in
            let exercise = Exercise(
                name: selectedExercise.option.name,
                equipment: selectedExercise.option.equipment.rawValue
            )

            return TemplateExercise(
                orderIndex: index,
                exercise: exercise,
                targetSets: selectedExercise.targetSets,
                targetReps: selectedExercise.targetReps
            )
        }

        let routine = WorkoutTemplate(
            name: cleanedName,
            exercises: templateExercises
        )

        modelContext.insert(routine)

        do {
            try modelContext.save()
            print("Saved routine: \(routine.name) with \(routine.exercises.count) exercises")
            dismiss()
        } catch {
            print("Failed to save routine: \(error.localizedDescription)")
        }
    }
}

 


struct SelectedExerciseDraft: Identifiable, Equatable {
    let id = UUID()
    let option: ExerciseOption
    var targetSets: Int = 3
    var targetReps: Int = 10
    var isExpanded: Bool = false
}

#Preview {
    CreateRoutine()
}
