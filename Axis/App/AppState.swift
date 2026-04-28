

import Foundation
import SwiftUI
import Combine

final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool = false
}
