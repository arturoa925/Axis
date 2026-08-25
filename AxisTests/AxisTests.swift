import Testing
import Foundation
@testable import Axis

// MARK: - Helpers

private func makePayload(
    templateName: String = "Push Day",
    templateID: String? = "A1B2C3D4-0000-0000-0000-000000000000",
    startedAt: Date = Date(timeIntervalSinceReferenceDate: 0),
    duration: TimeInterval = 3600,
    exercises: [WatchCompletedExercisePayload] = []
) -> WatchCompletedWorkoutPayload {
    WatchCompletedWorkoutPayload(
        templateName: templateName,
        templateID: templateID,
        startedAt: startedAt,
        duration: duration,
        exercises: exercises
    )
}

private func makeExercisePayload(
    name: String = "Bench Press",
    completedSets: Int = 3,
    targetSets: Int = 3,
    targetReps: Int = 10,
    orderIndex: Int = 0
) -> WatchCompletedExercisePayload {
    WatchCompletedExercisePayload(
        name: name,
        completedSets: completedSets,
        targetSets: targetSets,
        targetReps: targetReps,
        orderIndex: orderIndex
    )
}

// MARK: - CompletedWorkout (from Watch payload)

@Suite("CompletedWorkout — Watch payload conversion")
struct CompletedWorkoutTests {

    @Test func capturesTemplateName() {
        let completed = CompletedWorkout(from: makePayload(templateName: "Push Day"))
        #expect(completed.templateName == "Push Day")
    }

    @Test func capturesTemplateID() {
        let idString = "A1B2C3D4-0000-0000-0000-000000000000"
        let completed = CompletedWorkout(from: makePayload(templateID: idString))
        #expect(completed.templateID == UUID(uuidString: idString))
    }

    @Test func nilTemplateID_remainsNil() {
        let completed = CompletedWorkout(from: makePayload(templateID: nil))
        #expect(completed.templateID == nil)
    }

    @Test func capturesStartedAt() {
        let date = Date(timeIntervalSinceReferenceDate: 1_000_000)
        let completed = CompletedWorkout(from: makePayload(startedAt: date))
        #expect(completed.startedAt == date)
    }

    @Test func durationMapsToElapsedTime() {
        let completed = CompletedWorkout(from: makePayload(duration: 4500))
        #expect(completed.elapsedTime == 4500)
    }

    @Test func mapsAllExercises() {
        let payload = makePayload(exercises: [
            makeExercisePayload(name: "Bench Press", orderIndex: 0),
            makeExercisePayload(name: "Squat", orderIndex: 1),
            makeExercisePayload(name: "Deadlift", orderIndex: 2)
        ])
        let completed = CompletedWorkout(from: payload)
        #expect(completed.exercises.count == 3)
    }

    @Test func preservesExerciseName() {
        let payload = makePayload(exercises: [makeExercisePayload(name: "Overhead Press")])
        let completed = CompletedWorkout(from: payload)
        #expect(completed.exercises.first?.name == "Overhead Press")
    }

    @Test func preservesExerciseTargets() {
        let payload = makePayload(exercises: [makeExercisePayload(targetSets: 4, targetReps: 8)])
        let completed = CompletedWorkout(from: payload)
        #expect(completed.exercises.first?.targetSets == 4)
        #expect(completed.exercises.first?.targetReps == 8)
    }

    @Test func preservesOrderIndex() {
        let payload = makePayload(exercises: [makeExercisePayload(orderIndex: 2)])
        let completed = CompletedWorkout(from: payload)
        #expect(completed.exercises.first?.orderIndex == 2)
    }

    @Test func totalRepsCompleted_isCompletedSetsTimesTargetReps() {
        let payload = makePayload(exercises: [makeExercisePayload(completedSets: 3, targetReps: 10)])
        let completed = CompletedWorkout(from: payload)
        #expect(completed.exercises.first?.totalRepsCompleted == 30)
    }

    @Test func totalRepsCompleted_zeroWhenNoSetsCompleted() {
        let payload = makePayload(exercises: [makeExercisePayload(completedSets: 0, targetReps: 10)])
        let completed = CompletedWorkout(from: payload)
        #expect(completed.exercises.first?.totalRepsCompleted == 0)
    }

    @Test func endedAt_isAfterStartedAt() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let completed = CompletedWorkout(from: makePayload(startedAt: start))
        #expect(completed.endedAt >= start)
    }

    @Test func emptyExercises_producesEmptyList() {
        let completed = CompletedWorkout(from: makePayload(exercises: []))
        #expect(completed.exercises.isEmpty)
    }
}

// MARK: - WorkoutTemplate

@Suite("WorkoutTemplate")
struct WorkoutTemplateTests {

    @Test func storesName() {
        let template = WorkoutTemplate(name: "Leg Day")
        #expect(template.name == "Leg Day")
    }

    @Test func defaultsToEmptyExercises() {
        let template = WorkoutTemplate(name: "Empty")
        #expect(template.exercises.isEmpty)
    }

    @Test func storesExercises() {
        let exercise = Exercise(name: "Squat", equipment: "barbell")
        let te = TemplateExercise(orderIndex: 0, exercise: exercise, targetSets: 5, targetReps: 5)
        let template = WorkoutTemplate(name: "Strength", exercises: [te])
        #expect(template.exercises.count == 1)
        #expect(template.exercises.first?.exercise.name == "Squat")
    }

    @Test func generatesUniqueIDsByDefault() {
        let first = WorkoutTemplate(name: "A")
        let second = WorkoutTemplate(name: "B")
        #expect(first.id != second.id)
    }

    @Test func preservesExerciseOrderIndexRegardlessOfArrayOrder() {
        let squat = Exercise(name: "Squat", equipment: "barbell")
        let bench = Exercise(name: "Bench", equipment: "barbell")
        let te0 = TemplateExercise(orderIndex: 0, exercise: squat)
        let te1 = TemplateExercise(orderIndex: 1, exercise: bench)
        // stored out of order — the model itself doesn't sort, callers do
        let template = WorkoutTemplate(name: "Push", exercises: [te1, te0])
        let sorted = template.exercises.sorted { $0.orderIndex < $1.orderIndex }
        #expect(sorted.map(\.name) == ["Squat", "Bench"])
    }
}

// MARK: - CompletedExercise

@Suite("CompletedExercise")
struct CompletedExerciseTests {

    @Test func storesAllFields() {
        let ex = CompletedExercise(
            orderIndex: 1,
            name: "Deadlift",
            completedSets: 3,
            targetSets: 4,
            targetReps: 5,
            totalRepsCompleted: 15
        )
        #expect(ex.orderIndex == 1)
        #expect(ex.name == "Deadlift")
        #expect(ex.completedSets == 3)
        #expect(ex.targetSets == 4)
        #expect(ex.targetReps == 5)
        #expect(ex.totalRepsCompleted == 15)
    }

    @Test func defaultsToZeros() {
        let ex = CompletedExercise(orderIndex: 0, name: "Pull-Up")
        #expect(ex.completedSets == 0)
        #expect(ex.targetSets == 0)
        #expect(ex.targetReps == 0)
        #expect(ex.totalRepsCompleted == 0)
    }
}

// MARK: - TemplateExercise

@Suite("TemplateExercise")
struct TemplateExerciseTests {

    @Test func nameMirrorsUnderlyingExerciseName() {
        let exercise = Exercise(name: "Back Squat", equipment: "barbell")
        let templateExercise = TemplateExercise(orderIndex: 0, exercise: exercise, targetSets: 5, targetReps: 5)
        #expect(templateExercise.name == "Back Squat")
    }

    @Test func nameTracksExerciseNameChanges() {
        let exercise = Exercise(name: "Back Squat", equipment: "barbell")
        let templateExercise = TemplateExercise(orderIndex: 0, exercise: exercise)
        exercise.name = "Front Squat"
        #expect(templateExercise.name == "Front Squat")
    }

    @Test func defaultsTargetsToZero() {
        let exercise = Exercise(name: "Plank", equipment: "bodyweight")
        let templateExercise = TemplateExercise(orderIndex: 0, exercise: exercise)
        #expect(templateExercise.targetSets == 0)
        #expect(templateExercise.targetReps == 0)
    }

    @Test func storesOrderIndex() {
        let exercise = Exercise(name: "Row", equipment: "cable")
        let templateExercise = TemplateExercise(orderIndex: 3, exercise: exercise)
        #expect(templateExercise.orderIndex == 3)
    }
}

// MARK: - EquipmentType

@Suite("EquipmentType")
struct EquipmentTypeTests {

    @Test func hasSixCases() {
        #expect(EquipmentType.allCases.count == 6)
    }

    @Test func idMatchesRawValue() {
        for equipment in EquipmentType.allCases {
            #expect(equipment.id == equipment.rawValue)
        }
    }

    @Test(arguments: [
        (EquipmentType.barbell, "Barbell"),
        (EquipmentType.dumbbell, "Dumbbell"),
        (EquipmentType.kettlebell, "Kettlebell"),
        (EquipmentType.cable, "Cable"),
        (EquipmentType.bodyweight, "Bodyweight"),
        (EquipmentType.machine, "Machine")
    ])
    func titleMapsToDisplayName(equipment: EquipmentType, expectedTitle: String) {
        #expect(equipment.title == expectedTitle)
    }
}

// MARK: - RoutineEditingLogic

@Suite("RoutineEditingLogic — filterExercises")
struct RoutineEditingLogicFilterTests {

    private let options = [
        ExerciseOption(name: "Bench Press", equipment: .barbell),
        ExerciseOption(name: "Back Squat", equipment: .barbell),
        ExerciseOption(name: "Dumbbell Row", equipment: .dumbbell)
    ]

    @Test func filtersToOnlyTheSelectedEquipment() {
        let result = RoutineEditingLogic.filterExercises(options, equipment: .barbell, searchText: "")
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.equipment == .barbell })
    }

    @Test func emptySearchTextReturnsAllMatchesForEquipment() {
        let result = RoutineEditingLogic.filterExercises(options, equipment: .barbell, searchText: "")
        #expect(result.map(\.name).sorted() == ["Back Squat", "Bench Press"])
    }

    @Test func searchTextNarrowsByNameCaseInsensitively() {
        let result = RoutineEditingLogic.filterExercises(options, equipment: .barbell, searchText: "bench")
        #expect(result.map(\.name) == ["Bench Press"])
    }

    @Test func searchTextWithNoMatchesReturnsEmpty() {
        let result = RoutineEditingLogic.filterExercises(options, equipment: .barbell, searchText: "nonexistent")
        #expect(result.isEmpty)
    }

    @Test func searchMatchingOnlyAnotherEquipmentReturnsEmpty() {
        // "Row" only exists under .dumbbell, so filtering barbell + "row" should find nothing
        let result = RoutineEditingLogic.filterExercises(options, equipment: .barbell, searchText: "row")
        #expect(result.isEmpty)
    }
}

@Suite("RoutineEditingLogic — canSaveRoutine")
struct RoutineEditingLogicCanSaveTests {

    @Test func trueWhenNameAndExercisesArePresent() {
        #expect(RoutineEditingLogic.canSaveRoutine(name: "Push Day", exerciseCount: 1))
    }

    @Test func falseWhenNameIsEmpty() {
        #expect(!RoutineEditingLogic.canSaveRoutine(name: "", exerciseCount: 1))
    }

    @Test func falseWhenNameIsOnlyWhitespace() {
        #expect(!RoutineEditingLogic.canSaveRoutine(name: "   ", exerciseCount: 1))
    }

    @Test func falseWhenNoExercisesSelected() {
        #expect(!RoutineEditingLogic.canSaveRoutine(name: "Push Day", exerciseCount: 0))
    }

    @Test func falseWhenNameEmptyAndNoExercises() {
        #expect(!RoutineEditingLogic.canSaveRoutine(name: "", exerciseCount: 0))
    }

    @Test func trimsSurroundingWhitespaceBeforeChecking() {
        #expect(RoutineEditingLogic.canSaveRoutine(name: "  Push Day  ", exerciseCount: 1))
    }
}

@Suite("RoutineEditingLogic — buildTemplateExercises")
struct RoutineEditingLogicBuildTests {

    @Test func producesOneTemplateExercisePerSelection() {
        let selections = [
            SelectedExerciseDraft(option: ExerciseOption(name: "Bench Press", equipment: .barbell)),
            SelectedExerciseDraft(option: ExerciseOption(name: "Back Squat", equipment: .barbell))
        ]
        let result = RoutineEditingLogic.buildTemplateExercises(from: selections)
        #expect(result.count == 2)
    }

    @Test func numbersOrderIndexByArrayPosition() {
        let selections = [
            SelectedExerciseDraft(option: ExerciseOption(name: "Bench Press", equipment: .barbell)),
            SelectedExerciseDraft(option: ExerciseOption(name: "Back Squat", equipment: .barbell)),
            SelectedExerciseDraft(option: ExerciseOption(name: "Deadlift", equipment: .barbell))
        ]
        let result = RoutineEditingLogic.buildTemplateExercises(from: selections)
        #expect(result.map(\.orderIndex) == [0, 1, 2])
    }

    @Test func carriesOverNameAndEquipment() {
        var selection = SelectedExerciseDraft(option: ExerciseOption(name: "Bench Press", equipment: .barbell))
        selection.targetSets = 4
        selection.targetReps = 8
        let result = RoutineEditingLogic.buildTemplateExercises(from: [selection])
        #expect(result.first?.exercise.name == "Bench Press")
        #expect(result.first?.exercise.equipment == "barbell")
        #expect(result.first?.targetSets == 4)
        #expect(result.first?.targetReps == 8)
    }

    @Test func emptySelectionsProducesEmptyResult() {
        #expect(RoutineEditingLogic.buildTemplateExercises(from: []).isEmpty)
    }
}

@Suite("RoutineEditingLogic — reindexed")
struct RoutineEditingLogicReindexTests {

    @Test func renumbersSequentiallyFromZero() {
        let a = TemplateExercise(orderIndex: 5, exercise: Exercise(name: "A", equipment: "barbell"))
        let b = TemplateExercise(orderIndex: 9, exercise: Exercise(name: "B", equipment: "barbell"))
        RoutineEditingLogic.reindexed([a, b])
        #expect(a.orderIndex == 0)
        #expect(b.orderIndex == 1)
    }

    @Test func closesGapLeftByRemoval() {
        // simulates removing the middle exercise from a 3-item routine, mirroring
        // RoutineEditor.removeExercise's array-filter-then-reindex flow
        let a = TemplateExercise(orderIndex: 0, exercise: Exercise(name: "A", equipment: "barbell"))
        let c = TemplateExercise(orderIndex: 2, exercise: Exercise(name: "C", equipment: "barbell"))
        RoutineEditingLogic.reindexed([a, c])
        #expect(a.orderIndex == 0)
        #expect(c.orderIndex == 1)
    }

    @Test func emptyArrayIsANoOp() {
        RoutineEditingLogic.reindexed([])
    }

    @Test func returnsTheSameArrayItWasGiven() {
        let a = TemplateExercise(orderIndex: 0, exercise: Exercise(name: "A", equipment: "barbell"))
        let result = RoutineEditingLogic.reindexed([a])
        #expect(result.count == 1)
        #expect(result.first === a)
    }
}

// MARK: - ExerciseOptionLibrary

@Suite("ExerciseOptionLibrary")
struct ExerciseOptionLibraryTests {

    @Test func isNotEmpty() {
        #expect(!ExerciseOptionLibrary.all.isEmpty)
    }

    @Test func everyEquipmentTypeHasAtLeastOneExercise() {
        for equipment in EquipmentType.allCases {
            let matches = ExerciseOptionLibrary.all.filter { $0.equipment == equipment }
            #expect(!matches.isEmpty, "No exercises found for \(equipment.rawValue)")
        }
    }

    @Test func noDuplicateNamesWithinTheSameEquipmentType() {
        for equipment in EquipmentType.allCases {
            let names = ExerciseOptionLibrary.all
                .filter { $0.equipment == equipment }
                .map(\.name)
            #expect(Set(names).count == names.count, "Duplicate exercise name within \(equipment.rawValue)")
        }
    }

    @Test func noExerciseHasAnEmptyName() {
        #expect(ExerciseOptionLibrary.all.allSatisfy { !$0.name.isEmpty })
    }

    @Test func filteringByEquipmentReturnsOnlyThatEquipment() {
        let barbellOnly = ExerciseOptionLibrary.all.filter { $0.equipment == .barbell }
        #expect(!barbellOnly.isEmpty)
        #expect(barbellOnly.allSatisfy { $0.equipment == .barbell })
    }
}
