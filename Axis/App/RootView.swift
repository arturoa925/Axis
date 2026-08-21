import SwiftUI

struct RootView: View {
    // brings app state
    @EnvironmentObject var appState: AppState
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.scenePhase) private var scenePhase
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
        // forces the subtree to rebuild when day/night flips, so every
        // static AppColors lookup re-evaluates against the new theme
        .id(themeManager.isDarkMode)
        // system-adaptive elements (Materials, etc.) follow the device's actual
        // appearance setting unless told otherwise — pin them to our custom theme
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.6), value: onboardingStep)
        .onAppear {
            startOnboardingSequence()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                themeManager.refresh()
            }
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
