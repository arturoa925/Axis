

import SwiftUI

struct QuoteBlock: View {
    @State private var showWelcome = false
    @State private var showFirstLine = false
    @State private var showSecondLine = false

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Welcome")
                    .font(AppTypography.title)
                    .foregroundStyle(AppColors.TextBlue)
                    .opacity(showWelcome ? 1 : 0)
                    .offset(y: showWelcome ? 0 : 10)

                VStack(spacing: 6) {
                    Text("Small Actions.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.TextBlue)
                        .opacity(showFirstLine ? 1 : 0)
                        .offset(y: showFirstLine ? 0 : 12)

                    Text("Repeated Daily.")
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.TextBlue)
                        .opacity(showSecondLine ? 1 : 0)
                        .offset(y: showSecondLine ? 0 : 12)
                }
            }
            .multilineTextAlignment(.center)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7)) {
                showWelcome = true
            }

            withAnimation(.easeOut(duration: 0.8).delay(0.35)) {
                showFirstLine = true
            }

            withAnimation(.easeOut(duration: 0.8).delay(0.65)) {
                showSecondLine = true
            }
        }
    }
}

#Preview {
    QuoteBlock()
}
