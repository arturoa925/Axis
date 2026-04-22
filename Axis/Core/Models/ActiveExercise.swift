// temporary state for currect, live, active exericse

import Foundation
import SwiftData

@Model
final class ActiveExercise {
    var id: UUID
    var orderIndex: Int
    var name: String
    var completedSets: Int = 0
    var targetSets: Int = 0
    var targetReps: Int = 0
    var currentRepCount: Int = 0
    var isComplete: Bool {
        completedSets >= targetSets && targetSets > 0
    }
    
    init(id: UUID = UUID(), orderIndex: Int, name: String, completedSets: Int, targetSets: Int, targetReps: Int, currentRepCount: Int) {
        self.id = id
        self.orderIndex = orderIndex
        self.name = name
        self.completedSets = completedSets
        self.targetSets = targetSets
        self.targetReps = targetReps
        self.currentRepCount = currentRepCount
    }
}
