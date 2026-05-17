//
//  RoutinesHome.swift
//  Axis
//
//  Created by Arturo Ayala on 4/21/26.
//

import SwiftUI
import SwiftData

struct RoutinesHome: View {
    @Query(sort: \WorkoutTemplate.createdAt, order: .reverse) private var routines: [WorkoutTemplate]
    @State private var isShowingCreateRoutine = false
    @State private var selectedTab: RoutineHomeTab = .routines
    // list of created routines
    @State private var routineToEdit: WorkoutTemplate?
    @State private var routineToDelete: WorkoutTemplate?
    @Namespace private var tabAnimation
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var connectivityManager: PhoneConnectivityManager

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background
                    .ignoresSafeArea()

                if selectedTab == .routines {
                    VStack(spacing: 8) {
                        Text("Routines")
                            .font(.custom("IstokWeb-Regular", size: 40, relativeTo: .largeTitle))
                            .foregroundStyle(.white)
                            .padding(.top, 50)

                        ScrollView {
                            if routines.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(size: 34))
                                        .foregroundStyle(.white.opacity(0.8))

                                    Text("Create your first routine")
                                        .font(.custom("NotoSans-Regular", size: 17, relativeTo: .body))
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 120)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(routines) { routine in
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(routine.name)
                                                .font(.custom("IstokWeb-Regular", size: 22, relativeTo: .title3))
                                                .foregroundStyle(AppColors.TextBlue)

                                            Text("\(routine.exercises.count) exercises")
                                                .font(.custom("NotoSans-Regular", size: 14, relativeTo: .body))
                                                .foregroundStyle(AppColors.TextBlue.opacity(0.72))
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(16)
                                        .background(AppColors.cardBackground.opacity(0.95))
                                        .clipShape(RoundedRectangle(cornerRadius: 18))
                                        .contentShape(RoundedRectangle(cornerRadius: 18))
                                        .onTapGesture {
                                            routineToEdit = routine
                                        }
                                        .onLongPressGesture {
                                            routineToDelete = routine
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.top, 6)
                            }
                        }
                        .safeAreaPadding(.bottom, 180)
                    }
                } else {
                    HistoryView()
                        .safeAreaPadding(.bottom, 120)
                }

                VStack {
                    Spacer()

                    VStack(spacing: 14) {
                        if selectedTab == .routines {
                            Button {
                                isShowingCreateRoutine = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Create Routine")
                                }
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 2)
                            }
                            .buttonStyle(.borderedProminent)
                            .controlSize(.large)
                            .buttonBorderShape(.capsule)
                            .tint(.blue)
                            .padding(.horizontal, 24)
                        }

                        HStack(spacing: 12) {
                            routineTabButton(
                                tab: .routines,
                                systemImage: "figure.strengthtraining.traditional"
                            )

                            routineTabButton(
                                tab: .history,
                                systemImage: "chart.line.uptrend.xyaxis"
                            )
                        }
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .stroke(.white.opacity(0.28), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.12), radius: 18, x: 0, y: 8)

                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    }
                    .padding(.top, 34)
                    .background(
                        LinearGradient(
                            colors: [
                                AppColors.background.opacity(0),
                                AppColors.background.opacity(0.92),
                                AppColors.background
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea(edges: .bottom)
                    )
                }
            }
            .sheet(isPresented: $isShowingCreateRoutine) {
                CreateRoutine()
            }
            // editor redirect
            .navigationDestination(item: $routineToEdit) { routine in
                RoutineEditor(routine: routine)
            }
            .alert("Delete routine?", isPresented: Binding(
                get: { routineToDelete != nil },
                set: { if !$0 { routineToDelete = nil } }
            )) {
                Button("Cancel", role: .cancel) {
                    routineToDelete = nil
                }

                Button("Delete", role: .destructive) {
                    if let routineToDelete {
                        deleteRoutine(routineToDelete)
                    }
                    routineToDelete = nil
                }
            } message: {
                Text("This removes the routine and its selected exercises from your list.")
            }
            .toolbar(.hidden, for: .navigationBar)
            // pushes routines to watch
            .onAppear {
                connectivityManager.syncTemplates(routines)
            }
            .onChange(of: routines) { _, updated in
                connectivityManager.syncTemplates(updated)
            }
            // updates upon completing workout
            .onChange(of: connectivityManager.pendingCompletedWorkout) { _, payload in
                guard let payload else { return }
                let workout = CompletedWorkout(from: payload)
                modelContext.insert(workout)
                try? modelContext.save()
                connectivityManager.pendingCompletedWorkout = nil
            }
        }
    }
    private func deleteRoutine(_ routine: WorkoutTemplate) {
        modelContext.delete(routine)

        do {
            try modelContext.save()
        } catch {
            print("Failed to delete routine: \(error.localizedDescription)")
        }
    }

    private func routineTabButton(tab: RoutineHomeTab, systemImage: String) -> some View {
        Button {
            withAnimation(.smooth(duration: 0.25)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 18, weight: .semibold))
                .frame(width: 52, height: 42)
            .foregroundStyle(selectedTab == tab ? AppColors.TextBlue : AppColors.TextBlue.opacity(0.62))
            .background {
                if selectedTab == tab {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.58))
                        .matchedGeometryEffect(id: "selectedRoutineHomeTab", in: tabAnimation)
                }
            }
        }
        .buttonStyle(.plain)
    }
}



private enum RoutineHomeTab {
    case routines
    case history
}

#Preview {
    RoutinesHome()
        .modelContainer(for: [
            Exercise.self,
            TemplateExercise.self,
            WorkoutTemplate.self
        ], inMemory: true)
}
