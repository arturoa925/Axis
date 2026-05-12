//
//  MainTabView.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        RoutinesHome()
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [
            Exercise.self,
            TemplateExercise.self,
            WorkoutTemplate.self,
            // ActiveExercise.self,
            // ActiveWorkout.self,
            CompletedExercise.self,
            CompletedWorkout.self
        ], inMemory: true)
}
