import Testing
import Foundation
@testable import Axis

// MARK: - Test Helpers

private func makeTemplate(
    name: String = "Test Routine",
    exercises: [(name: String, sets: Int, reps: Int)] = [("Bench Press", 3, 10)]
) -> WorkoutTemplate {
    let templateExercises = exercises.enumerated().map { index, ex in
        let exercise = Exercise(name: ex.name, equipment: "barbell")
        return TemplateExercise(orderIndex: index, exercise: exercise, targetSets: ex.sets, targetReps: ex.reps)
    }
    return WorkoutTemplate(name: name, exercises: templateExercises)
}

// MARK: - WorkoutSessionManager

@Suite("WorkoutSessionManager")
struct WorkoutSessionManagerTests {

    // MARK: Starting a Workout

    @Test func startWorkout_setsActiveWorkout() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(name: "Push Day"))

        #expect(manager.activeWorkout != nil)
        #expect(manager.activeWorkout?.templateName == "Push Day")
        #expect(manager.didCompleteWorkout == false)
    }

    @Test func startWorkout_beginsAtFirstExercise() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)]))

        #expect(manager.activeWorkout?.currentExerciseIndex == 0)
        #expect(manager.currentExercise?.name == "Bench Press")
    }

    @Test func startWorkout_sortedByOrderIndex() {
        let manager = WorkoutSessionManager()
        // Pass exercises in reverse order to confirm sorting
        let ex1 = Exercise(name: "Squat", equipment: "barbell")
        let ex2 = Exercise(name: "Bench Press", equipment: "barbell")
        let te1 = TemplateExercise(orderIndex: 1, exercise: ex1, targetSets: 3, targetReps: 5)
        let te2 = TemplateExercise(orderIndex: 0, exercise: ex2, targetSets: 3, targetReps: 10)
        let template = WorkoutTemplate(name: "Test", exercises: [te1, te2])

        manager.startWorkout(from: template)

        #expect(manager.currentExercise?.name == "Bench Press")
    }

    // MARK: Rep Tracking

    @Test func incrementRep_increasesCount() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())

        manager.incrementRep()
        manager.incrementRep()

        #expect(manager.currentExercise?.currentRepCount == 2)
    }

    @Test func decrementRep_decreasesCount() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())
        manager.incrementRep()
        manager.incrementRep()

        manager.decrementRep()

        #expect(manager.currentExercise?.currentRepCount == 1)
    }

    @Test func decrementRep_doesNotGoBelowZero() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())

        manager.decrementRep()

        #expect(manager.currentExercise?.currentRepCount == 0)
    }

    @Test func incrementRep_doesNothingWhenPaused() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())
        manager.pauseWorkout()

        manager.incrementRep()

        #expect(manager.currentExercise?.currentRepCount == 0)
    }

    @Test func decrementRep_doesNothingWhenPaused() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())
        manager.incrementRep()
        manager.pauseWorkout()

        manager.decrementRep()

        #expect(manager.currentExercise?.currentRepCount == 1)
    }

    // MARK: Set Completion

    @Test func completeSet_incrementsCompletedSets() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10)]))

        manager.completeSet()

        #expect(manager.currentExercise?.completedSets == 1)
    }

    @Test func completeSet_resetsRepCount() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10)]))
        manager.incrementRep()
        manager.incrementRep()

        manager.completeSet()

        #expect(manager.currentExercise?.currentRepCount == 0)
    }

    @Test func completeSet_doesNothingWhenPaused() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10)]))
        manager.pauseWorkout()

        manager.completeSet()

        #expect(manager.currentExercise?.completedSets == 0)
    }

    @Test func completeSet_doesNothingWhenAlreadyAtTargetSets() {
        let manager = WorkoutSessionManager()
        // 1-set, 1-exercise workout so completing the set sets didCompleteWorkout
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 1, 10)]))
        manager.completeSet() // completes the only set

        let setsAfterFirst = manager.activeWorkout?.exercises.first?.completedSets ?? 0
        manager.completeSet() // should be blocked by the guard

        #expect(manager.activeWorkout?.exercises.first?.completedSets == setsAfterFirst)
    }

    @Test func completeSet_advancesToNextExercise() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [
            ("Bench Press", 1, 10),
            ("Squat", 3, 10)
        ]))

        manager.completeSet() // completes bench press (1 set)

        #expect(manager.activeWorkout?.currentExerciseIndex == 1)
        #expect(manager.currentExercise?.name == "Squat")
    }

    @Test func completeSet_setsDidCompleteWorkoutOnFinalSet() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 1, 10)]))

        manager.completeSet()

        #expect(manager.didCompleteWorkout == true)
    }

    // MARK: Pause & Resume

    @Test func pauseWorkout_setsIsPaused() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())

        manager.pauseWorkout()

        #expect(manager.activeWorkout?.isPaused == true)
    }

    @Test func resumeWorkout_clearsIsPaused() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())
        manager.pauseWorkout()

        manager.resumeWorkout()

        #expect(manager.activeWorkout?.isPaused == false)
    }

    // MARK: Timer

    @Test func tickElapsedTime_incrementsTime() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())

        manager.tickElapsedTime()
        manager.tickElapsedTime()
        manager.tickElapsedTime()

        #expect(manager.activeWorkout?.elapsedTime == 3)
    }

    @Test func tickElapsedTime_doesNothingWhenPaused() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())
        manager.pauseWorkout()

        manager.tickElapsedTime()

        #expect(manager.activeWorkout?.elapsedTime == 0)
    }

    // MARK: Navigation

    @Test func goToNextExercise_advancesIndex() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)]))

        manager.goToNextExercise()

        #expect(manager.activeWorkout?.currentExerciseIndex == 1)
    }

    @Test func goToNextExercise_doesNotGoPassLastExercise() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10)]))

        manager.goToNextExercise()

        #expect(manager.activeWorkout?.currentExerciseIndex == 0)
    }

    @Test func goToPreviousExercise_decrementsIndex() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)]))
        manager.goToNextExercise()

        manager.goToPreviousExercise()

        #expect(manager.activeWorkout?.currentExerciseIndex == 0)
    }

    @Test func goToPreviousExercise_doesNotGoBelowZero() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10)]))

        manager.goToPreviousExercise()

        #expect(manager.activeWorkout?.currentExerciseIndex == 0)
    }

    // MARK: First / Last Exercise Flags

    @Test func isOnFirstExercise_trueAtStart() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)]))

        #expect(manager.isOnFirstExercise == true)
    }

    @Test func isOnFirstExercise_falseAfterAdvancing() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)]))
        manager.goToNextExercise()

        #expect(manager.isOnFirstExercise == false)
    }

    @Test func isOnLastExercise_trueAtEnd() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)]))
        manager.goToNextExercise()

        #expect(manager.isOnLastExercise == true)
    }

    @Test func isOnFirstAndLastExercise_bothTrueForSingleExercise() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(exercises: [("Bench Press", 3, 10)]))

        #expect(manager.isOnFirstExercise == true)
        #expect(manager.isOnLastExercise == true)
    }

    // MARK: Finish & Cancel

    @Test func finishWorkout_returnsCompletedWorkout() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate(name: "Push Day"))

        let completed = manager.finishWorkout()

        #expect(completed != nil)
        #expect(completed?.templateName == "Push Day")
    }

    @Test func finishWorkout_clearsActiveWorkout() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())

        _ = manager.finishWorkout()

        #expect(manager.activeWorkout == nil)
    }

    @Test func finishWorkout_returnsNilWithNoActiveWorkout() {
        let manager = WorkoutSessionManager()

        #expect(manager.finishWorkout() == nil)
    }

    @Test func cancelWorkout_clearsActiveWorkout() {
        let manager = WorkoutSessionManager()
        manager.startWorkout(from: makeTemplate())

        manager.cancelWorkout()

        #expect(manager.activeWorkout == nil)
        #expect(manager.didCompleteWorkout == false)
    }
}

// MARK: - CompletedWorkout

@Suite("CompletedWorkout")
struct CompletedWorkoutTests {

    @Test func convenienceInit_capturesTemplateName() {
        let active = ActiveWorkout(template: makeTemplate(name: "Push Day"))

        let completed = CompletedWorkout(from: active)

        #expect(completed.templateName == "Push Day")
    }

    @Test func convenienceInit_capturesElapsedTime() {
        let active = ActiveWorkout(template: makeTemplate())
        active.elapsedTime = 2400

        let completed = CompletedWorkout(from: active)

        #expect(completed.elapsedTime == 2400)
    }

    @Test func convenienceInit_capturesTemplateID() {
        let template = makeTemplate()
        let active = ActiveWorkout(template: template)

        let completed = CompletedWorkout(from: active)

        #expect(completed.templateID == template.id)
    }

    @Test func convenienceInit_mapsAllExercises() {
        let active = ActiveWorkout(template: makeTemplate(exercises: [
            ("Bench Press", 3, 10),
            ("Squat", 4, 8),
            ("Deadlift", 1, 5)
        ]))

        let completed = CompletedWorkout(from: active)

        #expect(completed.exercises.count == 3)
    }

    @Test func convenienceInit_preservesExerciseTargets() {
        let active = ActiveWorkout(template: makeTemplate(exercises: [("Bench Press", 3, 10)]))

        let completed = CompletedWorkout(from: active)
        let exercise = completed.exercises.first

        #expect(exercise?.name == "Bench Press")
        #expect(exercise?.targetSets == 3)
        #expect(exercise?.targetReps == 10)
    }

    @Test func convenienceInit_calculatesTotalRepsCompleted() {
        let active = ActiveWorkout(template: makeTemplate(exercises: [("Bench Press", 3, 10)]))
        // Simulate 2 full sets + 5 partial reps into the third
        let exercise = active.exercises[0]
        exercise.completedSets = 2
        exercise.currentRepCount = 5

        let completed = CompletedWorkout(from: active)

        // (2 completed sets × 10 target reps) + 5 current reps = 25
        #expect(completed.exercises[0].totalRepsCompleted == 25)
    }

    @Test func convenienceInit_exercisesOrderedByOrderIndex() {
        let ex1 = Exercise(name: "Squat", equipment: "barbell")
        let ex2 = Exercise(name: "Bench Press", equipment: "barbell")
        let te1 = TemplateExercise(orderIndex: 1, exercise: ex1, targetSets: 3, targetReps: 5)
        let te2 = TemplateExercise(orderIndex: 0, exercise: ex2, targetSets: 3, targetReps: 10)
        let active = ActiveWorkout(template: WorkoutTemplate(name: "Test", exercises: [te1, te2]))

        let completed = CompletedWorkout(from: active)
        let sorted = completed.exercises.sorted { $0.orderIndex < $1.orderIndex }

        #expect(sorted[0].name == "Bench Press")
        #expect(sorted[1].name == "Squat")
    }
}

// MARK: - ActiveExercise

@Suite("ActiveExercise")
struct ActiveExerciseTests {

    @Test func isComplete_trueWhenCompletedSetsReachTarget() {
        let exercise = ActiveExercise(orderIndex: 0, name: "Bench Press", completedSets: 3, targetSets: 3, targetReps: 10, currentRepCount: 0)

        #expect(exercise.isComplete == true)
    }

    @Test func isComplete_falseWhenBelowTarget() {
        let exercise = ActiveExercise(orderIndex: 0, name: "Bench Press", completedSets: 2, targetSets: 3, targetReps: 10, currentRepCount: 0)

        #expect(exercise.isComplete == false)
    }

    @Test func isComplete_falseWhenTargetSetsIsZero() {
        let exercise = ActiveExercise(orderIndex: 0, name: "Bench Press", completedSets: 0, targetSets: 0, targetReps: 10, currentRepCount: 0)

        #expect(exercise.isComplete == false)
    }
}
