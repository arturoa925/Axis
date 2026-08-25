// shell to hold the rolling quotes

import SwiftUI

struct OnboardingGreeting: View {
    var onContinue: (() -> Void)? = nil

    var body: some View {
        QuoteBlock(onContinue: onContinue)
    }
}

#Preview {
    OnboardingGreeting()
}
