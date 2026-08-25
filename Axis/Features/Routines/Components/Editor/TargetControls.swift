

import SwiftUI

struct TargetControl: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // title refers to the trait being modified
            Text(title)
                .font(.custom("NotoSans-Regular", size: 13, relativeTo: .caption))
                .foregroundStyle(.primary.opacity(0.9))

            HStack(spacing: 12) {
                Button {
                    // ensures cant reach 0 or set goals
                    guard value > range.lowerBound else { return }
                    withAnimation(.smooth(duration: 0.18)) {
                        value -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(.caption, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(.white.opacity(0.10))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(.primary.opacity(value > range.lowerBound ? 0.86 : 0.28))
                // lets user know minus is disabled
                .disabled(value <= range.lowerBound)
                .minimumTapTarget()

                Text("\(value)")
                    .font(.custom("NotoSans-Regular", size: 22, relativeTo: .title3))
                    .foregroundStyle(.primary)
                    .frame(minWidth: 28)
                    .contentTransition(.numericText())

                Button {
                    guard value < range.upperBound else { return }
                    withAnimation(.smooth(duration: 0.18)) {
                        value += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(.caption, weight: .bold))
                        .frame(width: 28, height: 28)
                        .background(AppColors.TextBlue.opacity(0.18))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .foregroundStyle(AppColors.TextBlue)
                .disabled(value >= range.upperBound)
                .minimumTapTarget()
            }
            .frame(maxWidth: .infinity)
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(.white.opacity(0.22), lineWidth: 1)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue("\(value)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                guard value < range.upperBound else { return }
                withAnimation(.smooth(duration: 0.18)) { value += 1 }
            case .decrement:
                guard value > range.lowerBound else { return }
                withAnimation(.smooth(duration: 0.18)) { value -= 1 }
            @unknown default:
                break
            }
        }
    }
}
#Preview {
    @Previewable @State var sets = 3
    @Previewable @State var reps = 10

    return ZStack {
        AppColors.background
            .ignoresSafeArea()

        VStack(spacing: 16) {
            Text("Target Controls Preview")
                .font(.custom("NotoSans-Regular", size: 24, relativeTo: .title2))
                .foregroundStyle(.primary)
                .padding(.bottom, 8)

            HStack(spacing: 12) {
                TargetControl(title: "Sets", value: $sets, range: 1...10)
                TargetControl(title: "Reps", value: $reps, range: 1...50)
            }

            Spacer()

            Text("\(sets) sets × \(reps) reps")
                .font(.custom("NotoSans-Regular", size: 18, relativeTo: .body))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .padding(.top, 20)

            Spacer()
        }
        .padding(24)
    }
}

