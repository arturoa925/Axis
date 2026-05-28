import SwiftUI

struct SelectingWorkout: View {
    let template: WatchTemplatePayload
    let onStart: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            WatchColors.background.ignoresSafeArea()

            VStack(spacing: 0) {
                Text(template.name)
                    .font(.custom("IstokWeb-Regular", size: 22, relativeTo: .headline))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .padding(.horizontal, 14)
                    .padding(.top, 8)
                    .padding(.bottom,10)

                Spacer()

                Button(action: onStart) {
                    Text("Start")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 100, height: 100)
                        .background(Circle().fill(Color(hex: "#315BFF")))
                }
                .buttonStyle(.plain)

                Spacer()

                HStack {
                    Button(action: onCancel) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 36)
                            .glassEffect(in: Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Cancel")
                    Spacer()
                }
                .padding(.leading, 14)
                .padding(.bottom, 8)
            }
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
