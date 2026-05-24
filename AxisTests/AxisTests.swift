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
