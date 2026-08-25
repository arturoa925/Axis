// shell for holding the watch connection status text

import SwiftUI

struct OnboardingGuide: View {
    var onContinue: (() -> Void)? = nil

    var body: some View {
        WatchConnectionStatusBlock(onContinue: onContinue)
    }
}

#Preview {
    OnboardingGuide()
}
