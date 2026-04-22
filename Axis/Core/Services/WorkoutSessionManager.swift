//
//  WorkoutSessionManager.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import Foundation
import Observation

@Observable
final class WorkoutSessionManager {
    var activeWorkout: ActiveWorkout?
    var didCompleteWorkout: Bool = false

    var isOnFirstExercise: Bool {
        guard let activeWorkout else { return false }
        return activeWorkout.currentExerciseIndex == 0
    }

    var isOnLastExercise: Bool {
        guard let activeWorkout else { return false }
        let sortedExercises = activeWorkout.exercises.sorted { $0.orderIndex < $1.orderIndex }
        guard !sortedExercises.isEmpty else { return false }
        return activeWorkout.currentExerciseIndex == sortedExercises.count - 1
    }

    var currentSetDisplay: Int {
        guard let currentExercise else { return 1 }
        return min(currentExercise.completedSets + 1, max(currentExercise.targetSets, 1))
    }

    var currentSetProgressText: String {
        guard let currentExercise else { return "Set 1 of 1" }
        let totalSets = max(currentExercise.targetSets, 1)
        let currentSet = min(currentExercise.completedSets + 1, totalSets)
        return "Set \(currentSet) of \(totalSets)"
    }

    var currentRepProgressText: String {
        guard let currentExercise else { return "0 / 0 reps" }
        let targetReps = max(currentExercise.targetReps, 0)
        let currentReps = max(currentExercise.currentRepCount, 0)
        return "\(currentReps) / \(targetReps) reps"
    }

    var currentExercise: ActiveExercise? {
        guard let activeWorkout else { return nil }
        guard activeWorkout.currentExerciseIndex >= 0,
              activeWorkout.currentExerciseIndex < activeWorkout.exercises.count else {
            return nil
        }
        return activeWorkout.exercises.sorted { $0.orderIndex < $1.orderIndex }[activeWorkout.currentExerciseIndex]
    }

    func startWorkout(from template: WorkoutTemplate) {
        didCompleteWorkout = false
        activeWorkout = ActiveWorkout(template: template)
    }

    func pauseWorkout() {
        activeWorkout?.isPaused = true
    }

    func resumeWorkout() {
        activeWorkout?.isPaused = false
    }

    func tickElapsedTime() {
        guard let activeWorkout, !activeWorkout.isPaused else { return }
        activeWorkout.elapsedTime += 1
    }

    func incrementRep() {
        guard let activeWorkout else { return }
        guard let currentExercise else { return }
        guard !activeWorkout.isPaused else { return }

        currentExercise.currentRepCount += 1
    }

    func decrementRep() {
        guard let activeWorkout else { return }
        guard let currentExercise else { return }
        guard !activeWorkout.isPaused else { return }
        guard currentExercise.currentRepCount > 0 else { return }

        currentExercise.currentRepCount -= 1
    }

    func completeSet() {
        guard let activeWorkout else { return }
        guard let currentExercise else { return }
        guard !activeWorkout.isPaused else { return }
        guard currentExercise.completedSets < currentExercise.targetSets else { return }

        currentExercise.completedSets += 1
        currentExercise.currentRepCount = 0

        if currentExercise.completedSets >= currentExercise.targetSets {
            if isOnLastExercise {
                didCompleteWorkout = true
                
            } else {
                activeWorkout.currentExerciseIndex += 1
            }
        }
    }

    func goToNextExercise() {
        guard let activeWorkout else { return }
        let sortedExercises = activeWorkout.exercises.sorted { $0.orderIndex < $1.orderIndex }
        let nextIndex = activeWorkout.currentExerciseIndex + 1

        guard nextIndex < sortedExercises.count else { return }

        activeWorkout.currentExerciseIndex = nextIndex
    }

    func goToPreviousExercise() {
        guard let activeWorkout else { return }
        let previousIndex = activeWorkout.currentExerciseIndex - 1

        guard previousIndex >= 0 else { return }

        activeWorkout.currentExerciseIndex = previousIndex
    }

    func cancelWorkout() {
        didCompleteWorkout = false
        activeWorkout = nil
    }

    func finishWorkout() -> CompletedWorkout? {
        guard let activeWorkout else { return nil }
        let completedWorkout = CompletedWorkout(from: activeWorkout)
        didCompleteWorkout = true
        self.activeWorkout = nil
        return completedWorkout
    }
}
