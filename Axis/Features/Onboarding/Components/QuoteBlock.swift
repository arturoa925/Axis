

import SwiftUI

struct QuoteBlock: View {
    var onContinue: (() -> Void)? = nil

    @State private var animate = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 18) {
                    Text("Welcome")
                        .font(AppTypography.title)
                        .foregroundStyle(AppColors.TextBlue)
                        .opacity(animate ? 1 : 0)
                        .scaleEffect(animate ? 1 : 0.92)
                        .offset(y: animate ? 0 : 10)
                        .animation(.spring(response: 0.5, dampingFraction: 0.78), value: animate)

                    VStack(spacing: 6) {
                        Text("Small Actions.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.TextBlue)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 12)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.15), value: animate)

                        Text("Repeated Daily.")
                            .font(AppTypography.body)
                            .foregroundStyle(AppColors.TextBlue)
                            .opacity(animate ? 1 : 0)
                            .offset(y: animate ? 0 : 12)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3), value: animate)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Welcome. Small Actions. Repeated Daily.")

                // with VoiceOver running, RootView skips the auto-advance timer and
                // hands control to this button instead, so speech never gets cut off
                if let onContinue {
                    Button(action: onContinue) {
                        Text("Continue")
                            .font(AppTypography.body)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.actionBlue)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(LivelyButtonStyle())
                    .padding(.horizontal, 40)
                    .padding(.top, 30)
                }
            }
            .multilineTextAlignment(.center)
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    QuoteBlock()
}

#Preview("With Continue button") {
    QuoteBlock(onContinue: {})
}
