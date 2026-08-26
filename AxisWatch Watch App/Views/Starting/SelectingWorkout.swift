import SwiftUI

struct SelectingWorkout: View {
    let template: WatchTemplatePayload
    let onStart: () -> Void
    let onCancel: () -> Void

    @State private var animateTitle = false
    @State private var animateStart = false
    @State private var animateCancel = false

    var body: some View {
        ZStack {
            WatchColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer(minLength: 12)

                VStack(spacing: 3) {
                    Text(template.name)
                        .font(.custom("IstokWeb-Regular", size: 22, relativeTo: .headline))
                        .foregroundStyle(WatchColors.textBlack)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)

                    Text("\(template.exercises.count) exercises")
                        .font(.system(.caption2))
                        .foregroundStyle(WatchColors.textBlack.opacity(0.65))
                }
                .padding(.horizontal, 14)
                .opacity(animateTitle ? 1 : 0)
                .scaleEffect(animateTitle ? 1 : 0.92)
                .offset(y: animateTitle ? 0 : 8)
                .animation(.spring(response: 0.5, dampingFraction: 0.78), value: animateTitle)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)

                Spacer(minLength: 10)

                Button(action: onStart) {
                    Text("Start")
                        .font(.system(.title3, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 92, height: 92)
                        .background(
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "#5B7CFF"), Color(hex: "#2A4EE0")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.35), lineWidth: 1.5)
                        )
                        .shadow(color: Color(hex: "#315BFF").opacity(0.55), radius: 14, x: 0, y: 6)
                }
                .buttonStyle(WatchLivelyButtonStyle())
                .opacity(animateStart ? 1 : 0)
                .scaleEffect(animateStart ? 1 : 0.5)
                .animation(.spring(response: 0.55, dampingFraction: 0.62), value: animateStart)
                .accessibilityLabel("Start \(template.name)")
                .accessibilityHint("Begins your workout")

                Spacer(minLength: 10)

                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(.caption, weight: .semibold))
                            .foregroundStyle(WatchColors.textBlack)
                            .frame(width: 36, height: 36)
                            .glassEffect(in: Circle())
                            .environment(\.colorScheme, WatchThemeManager.shared.isDarkMode ? .dark : .light)
                    }
                    .buttonStyle(WatchLivelyButtonStyle())
                    .opacity(animateCancel ? 1 : 0)
                    .animation(.easeOut(duration: 0.5), value: animateCancel)
                    .accessibilityLabel("Cancel")
                    Spacer()
                }
                .padding(.leading, 20)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            animateTitle = true
            withAnimation { animateStart = true }
            withAnimation(.easeOut.delay(0.3)) { animateCancel = true }
        }
    }
}

#Preview {
    SelectingWorkout(
        template: WatchTemplatePayload(
            id: "1",
            name: "Push Day",
            exercises: [
                WatchExercisePayload(name: "Bench Press", targetSets: 4, targetReps: 8, orderIndex: 0),
                WatchExercisePayload(name: "Shoulder Press", targetSets: 3, targetReps: 10, orderIndex: 1),
            ]
        ),
        onStart: {},
        onCancel: {}
    )
}
