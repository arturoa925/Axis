//
//  RootView.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import SwiftUI
import Combine
import UIKit

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var showWorkoutSessionTest = true

    var body: some View {
        if showWorkoutSessionTest {
            WorkoutSessionTestPlaceholderView()
        } else if appState.hasCompletedOnboarding {
            MainTabView()
        } else {
            Text("Onboarding")
        }
    }
}

struct WorkoutSessionTestPlaceholderView: View {
    @State private var sessionManager = WorkoutSessionManager()
    @State private var completedWorkout: CompletedWorkout?
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Button("Start Sample Workout") {
                    startSampleWorkout()
                }
                .buttonStyle(.borderedProminent)

                Text("AXIS TITLE TEST")
                    .font(AppTypography.title)

                Text("Body text sample")
                    .font(AppTypography.body)

                if let activeWorkout = sessionManager.activeWorkout {
                    Text("Workout: \(activeWorkout.templateName)")
                        .font(AppTypography.title)

                    Text("Elapsed: \(Int(activeWorkout.elapsedTime)) sec")

                    if let currentExercise = sessionManager.currentExercise {
                        Text("Exercise: \(currentExercise.name)")
                            .font(AppTypography.body)
                    }

                    Text(sessionManager.currentSetProgressText)
                    Text(sessionManager.currentRepProgressText)

                    HStack {
                        Button("- Rep") {
                            sessionManager.decrementRep()
                        }
                        .buttonStyle(.bordered)

                        Button("+ Rep") {
                            sessionManager.incrementRep()
                        }
                        .buttonStyle(.bordered)
                    }

                    Button("Complete Set") {
                        sessionManager.completeSet()

                        if sessionManager.didCompleteWorkout {
                            completedWorkout = sessionManager.finishWorkout()
                        }
                    }
                    .buttonStyle(.borderedProminent)

                    HStack {
                        Button("Previous") {
                            sessionManager.goToPreviousExercise()
                        }
                        .buttonStyle(.bordered)
                        .disabled(sessionManager.isOnFirstExercise)

                        Button("Next") {
                            sessionManager.goToNextExercise()
                        }
                        .buttonStyle(.bordered)
                        .disabled(sessionManager.isOnLastExercise)
                    }

                    HStack {
                        Button(activeWorkout.isPaused ? "Resume" : "Pause") {
                            if activeWorkout.isPaused {
                                sessionManager.resumeWorkout()
                            } else {
                                sessionManager.pauseWorkout()
                            }
                        }
                        .buttonStyle(.bordered)

                        Button("Tick +1s") {
                            sessionManager.tickElapsedTime()
                        }
                        .buttonStyle(.bordered)
                    }

                    HStack {
                        Button("Finish Workout") {
                            completedWorkout = sessionManager.finishWorkout()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Cancel") {
                            sessionManager.cancelWorkout()
                            completedWorkout = nil
                        }
                        .buttonStyle(.bordered)
                    }
                }

                if sessionManager.didCompleteWorkout {
                    Text("Workout Complete")
                        .font(.headline)
                }

                if let completedWorkout {
                    Text("Saved: \(completedWorkout.templateName)")
                    Text("Exercises: \(completedWorkout.exercises.count)")
                    Text("Duration: \(Int(completedWorkout.elapsedTime)) sec")
                    Text("Completed: \(completedWorkout.completedAt.formatted(date: .abbreviated, time: .shortened))")
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Axis")
            .onReceive(timer) { _ in
                sessionManager.tickElapsedTime()
            }
            .onAppear {
                for family in UIFont.familyNames.sorted() {
                    print("Family: \(family)")
                    for name in UIFont.fontNames(forFamilyName: family) {
                        print("  \(name)")
                    }
                }
            }
        }
    }

    private func startSampleWorkout() {
        let bench = Exercise(name: "Bench Press", equipment: "barbell", isCustom: false)
        let incline = Exercise(name: "Incline Dumbbell Press", equipment: "dumbbell", isCustom: false)
        let pushdown = Exercise(name: "Tricep Pushdown", equipment: "cables", isCustom: false)

        let templateExercises = [
            TemplateExercise(orderIndex: 0, exercise: bench, targetSets: 3, targetReps: 10),
            TemplateExercise(orderIndex: 1, exercise: incline, targetSets: 3, targetReps: 10),
            TemplateExercise(orderIndex: 2, exercise: pushdown, targetSets: 3, targetReps: 12)
        ]

        let template = WorkoutTemplate(name: "Push Day", exercises: templateExercises)
        completedWorkout = nil
        sessionManager.didCompleteWorkout = false
        sessionManager.startWorkout(from: template)
    }
}
