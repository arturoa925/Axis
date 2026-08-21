import SwiftUI
import SwiftData

struct HistoryView: View {
    // sorted by most recently completed
    @Query(sort: \CompletedWorkout.completedAt, order: .reverse)
    private var workouts: [CompletedWorkout]

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text("History")
                    .font(.custom("IstokWeb-Regular", size: 40, relativeTo: .largeTitle))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 20)
                    .padding(.top, 50)

                if workouts.isEmpty {
                    Spacer()
                    // fallback
                    emptyState
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            ForEach(workouts, id: \.id) { workout in
                                WorkoutHistoryCard(workout: workout)
                                    .scrollTransition { content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                            .scaleEffect(phase.isIdentity ? 1 : 0.92)
                                            .offset(y: phase.isIdentity ? 0 : 24)
                                    }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .frame(maxHeight: .infinity, alignment: .top)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Text("No workouts yet")
                .font(.custom("IstokWeb-Regular", size: 22, relativeTo: .title3))
                .foregroundStyle(AppColors.TextBlue)

            Text("Completed workouts will appear here.")
                .font(.custom("NotoSans-Regular", size: 15, relativeTo: .body))
                .foregroundStyle(AppColors.TextBlue)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(for: CompletedWorkout.self, inMemory: true)
}
