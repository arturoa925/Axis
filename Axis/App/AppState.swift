

import Foundation
import SwiftUI
import Combine

final class AppState: ObservableObject {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
}
