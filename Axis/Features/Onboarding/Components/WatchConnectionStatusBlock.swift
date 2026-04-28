

import SwiftUI

struct WatchConnectionStatusBlock: View {
    enum ConnectionState {
        case checking
        case connected
        case failed
    }

    @State private var connectionState: ConnectionState = .checking
   

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text("Build your workouts here")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.TextBrown)
                    .multilineTextAlignment(.center)

                Text("Begin on your Apple Watch")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.TextBrown)
                    .padding(.top, 20)
                    .multilineTextAlignment(.center)

                VStack(spacing: 12) {
                    statusLine
                        .font(AppTypography.body)
                        .foregroundStyle(AppColors.TextBrown)
                        .multilineTextAlignment(.center)

                    statusDetail
                        .padding(.top, 24)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal, 28)
        }
        .onAppear {
         

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
                connectionState = .connected
                // Change to `.failed` to preview failure state.
            }
        }
    }

    @ViewBuilder
    private var statusDetail: some View {
        switch connectionState {
        case .checking:
            ProgressView()
                .tint(AppColors.TextBlue)

        case .connected:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.blue)

        case .failed:
            VStack(spacing: 10) {
                Text("Apple Watch not connected")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.TextBlue)

                Text("Will try again in the background")
                    .font(AppTypography.body)
                    .foregroundStyle(AppColors.TextBlue)
            }
            .multilineTextAlignment(.center)
        }
    }

    private var statusLine: Text {
        switch connectionState {
        case .checking:
            return Text("Checking for an Apple Watch connection")
        case .connected:
            return Text("Apple Watch connected")
        case .failed:
            return Text("Checking for an Apple Watch connection")
        }
    }
}

#Preview {
    WatchConnectionStatusBlock()
}
