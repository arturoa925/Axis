//
//  MainTabView.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import SwiftUI
import SwiftData

// default home view
// tab nav is saved in RoutinesHome

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
            CompletedExercise.self,
            CompletedWorkout.self
        ], inMemory: true)
}
