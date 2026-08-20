

import SwiftUI

struct QuoteBlock: View {
    @State private var animate = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

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
            .multilineTextAlignment(.center)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Welcome. Small Actions. Repeated Daily.")
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    QuoteBlock()
}
