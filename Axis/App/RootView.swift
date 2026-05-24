import SwiftUI

struct RootView: View {
    // brings app state
    @EnvironmentObject var appState: AppState
    @State private var onboardingStep: OnboardingStep = .launch

    // 4 step sequence
    // after opening once, guide step is skipped
    var body: some View {
        ZStack {
            AppColors.background
                .ignoresSafeArea()

            
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

        // skip determining step
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.2) {
            withAnimation(.easeInOut(duration: 0.75)) {
                onboardingStep = appState.hasCompletedOnboarding ? .main : .guide
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.2) {
            appState.hasCompletedOnboarding = true
            withAnimation(.easeInOut(duration: 0.75)) {
                onboardingStep = .main
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
