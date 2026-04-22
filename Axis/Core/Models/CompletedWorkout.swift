// final workout summary

import Foundation
import SwiftData

@Model
final class CompletedWorkout {
    var id: UUID
    // referrence workoutTemplate
    var templateID: UUID?
    var templateName: String
    var startedAt: Date
    var endedAt: Date
    var elapsedTime: TimeInterval
    var completedAt: Date
    var totalCalories: Double
    var averageHeartRate: Double
    var exercises: [CompletedExercise]

    init(
        id: UUID = UUID(),
        templateID: UUID? = nil,
        templateName: String,
        startedAt: Date,
        endedAt: Date = Date(),
        elapsedTime: TimeInterval = 0,
        completedAt: Date = Date(),
        totalCalories: Double = 0,
        averageHeartRate: Double = 0,
        exercises: [CompletedExercise] = []
    ) {
        self.id = id
        self.templateID = templateID
        self.templateName = templateName
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.elapsedTime = elapsedTime
        self.completedAt = completedAt
        self.totalCalories = totalCalories
        self.averageHeartRate = averageHeartRate
        self.exercises = exercises
    }
    convenience init(
        from activeWorkout: ActiveWorkout,
        endedAt: Date = Date(),
        totalCalories: Double = 0,
        averageHeartRate: Double = 0
    ) {
        let sortedExercises = activeWorkout.exercises.sorted { $0.orderIndex < $1.orderIndex }

        let completedExercises = sortedExercises.map { activeExercise in
            CompletedExercise(
                orderIndex: activeExercise.orderIndex,
                name: activeExercise.name,
                completedSets: activeExercise.completedSets,
                targetSets: activeExercise.targetSets,
                targetReps: activeExercise.targetReps,
                totalRepsCompleted: (activeExercise.completedSets * activeExercise.targetReps) + activeExercise.currentRepCount
            )
        }

        self.init(
            templateID: activeWorkout.templateID,
            templateName: activeWorkout.templateName,
            startedAt: activeWorkout.startedAt,
            endedAt: endedAt,
            elapsedTime: activeWorkout.elapsedTime,
            totalCalories: totalCalories,
            averageHeartRate: averageHeartRate,
            exercises: completedExercises
        )
    }
}
