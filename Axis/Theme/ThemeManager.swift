
import Foundation
import Combine

// determines dark mode purely from time of day — no user toggle, no location.
// treats 7am–7pm as "day" and everything outside that window as "dark."
@MainActor
final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published private(set) var isDarkMode: Bool

    private let dayStartHour = 7
    private let nightStartHour = 19

    private var timer: Timer?

    private init() {
        isDarkMode = Self.computeIsDarkMode(dayStart: dayStartHour, nightStart: nightStartHour)
        startTimer()
    }

    // re-check the clock; call this whenever the app becomes active
    func refresh() {
        let updated = Self.computeIsDarkMode(dayStart: dayStartHour, nightStart: nightStartHour)
        if updated != isDarkMode {
            isDarkMode = updated
        }
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.refresh()
            }
        }
    }

    private static func computeIsDarkMode(dayStart: Int, nightStart: Int) -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < dayStart || hour >= nightStart
    }
}
