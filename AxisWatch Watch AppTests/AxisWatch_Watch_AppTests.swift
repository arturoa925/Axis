import Testing
import Foundation
@testable import AxisWatch_Watch_App

// MARK: - Helpers

private func makeTemplate(
    name: String = "Test Routine",
    id: String = "test-id",
    exercises: [(name: String, sets: Int, reps: Int)] = [("Bench Press", 3, 10)]
) -> WatchTemplatePayload {
    WatchTemplatePayload(
        id: id,
        name: name,
        exercises: exercises.enumerated().map { index, ex in
            WatchExercisePayload(name: ex.name, targetSets: ex.sets, targetReps: ex.reps, orderIndex: index)
        }
    )
}

private func makeSession(
    exercises: [(name: String, sets: Int, reps: Int)] = [("Bench Press", 3, 10)]
) -> WatchWorkoutSession {
    let session = WatchWorkoutSession()
    session.start(template: makeTemplate(exercises: exercises))
    return session
}

// MARK: - WatchActiveExercise

@Suite("WatchActiveExercise")
struct WatchActiveExerciseTests {

    @Test func isComplete_trueWhenCompletedSetsReachTarget() {
        let exercise = WatchActiveExercise(name: "Bench Press", targetSets: 3, targetReps: 10, completedSets: 3)

        #expect(exercise.isComplete == true)
    }

    @Test func isComplete_falseWhenBelowTarget() {
        let exercise = WatchActiveExercise(name: "Bench Press", targetSets: 3, targetReps: 10, completedSets: 2)

        #expect(exercise.isComplete == false)
    }

    @Test func isComplete_falseAtZero() {
        let exercise = WatchActiveExercise(name: "Bench Press", targetSets: 3, targetReps: 10)

        #expect(exercise.isComplete == false)
    }

    @Test func setProgressText_showsSetOneOnFresh() {
        let exercise = WatchActiveExercise(name: "Bench Press", targetSets: 3, targetReps: 10)

        #expect(exercise.setProgressText == "Set 1 of 3")
    }

    @Test func setProgressText_advancesAfterCompletingSet() {
        var exercise = WatchActiveExercise(name: "Bench Press", targetSets: 3, targetReps: 10)
        exercise.completedSets = 1

        #expect(exercise.setProgressText == "Set 2 of 3")
    }

    @Test func setProgressText_clampsToTargetWhenComplete() {
        var exercise = WatchActiveExercise(name: "Bench Press", targetSets: 3, targetReps: 10)
        exercise.completedSets = 3

        #expect(exercise.setProgressText == "Set 3 of 3")
    }
}

// MARK: - WatchWorkoutSession: start()

@Suite("WatchWorkoutSession — start")
struct WatchWorkoutSessionStartTests {

    @Test func start_setsTemplateName() {
        let session = WatchWorkoutSession()
        session.start(template: makeTemplate(name: "Push Day"))

        #expect(session.templateName == "Push Day")
    }

    @Test func start_setsTemplateID() {
        let session = WatchWorkoutSession()
        session.start(template: makeTemplate(id: "abc-123"))

        #expect(session.templateID == "abc-123")
    }

    @Test func start_beginsAtIndexZero() {
        let session = makeSession(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)])

        #expect(session.currentIndex == 0)
    }

    @Test func start_createsCorrectExerciseCount() {
        let session = makeSession(exercises: [("A", 3, 10), ("B", 3, 10), ("C", 3, 10)])

        #expect(session.exercises.count == 3)
    }

    @Test func start_sortsExercisesByOrderIndex() {
        let session = WatchWorkoutSession()
        session.start(template: WatchTemplatePayload(
            id: "1",
            name: "Test",
            exercises: [
                WatchExercisePayload(name: "Squat", targetSets: 3, targetReps: 5, orderIndex: 1),
                WatchExercisePayload(name: "Bench Press", targetSets: 3, targetReps: 10, orderIndex: 0)
            ]
        ))

        #expect(session.exercises[0].name == "Bench Press")
        #expect(session.exercises[1].name == "Squat")
    }

    @Test func start_resetsIsComplete() {
        let session = makeSession(exercises: [("Bench Press", 1, 10)])
        session.completeSet()
        #expect(session.isComplete == true)

        session.start(template: makeTemplate())

        #expect(session.isComplete == false)
    }

    @Test func start_resetsCurrentIndex() {
        let session = makeSession(exercises: [("A", 1, 10), ("B", 3, 10)])
        session.completeSet() // advances to index 1

        session.start(template: makeTemplate())

        #expect(session.currentIndex == 0)
    }
}

// MARK: - WatchWorkoutSession: incrementRep / decrementRep

@Suite("WatchWorkoutSession — rep tracking")
struct WatchWorkoutSessionRepTests {

    @Test func incrementRep_increasesCurrentReps() {
        let session = makeSession()

        session.incrementRep()

        #expect(session.currentExercise?.currentReps == 1)
    }

    @Test func incrementRep_stacksCorrectly() {
        let session = makeSession()

        session.incrementRep()
        session.incrementRep()
        session.incrementRep()

        #expect(session.currentExercise?.currentReps == 3)
    }

    @Test func decrementRep_decreasesCurrentReps() {
        let session = makeSession()
        session.incrementRep()
        session.incrementRep()

        session.decrementRep()

        #expect(session.currentExercise?.currentReps == 1)
    }

    @Test func decrementRep_doesNotGoBelowZero() {
        let session = makeSession()

        session.decrementRep()

        #expect(session.currentExercise?.currentReps == 0)
    }

    @Test func decrementRep_multipleCallsStayAtZero() {
        let session = makeSession()

        session.decrementRep()
        session.decrementRep()
        session.decrementRep()

        #expect(session.currentExercise?.currentReps == 0)
    }
}

// MARK: - WatchWorkoutSession: completeSet()

@Suite("WatchWorkoutSession — completeSet")
struct WatchWorkoutSessionCompleteSetTests {

    @Test func completeSet_incrementsCompletedSets() {
        let session = makeSession(exercises: [("Bench Press", 3, 10)])

        session.completeSet()

        #expect(session.exercises[0].completedSets == 1)
    }

    @Test func completeSet_resetsCurrentReps() {
        let session = makeSession(exercises: [("Bench Press", 3, 10)])
        session.incrementRep()
        session.incrementRep()

        session.completeSet()

        #expect(session.exercises[0].currentReps == 0)
    }

    @Test func completeSet_doesNothingWhenAlreadyAtTargetSets() {
        let session = makeSession(exercises: [("Bench Press", 1, 10)])
        session.completeSet() // finishes only set → isComplete = true

        let setsAfter = session.exercises[0].completedSets
        session.completeSet() // should be blocked

        #expect(session.exercises[0].completedSets == setsAfter)
    }

    @Test func completeSet_advancesToNextExercise() {
        let session = makeSession(exercises: [("Bench Press", 1, 10), ("Squat", 3, 10)])

        session.completeSet() // finishes bench press (1 set)

        #expect(session.currentIndex == 1)
        #expect(session.currentExercise?.name == "Squat")
    }

    @Test func completeSet_doesNotAdvancePastLastExercise() {
        let session = makeSession(exercises: [("Bench Press", 3, 10)])
        session.completeSet()
        session.completeSet()
        session.completeSet()

        #expect(session.currentIndex == 0)
    }

    @Test func completeSet_setsIsCompleteOnFinalSetOfFinalExercise() {
        let session = makeSession(exercises: [("Bench Press", 1, 10)])

        session.completeSet()

        #expect(session.isComplete == true)
    }

    @Test func completeSet_doesNotSetIsCompleteOnIntermediateExercise() {
        let session = makeSession(exercises: [("Bench Press", 1, 10), ("Squat", 3, 10)])

        session.completeSet() // finishes bench, advances to squat

        #expect(session.isComplete == false)
    }

    @Test func completeSet_fullWorkflowMultipleExercises() {
        let session = makeSession(exercises: [("A", 2, 8), ("B", 1, 10)])

        session.completeSet() // A set 1
        session.completeSet() // A set 2 → advance to B
        #expect(session.currentIndex == 1)

        session.completeSet() // B set 1 → complete
        #expect(session.isComplete == true)
    }
}

// MARK: - WatchWorkoutSession: isOnLastExercise

@Suite("WatchWorkoutSession — isOnLastExercise")
struct WatchWorkoutSessionLastExerciseTests {

    @Test func isOnLastExercise_trueForSingleExercise() {
        let session = makeSession(exercises: [("Bench Press", 3, 10)])

        #expect(session.isOnLastExercise == true)
    }

    @Test func isOnLastExercise_falseWhenNotAtLast() {
        let session = makeSession(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)])

        #expect(session.isOnLastExercise == false)
    }

    @Test func isOnLastExercise_trueAfterAdvancing() {
        let session = makeSession(exercises: [("Bench Press", 1, 10), ("Squat", 3, 10)])
        session.completeSet() // advances to squat

        #expect(session.isOnLastExercise == true)
    }
}

// MARK: - WatchWorkoutSession: currentExercise

@Suite("WatchWorkoutSession — currentExercise")
struct WatchWorkoutSessionCurrentExerciseTests {

    @Test func currentExercise_returnsFirstOnStart() {
        let session = makeSession(exercises: [("Bench Press", 3, 10), ("Squat", 3, 10)])

        #expect(session.currentExercise?.name == "Bench Press")
    }

    @Test func currentExercise_updatesAfterAdvancing() {
        let session = makeSession(exercises: [("Bench Press", 1, 10), ("Squat", 3, 10)])
        session.completeSet()

        #expect(session.currentExercise?.name == "Squat")
    }

    @Test func currentExercise_nilWhenNoExercises() {
        let session = WatchWorkoutSession()
        session.start(template: makeTemplate(exercises: []))

        #expect(session.currentExercise == nil)
    }
}

// MARK: - WatchWorkoutSession: buildPayload()

@Suite("WatchWorkoutSession — buildPayload")
struct WatchWorkoutSessionBuildPayloadTests {

    @Test func buildPayload_hasCorrectTemplateName() {
        let session = WatchWorkoutSession()
        session.start(template: makeTemplate(name: "Leg Day"))

        let payload = session.buildPayload()

        #expect(payload.templateName == "Leg Day")
    }

    @Test func buildPayload_hasCorrectTemplateID() {
        let session = WatchWorkoutSession()
        session.start(template: makeTemplate(id: "xyz-789"))

        let payload = session.buildPayload()

        #expect(payload.templateID == "xyz-789")
    }

    @Test func buildPayload_hasCorrectExerciseCount() {
        let session = makeSession(exercises: [("A", 3, 10), ("B", 2, 8)])

        let payload = session.buildPayload()

        #expect(payload.exercises.count == 2)
    }

    @Test func buildPayload_capturesCompletedSets() {
        let session = makeSession(exercises: [("Bench Press", 3, 10)])
        session.completeSet()
        session.completeSet()

        let payload = session.buildPayload()

        #expect(payload.exercises[0].completedSets == 2)
    }

    @Test func buildPayload_preservesExerciseTargets() {
        let session = makeSession(exercises: [("Bench Press", 3, 10)])

        let payload = session.buildPayload()

        #expect(payload.exercises[0].name == "Bench Press")
        #expect(payload.exercises[0].targetSets == 3)
        #expect(payload.exercises[0].targetReps == 10)
    }

    @Test func buildPayload_durationIsNonNegative() {
        let session = makeSession()

        let payload = session.buildPayload()

        #expect(payload.duration >= 0)
    }

    @Test func buildPayload_orderIndexMatchesExercisePosition() {
        let session = makeSession(exercises: [("A", 3, 10), ("B", 3, 10), ("C", 3, 10)])

        let payload = session.buildPayload()
        let sorted = payload.exercises.sorted { $0.orderIndex < $1.orderIndex }

        #expect(sorted[0].name == "A")
        #expect(sorted[1].name == "B")
        #expect(sorted[2].name == "C")
    }
}
