import Foundation
import Observation

struct WatchActiveExercise {
    let name: String
    let targetSets: Int
    let targetReps: Int
    var completedSets: Int = 0
    var currentReps: Int = 0

    var isComplete: Bool { completedSets >= targetSets }
    var setProgressText: String { "Set \(min(completedSets + 1, targetSets)) of \(targetSets)" }
}

@Observable
final class WatchWorkoutSession {
    var exercises: [WatchActiveExercise] = []
    var currentIndex: Int = 0
    var isComplete: Bool = false
    private(set) var startedAt: Date = Date()
    private(set) var templateName: String = ""
    private(set) var templateID: String? = nil

    var currentExercise: WatchActiveExercise? {
        guard currentIndex < exercises.count else { return nil }
        return exercises[currentIndex]
    }

    var isOnLastExercise: Bool {
        currentIndex == exercises.count - 1
    }

    func start(template: WatchTemplatePayload) {
        templateName = template.name
        templateID = template.id
        startedAt = Date()
        currentIndex = 0
        isComplete = false
        exercises = template.exercises
            .sorted { $0.orderIndex < $1.orderIndex }
            .map { WatchActiveExercise(name: $0.name, targetSets: $0.targetSets, targetReps: $0.targetReps) }
    }

    func incrementRep() {
        guard currentIndex < exercises.count else { return }
        exercises[currentIndex].currentReps += 1
    }

    func decrementRep() {
        guard currentIndex < exercises.count, exercises[currentIndex].currentReps > 0 else { return }
        exercises[currentIndex].currentReps -= 1
    }

    func completeSet() {
        guard currentIndex < exercises.count else { return }
        guard exercises[currentIndex].completedSets < exercises[currentIndex].targetSets else { return }

        exercises[currentIndex].completedSets += 1
        exercises[currentIndex].currentReps = 0

        if exercises[currentIndex].isComplete {
            if isOnLastExercise {
                isComplete = true
            } else {
                currentIndex += 1
            }
        }
    }

    func buildPayload() -> WatchCompletedWorkoutPayload {
        WatchCompletedWorkoutPayload(
            templateName: templateName,
            templateID: templateID,
            startedAt: startedAt,
            duration: Date().timeIntervalSince(startedAt),
            exercises: exercises.enumerated().map { idx, ex in
                WatchCompletedExercisePayload(
                    name: ex.name,
                    completedSets: ex.completedSets,
                    targetSets: ex.targetSets,
                    targetReps: ex.targetReps,
                    orderIndex: idx
                )
            }
        )
    }
}
