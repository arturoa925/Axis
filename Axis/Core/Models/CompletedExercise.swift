// finished history snapshot of an exercise

import Foundation
import SwiftData

@Model
final class CompletedExercise {
    var id: UUID
    var orderIndex: Int
    var name: String
    var completedSets: Int
    var targetSets: Int
    var targetReps: Int
    var totalRepsCompleted: Int

    init(
        id: UUID = UUID(),
        orderIndex: Int,
        name: String,
        completedSets: Int = 0,
        targetSets: Int = 0,
        targetReps: Int = 0,
        totalRepsCompleted: Int = 0
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.name = name
        self.completedSets = completedSets
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.totalRepsCompleted = totalRepsCompleted
    }
}
