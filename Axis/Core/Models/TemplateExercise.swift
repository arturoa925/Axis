// saves exercise details
// connects to a routine

import Foundation
import SwiftData

@Model
final class TemplateExercise {
    var id: UUID
    var orderIndex: Int
    var exercise: Exercise
    var targetSets: Int
    var targetReps: Int
    var name: String { exercise.name }
    
    init(
        id: UUID = UUID(),
        orderIndex: Int,
        exercise: Exercise,
        targetSets: Int = 0,
        targetReps: Int = 0
    ) {
        self.id = id
        self.orderIndex = orderIndex
        self.exercise = exercise
        self.targetSets = targetSets
        self.targetReps = targetReps
    }
}
