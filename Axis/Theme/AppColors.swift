
import SwiftUI

struct AppColors {

    private static var isDarkMode: Bool { ThemeManager.shared.isDarkMode }

    //Backgrounds
    static var background: Color {
        isDarkMode ? Color(hex: "#17181C") : Color(hex: "#D8CFC4")
    }
    // light blue (dark: desaturated navy)
    static var cardBackground: Color {
        isDarkMode ? Color(hex: "#262B3D") : Color(hex: "#D0DAFF")
    }

    // Text
    // navy (dark: lightened for contrast against a dark background)
    static var TextBlue: Color {
        isDarkMode ? Color(hex: "#93ACEE") : Color(hex: "#5B7AC5")
    }
    // brown (dark: bright warm cream, since dark brown vanishes on a dark background)
    static var TextBrown: Color {
        isDarkMode ? Color(hex: "#F7E9D0") : Color(hex: "#774B1C")
    }
    static let TextWhite = Color(hex: "#FFFFFF")
    static let TextBlack = Color(hex: "#000000")

    // Actions
    // vivid, saturated blue for primary CTAs — meant to pop, not blend in. Stays the same in both modes.
    static let actionBlue = Color(hex: "#3D6BFF")

    //Status
    static let success = Color.blue
    static let warning = Color.orange
    static let error = Color.red
}

//  Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
