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

    convenience init(from watchPayload: WatchCompletedWorkoutPayload, endedAt: Date = Date()) {
        let completedExercises = watchPayload.exercises.map { ex in
            CompletedExercise(
                orderIndex: ex.orderIndex,
                name: ex.name,
                completedSets: ex.completedSets,
                targetSets: ex.targetSets,
                targetReps: ex.targetReps,
                totalRepsCompleted: ex.completedSets * ex.targetReps
            )
        }
        self.init(
            templateID: watchPayload.templateID.flatMap { UUID(uuidString: $0) },
            templateName: watchPayload.templateName,
            startedAt: watchPayload.startedAt,
            endedAt: endedAt,
            elapsedTime: watchPayload.duration,
            exercises: completedExercises
        )
    }
}
