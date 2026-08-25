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
    @State private var createButtonSpin: Double = 0
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
                            .foregroundStyle(.primary)
                            .padding(.top, 50)

                        ScrollView {
                            if routines.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "list.bullet.clipboard")
                                        .font(.system(.largeTitle))
                                        .foregroundStyle(.primary.opacity(0.8))
                                        .accessibilityHidden(true)

                                    Text("Create your first routine")
                                        .font(.custom("NotoSans-Regular", size: 17, relativeTo: .body))
                                        .foregroundStyle(.primary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 120)
                            } else {
                                LazyVStack(spacing: 12) {
                                    ForEach(routines) { routine in
                                        HStack(spacing: 14) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(routine.name)
                                                    .font(.custom("IstokWeb-Regular", size: 20, relativeTo: .title3))
                                                    .foregroundStyle(.primary)
                                                    .lineLimit(1)

                                                Text("\(routine.exercises.count) exercises")
                                                    .font(.custom("NotoSans-Regular", size: 13, relativeTo: .body))
                                                    .foregroundStyle(.primary.opacity(0.65))
                                            }

                                            Spacer(minLength: 8)

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundStyle(.primary.opacity(0.4))
                                        }
                                        .padding(16)
                                        .background(.ultraThinMaterial)
                                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .stroke(.white.opacity(0.22), lineWidth: 1)
                                        }
                                        .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
                                        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                        .onTapGesture {
                                            routineToEdit = routine
                                        }
                                        .onLongPressGesture {
                                            routineToDelete = routine
                                        }
                                        .accessibilityElement(children: .ignore)
                                        .accessibilityLabel("\(routine.name), \(routine.exercises.count) exercises")
                                        .accessibilityHint("Tap to open. Long press to delete.")
                                        .accessibilityAction(named: "Delete") { routineToDelete = routine }
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
                                withAnimation(.spring(response: 0.45, dampingFraction: 0.6)) {
                                    createButtonSpin += 360
                                }
                                isShowingCreateRoutine = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "plus.circle.fill")
                                        .rotationEffect(.degrees(createButtonSpin))
                                    Text("Create Routine")
                                }
                                .font(.custom("NotoSans-Regular", size: 18, relativeTo: .headline))
                                .fontWeight(.semibold)
                                .foregroundStyle(AppColors.TextWhite)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 14)
                                .background(
                                    LinearGradient(
                                        colors: [AppColors.actionBlue, AppColors.actionBlue.opacity(0.85)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: AppColors.actionBlue.opacity(0.55), radius: 18, x: 0, y: 8)
                            }
                            .buttonStyle(LivelyButtonStyle())
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
            .alert("Delete \"\(routineToDelete?.name ?? "routine")\"?", isPresented: Binding(
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
            // pushes routines to watch + drains any payload that arrived before view appeared
            .onAppear {
                connectivityManager.syncTemplates(routines)
                savePendingWorkoutIfNeeded()
            }
            .onChange(of: routines) { _, updated in
                connectivityManager.syncTemplates(updated)
            }
            // updates upon completing workout
            .onChange(of: connectivityManager.pendingCompletedWorkout) { _, _ in
                savePendingWorkoutIfNeeded()
            }
        }
    }
    private func savePendingWorkoutIfNeeded() {
        guard let payload = connectivityManager.pendingCompletedWorkout else { return }
        let workout = CompletedWorkout(from: payload)
        modelContext.insert(workout)
        try? modelContext.save()
        connectivityManager.pendingCompletedWorkout = nil
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
        let tabName = tab == .routines ? "Routines" : "History"
        return Button {
            withAnimation(.smooth(duration: 0.25)) {
                selectedTab = tab
            }
        } label: {
            Image(systemName: systemImage)
                .font(.system(.body, weight: .semibold))
                .frame(width: 52, height: 44)
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
        .accessibilityLabel(tabName)
        .accessibilityAddTraits(selectedTab == tab ? .isSelected : [])
    }
}



private enum RoutineHomeTab {
    case routines
    case history
}

#Preview {
    RoutinesHome()
        .environmentObject(PhoneConnectivityManager())
        .modelContainer(for: [
            Exercise.self,
            TemplateExercise.self,
            WorkoutTemplate.self
        ], inMemory: true)
}
