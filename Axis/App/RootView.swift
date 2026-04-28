import SwiftUI

struct RootView: View {
    @EnvironmentObject var appState: AppState
    @State private var onboardingStep: OnboardingStep = .launch

    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            Group {
                switch onboardingStep {
                case .launch:
                    LaunchView()
                        .transition(.opacity)

                case .greeting:
                    OnboardingGreeting()
                        .transition(.opacity)

                case .guide:
                    OnboardingGuide()
                        .transition(.opacity)

                case .main:
                    MainTabView()
                        .transition(.opacity)
                }
            }
        }
        .animation(.easeInOut(duration: 0.6), value: onboardingStep)
        .onAppear {
            startOnboardingSequence()
        }
    }

    private func startOnboardingSequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            withAnimation(.easeInOut(duration: 0.75)) {
                onboardingStep = .greeting
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 6.2) {
            withAnimation(.easeInOut(duration: 0.75)) {
                onboardingStep = appState.hasCompletedOnboarding ? .main : .guide
            }
        }
    }
}

private enum OnboardingStep {
    case launch
    case greeting
    case guide
    case main
}

#Preview {
    RootView()
        .environmentObject(AppState())
}
