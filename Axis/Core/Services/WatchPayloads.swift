import Foundation

// Template data sent from phone to watch
struct WatchTemplatePayload: Codable, Identifiable {
    let id: String
    let name: String
    let exercises: [WatchExercisePayload]
}

struct WatchExercisePayload: Codable {
    let name: String
    let targetSets: Int
    let targetReps: Int
    let orderIndex: Int
}

// Completed workout sent from watch to phone
struct WatchCompletedWorkoutPayload: Codable, Equatable {
    let templateName: String
    let templateID: String?
    let startedAt: Date
    let duration: TimeInterval
    let exercises: [WatchCompletedExercisePayload]
}

struct WatchCompletedExercisePayload: Codable, Equatable {
    let name: String
    let completedSets: Int
    let targetSets: Int
    let targetReps: Int
    let orderIndex: Int
}

enum WatchMessageKey {
    static let templates = "templates"
    static let completedWorkout = "completedWorkout"
}
