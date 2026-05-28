
import SwiftUI

struct WatchConnectionStatusBlock: View {

    enum ConnectionState {
        case checking
        case connected
        case failed
    }

    @EnvironmentObject private var connectivityManager: PhoneConnectivityManager

    // must establish watch connection type first
    private var connectionState: ConnectionState {
        guard connectivityManager.isActivated else { return .checking }
        return connectivityManager.isWatchReachable ? .connected : .failed
    }

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
    }

    @ViewBuilder
    private var statusDetail: some View {
        switch connectionState {
        case .checking:
            ProgressView()
                .tint(AppColors.TextBlue)
                .accessibilityLabel("Checking for Apple Watch connection")

        case .connected:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.blue)
                .accessibilityLabel("Apple Watch connected")

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
        .environmentObject(PhoneConnectivityManager())
}
