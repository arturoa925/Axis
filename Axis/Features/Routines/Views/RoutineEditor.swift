import SwiftUI
import SwiftData

struct RoutineEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext


    @Bindable var routine: WorkoutTemplate

    @State private var exerciseSearchText = ""
    @State private var selectedEquipment: EquipmentType = .barbell
    @State private var exerciseToDelete: TemplateExercise?
    @State private var expandedExerciseID: UUID?
    @State private var isAddPanelExpanded = false
    @GestureState private var addPanelDragOffset: CGFloat = 0

    // sort by the order they were added in routine
    private var sortedExercises: [TemplateExercise] {
        routine.exercises.sorted { $0.orderIndex < $1.orderIndex }
    }

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 18)
                    .padding(.top, 10)
                    .padding(.bottom, 12)
                    .background(AppColors.background.opacity(0.94))
                    .zIndex(2)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Exercises")
                            .font(AppTypography.body)
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 18)

                        // exercise cards from original routine
                        VStack(spacing: 12) {
                            ForEach(sortedExercises) { exercise in
                                ExerciseCard(
                                    exercise: exercise,
                                    expandedExerciseID: $expandedExerciseID,
                                    equipmentTitle: { EquipmentType(rawValue: $0)?.title ?? $0 },
                                    targetControl: { title, value, range in
                                        AnyView(TargetControl(title: title, value: value, range: range))
                                    }
                                )
                                .padding(.horizontal, 18)
                                .onLongPressGesture {
                                    exerciseToDelete = exercise
                                }
                                .accessibilityHint("Long press to remove")
                                .accessibilityAction(named: "Remove") { exerciseToDelete = exercise }
                            }
                        }
                    }
                    .padding(.top, 12)
                }
                .safeAreaPadding(.bottom, addPanelHeight + 74)
            }

            // bottom section to add additional exercises
            VStack(spacing: 12) {
                Spacer()
                AddExerciseSection(
                    routine: routine,
                    exerciseSearchText: $exerciseSearchText,
                    selectedEquipment: $selectedEquipment,
                    isAddPanelExpanded: $isAddPanelExpanded,
                    addPanelDragGesture: addPanelDragGesture,
                    saveChanges: saveChanges,
                    removeExercise: removeExercise
                )
                .frame(maxHeight: addPanelHeight)
                .offset(y: max(0, addPanelDragOffset))
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 54)
            .background(alignment: .bottom) {
                LinearGradient(
                    colors: [
                        AppColors.background.opacity(0),
                        AppColors.background.opacity(0.82),
                        AppColors.background
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: isAddPanelExpanded ? 470 : 260)
                .allowsHitTesting(false)
            }
        }
        .navigationBarBackButtonHidden(true)
        // long press gesture to delete any exercise
        .alert("Remove exercise?", isPresented: Binding(
            get: { exerciseToDelete != nil },
            set: { if !$0 { exerciseToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                exerciseToDelete = nil
            }

            Button("Remove", role: .destructive) {
                if let exerciseToDelete {
                    removeExercise(exerciseToDelete)
                }
                exerciseToDelete = nil
            }
        } message: {
            Text("This removes the exercise from this routine.")
        }
       
    }

    
    private var header: some View {
        ZStack {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(.body, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 44, height: 44)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(.white.opacity(0.12), lineWidth: 1)
                        }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Spacer()
            }

            Text(routine.name)
                .font(.custom("IstokWeb-Bold", size: 24, relativeTo: .title2))
                .foregroundStyle(AppColors.TextBlue)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .padding(.horizontal, 60)
        }
    }



    

    private var addPanelHeight: CGFloat {
        isAddPanelExpanded ? 360 : 178
    }

    private var addPanelDragGesture: AnyGesture<DragGesture.Value> {
        AnyGesture(
            DragGesture(minimumDistance: 8)
                .updating($addPanelDragOffset) { value, state, _ in
                    if isAddPanelExpanded, value.translation.height > 0 {
                        state = value.translation.height
                    }
                }
                .onEnded { value in
                    withAnimation(.smooth(duration: 0.28)) {
                        if value.translation.height < -35 {
                            isAddPanelExpanded = true
                        } else if value.translation.height > 35 {
                            isAddPanelExpanded = false
                        }
                    }
                }
        )
    }

    
    private func removeExercise(_ exercise: TemplateExercise) {
        routine.exercises.removeAll { $0.id == exercise.id }
        for index in routine.exercises.indices {
            routine.exercises[index].orderIndex = index
        }
    }

    private func saveChanges() {
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Failed to save routine changes: \(error.localizedDescription)")
        }
    }


}
#Preview {
    // Create sample exercises
    let benchPress = Exercise(name: "Bench Press", equipment: "barbell")
    let squat = Exercise(name: "Back Squat", equipment: "barbell")
    let deadlift = Exercise(name: "Deadlift", equipment: "barbell")
    let shoulderPress = Exercise(name: "Overhead Press", equipment: "barbell")
    let bicepCurl = Exercise(name: "Bicep Curl", equipment: "dumbbell")
    let tricepExtension = Exercise(name: "Tricep Extension", equipment: "dumbbell")
    let cableFly = Exercise(name: "Cable Fly", equipment: "cable")
    let pullUp = Exercise(name: "Pull-up", equipment: "bodyweight")
    let legPress = Exercise(name: "Leg Press", equipment: "machine")
    
    // Create template exercises for the routine
    let templateExercises = [
        TemplateExercise(orderIndex: 0, exercise: benchPress, targetSets: 4, targetReps: 8),
        TemplateExercise(orderIndex: 1, exercise: shoulderPress, targetSets: 3, targetReps: 10),
        TemplateExercise(orderIndex: 2, exercise: tricepExtension, targetSets: 3, targetReps: 12)
    ]
    
    // Create the workout template
    let pushDayRoutine = WorkoutTemplate(
        name: "Push Day",
        exercises: templateExercises
    )
    
    // Set up in-memory model container
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, WorkoutTemplate.self, TemplateExercise.self,
        configurations: config
    )
    
    // Insert all sample exercises into the library
    let allExercises = [
        benchPress, squat, deadlift, shoulderPress,
        bicepCurl, tricepExtension, cableFly, pullUp, legPress
    ]
    
    for exercise in allExercises {
        container.mainContext.insert(exercise)
    }
    
    // Insert the routine and its template exercises
    container.mainContext.insert(pushDayRoutine)
    for templateExercise in templateExercises {
        container.mainContext.insert(templateExercise)
    }
    
    return NavigationStack {
        RoutineEditor(routine: pushDayRoutine)
    }
    .modelContainer(container)
}

