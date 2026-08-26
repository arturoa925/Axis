import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255, opacity: Double(a) / 255)
    }
}

enum WatchColors {
    private static var isDarkMode: Bool { WatchThemeManager.shared.isDarkMode }

    static var background: Color {
        isDarkMode ? Color(hex: "#17181C") : Color(hex: "#D8CFC4")
    }
    static var cardBackground: Color {
        isDarkMode ? Color(hex: "#262B3D") : Color(hex: "#D0DAFF")
    }
    static var textBrown: Color {
        isDarkMode ? Color(hex: "#F7E9D0") : Color(hex: "#774B1C")
    }
    static var textBlue: Color {
        isDarkMode ? Color(hex: "#93ACEE") : Color(hex: "#5B7AC5")
    }
    // primary text against background/cards — near-black by day, near-white by night
    static var textBlack: Color {
        isDarkMode ? Color.white : Color.black
    }
    static let textWhite = Color.white
}

struct WatchLivelyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .brightness(configuration.isPressed ? 0.2 : 0)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.55), value: configuration.isPressed)
    }
}
