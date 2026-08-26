import Foundation
import Combine

// watch counterpart to Axis/Theme/ThemeManager.swift — same time-based rule
// (7am–7pm is "day," everything outside is "dark"), kept as its own instance
// since the watch app is a separate process from the iPhone app.
@MainActor
final class WatchThemeManager: ObservableObject {
    static let shared = WatchThemeManager()

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
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    private static func computeIsDarkMode(dayStart: Int, nightStart: Int) -> Bool {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < dayStart || hour >= nightStart
    }
}
