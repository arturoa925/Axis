
// a collection of template exercises 

import Foundation
import SwiftData

@Model
final class WorkoutTemplate {
    var id: UUID
    var name: String
    var createdAt: Date
    var exercises: [TemplateExercise]
    
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date = Date(),
        exercises: [TemplateExercise] = []
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.exercises = exercises
    }
}
