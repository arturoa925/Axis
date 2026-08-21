
import SwiftUI
import SwiftData

struct AddExerciseSection: View {
    @Bindable var routine: WorkoutTemplate
    @Binding var exerciseSearchText: String
    @Binding var selectedEquipment: EquipmentType
    @Binding var isAddPanelExpanded: Bool
    let addPanelDragGesture: AnyGesture<DragGesture.Value>
    @Query(sort: \Exercise.name) private var exerciseLibrary: [Exercise]
    @Environment(\.modelContext) private var modelContext

    // filter the static library — not SwiftData — so all equipment types are always visible
    private var filteredExercises: [ExerciseOption] {
        ExerciseOptionLibrary.all
            .filter { $0.equipment == selectedEquipment }
            .filter { option in
                exerciseSearchText.isEmpty || option.name.localizedCaseInsensitiveContains(exerciseSearchText)
            }
    }
    let saveChanges: () -> Void
    let removeExercise: (TemplateExercise) -> Void

    // shell for holding both components in this view
    var body: some View {
        VStack(spacing: 12) {
            addExercisePanel
            saveButton
        }
    }

    // adding exercises
    private var addExercisePanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.smooth(duration: 0.28)) {
                    isAddPanelExpanded.toggle()
                }
            } label: {
                // the full rectangle
                Capsule()
                    .fill(.white.opacity(0.28))
                    .frame(width: 42, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .gesture(addPanelDragGesture)
            .accessibilityLabel(isAddPanelExpanded ? "Collapse exercise search" : "Expand exercise search")

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)

                TextField("Add another exercise", text: $exerciseSearchText)
                    .font(.custom("NotoSans-Regular", size: 15, relativeTo: .body))
                    .textInputAutocapitalization(.words)
                    .submitLabel(.search)

                Button {
                    withAnimation(.smooth(duration: 0.28)) {
                        isAddPanelExpanded.toggle()
                    }
                } label: {
                    Image(systemName: isAddPanelExpanded ? "chevron.down" : "chevron.up")
                        .font(.system(.caption, weight: .bold))
                        .foregroundStyle(.white.opacity(0.78))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.10))
                        .clipShape(Circle())
                        .animation(nil, value: isAddPanelExpanded)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isAddPanelExpanded ? "Collapse exercise search" : "Expand exercise search")
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.18), lineWidth: 1)
            }

            // applicable when capsule is not expanded
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(EquipmentType.allCases) { equipment in
                        Button {
                            withAnimation(.smooth(duration: 0.22)) {
                                selectedEquipment = equipment
                            }
                        } label: {
                            Text(equipment.title)
                                .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                                .fontWeight(.semibold)
                                .foregroundStyle(selectedEquipment == equipment ? Color(hex: "#2A2A2A") : AppColors.TextBrown)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 7)
                                .background {
                                    if selectedEquipment == equipment {
                                        Capsule().fill(Color.white)
                                    } else {
                                        Capsule().fill(.thinMaterial)
                                    }
                                }
                                .clipShape(Capsule())
                                .overlay {
                                    Capsule()
                                        .stroke(.white.opacity(selectedEquipment == equipment ? 0 : 0.18), lineWidth: 1)
                                }
                        }
                        .buttonStyle(.plain)
                        .accessibilityAddTraits(selectedEquipment == equipment ? .isSelected : [])
                    }
                }
            }

            if isAddPanelExpanded {
                ScrollView(showsIndicators: false) {
                    // adaptive to list of exercises available
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 145), spacing: 10)], spacing: 10) {
                        ForEach(filteredExercises) { option in
                            addExerciseChip(option)
                        }
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 8)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                // revert to default view when closing the expansion
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(filteredExercises) { option in
                            addExerciseChip(option)
                        }
                    }
                }
                .transition(.opacity)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
    }

    private func addExerciseChip(_ option: ExerciseOption) -> some View {
        let isAlreadyAdded = routine.exercises.contains { $0.exercise.name == option.name }

        return Button {
            toggleExercise(option)
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isAlreadyAdded ? "checkmark.circle.fill" : "plus.circle.fill")
                    .font(.system(.footnote, weight: .semibold))
                    .foregroundStyle(isAlreadyAdded ? .green : AppColors.TextBlue)

                Text(option.name)
                    .font(.custom("NotoSans-Regular", size: 14, relativeTo: .body))
                    .fontWeight(.semibold)
                    .foregroundStyle(isAlreadyAdded ? AppColors.background : AppColors.TextBrown)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)

                // alrady added modifications
                if isAlreadyAdded {
                    Text("Added")
                        .font(.custom("NotoSans-Regular", size: 11, relativeTo: .caption2))
                        .foregroundStyle(AppColors.background.opacity(0.72))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(AppColors.background.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .frame(maxWidth: isAddPanelExpanded ? .infinity : nil, alignment: .leading)
            .background {
                if isAlreadyAdded {
                    Capsule().fill(Color.white)
                } else {
                    Capsule().fill(.regularMaterial)
                }
            }
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .stroke(isAlreadyAdded ? Color.clear : .white.opacity(0.18), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isAlreadyAdded ? "Remove \(option.name) from routine" : "Add \(option.name) to routine")
        .accessibilityAddTraits(isAlreadyAdded ? .isSelected : [])
    }

    // save button component
    private var saveButton: some View {
        Button {
            saveChanges()
        } label: {
            Text("Save Changes")
                .font(.custom("NotoSans-Regular", size: 17, relativeTo: .headline))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(AppColors.actionBlue)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: AppColors.actionBlue.opacity(0.5), radius: 16, x: 0, y: 8)
        }
        .buttonStyle(LivelyButtonStyle())
    }

    private func toggleExercise(_ option: ExerciseOption) {
        withAnimation(.smooth(duration: 0.28)) {
            if let existingTemplateExercise = routine.exercises.first(where: { $0.exercise.name == option.name }) {
                removeExercise(existingTemplateExercise)
            } else {
                let exercise = exerciseLibrary.first(where: { $0.name == option.name }) ?? {
                    let new = Exercise(name: option.name, equipment: option.equipment.rawValue)
                    modelContext.insert(new)
                    return new
                }()
                let templateExercise = TemplateExercise(
                    orderIndex: routine.exercises.count,
                    exercise: exercise,
                    targetSets: 3,
                    targetReps: 10
                )
                routine.exercises.append(templateExercise)
            }
        }
    }
}
#Preview {
    @Previewable @State var exerciseSearchText = ""
    @Previewable @State var selectedEquipment = EquipmentType.barbell
    @Previewable @State var isAddPanelExpanded = false
    
    // Create sample data
    let sampleExercises = [
        Exercise(name: "Bench Press", equipment: "barbell"),
        Exercise(name: "Squat", equipment: "barbell"),
        Exercise(name: "Deadlift", equipment: "barbell"),
        Exercise(name: "Bicep Curl", equipment: "dumbbell"),
        Exercise(name: "Shoulder Press", equipment: "dumbbell"),
        Exercise(name: "Cable Fly", equipment: "cable"),
        Exercise(name: "Pull-up", equipment: "bodyweight"),
        Exercise(name: "Leg Press", equipment: "machine")
    ]
    
    let sampleRoutine = WorkoutTemplate(
        name: "Push Day",
        exercises: []
    )
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, WorkoutTemplate.self, TemplateExercise.self,
        configurations: config
    )
    
    // Insert sample exercises into the container
    for exercise in sampleExercises {
        container.mainContext.insert(exercise)
    }
    container.mainContext.insert(sampleRoutine)
    
    return ZStack {
        AppColors.background
            .ignoresSafeArea()
        
        VStack {
            Spacer()
            
            AddExerciseSection(
                routine: sampleRoutine,
                exerciseSearchText: $exerciseSearchText,
                selectedEquipment: $selectedEquipment,
                isAddPanelExpanded: $isAddPanelExpanded,
                addPanelDragGesture: AnyGesture(DragGesture().onChanged { _ in }),
                saveChanges: {
                    print("Save changes tapped")
                },
                removeExercise: { exercise in
                    print("Remove exercise: \(exercise.name)")
                }
            )
            .padding()
        }
    }
    .modelContainer(container)
}

