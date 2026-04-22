// in-progress workout container

import Foundation
import SwiftData

@Model
final class ActiveWorkout {
    var id: UUID
    var templateID: UUID?
    var templateName: String
    var startedAt: Date
    var elapsedTime: TimeInterval
    var currentExerciseIndex: Int
    var isPaused: Bool
    var exercises: [ActiveExercise]

    init(
        id: UUID = UUID(),
        templateID: UUID? = nil,
        templateName: String,
        startedAt: Date = Date(),
        elapsedTime: TimeInterval = 0,
        currentExerciseIndex: Int = 0,
        isPaused: Bool = false,
        exercises: [ActiveExercise] = []
    ) {
        self.id = id
        self.templateID = templateID
        self.templateName = templateName
        self.startedAt = startedAt
        self.elapsedTime = elapsedTime
        self.currentExerciseIndex = currentExerciseIndex
        self.isPaused = isPaused
        self.exercises = exercises
    }
    
    convenience init(template: WorkoutTemplate) {
        let sortedExercises = template.exercises.sorted { $0.orderIndex < $1.orderIndex }

        let activeExercises = sortedExercises.map { templateExercise in
            ActiveExercise(
                orderIndex: templateExercise.orderIndex,
                name: templateExercise.exercise.name,
                completedSets: 0,
                targetSets: templateExercise.targetSets,
                targetReps: templateExercise.targetReps,
                currentRepCount: 0
            )
        }

        self.init(
            templateID: template.id,
            templateName: template.name,
            startedAt: Date(),
            elapsedTime: 0,
            currentExerciseIndex: 0,
            isPaused: false,
            exercises: activeExercises
        )
    }
}
