import Foundation

// pure, view-independent logic shared by CreateRoutine, RoutineEditor, and
// AddExerciseSection — kept separate from SwiftUI/SwiftData so it's directly testable
enum RoutineEditingLogic {

    // filters the exercise library by equipment, then by a case-insensitive name search
    static func filterExercises(
        _ options: [ExerciseOption],
        equipment: EquipmentType,
        searchText: String
    ) -> [ExerciseOption] {
        options
            .filter { $0.equipment == equipment }
            .filter { option in
                searchText.isEmpty || option.name.localizedCaseInsensitiveContains(searchText)
            }
    }

    // a routine needs a non-blank name and at least one exercise before it can be saved
    static func canSaveRoutine(name: String, exerciseCount: Int) -> Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && exerciseCount > 0
    }

    // builds persistable TemplateExercises (with fresh Exercise records) from draft
    // selections, numbering orderIndex by array position
    static func buildTemplateExercises(from selections: [SelectedExerciseDraft]) -> [TemplateExercise] {
        selections.enumerated().map { index, selection in
            let exercise = Exercise(
                name: selection.option.name,
                equipment: selection.option.equipment.rawValue
            )
            return TemplateExercise(
                orderIndex: index,
                exercise: exercise,
                targetSets: selection.targetSets,
                targetReps: selection.targetReps
            )
        }
    }

    // renumbers orderIndex to match array position, closing any gap left by a removal
    @discardableResult
    static func reindexed(_ exercises: [TemplateExercise]) -> [TemplateExercise] {
        for (index, exercise) in exercises.enumerated() {
            exercise.orderIndex = index
        }
        return exercises
    }
}
