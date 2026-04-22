
import SwiftUI

struct AppColors {

    // MARK: - Backgrounds
    static let background = Color(hex: "#D8CFC4")
    static let cardBackground = Color(hex: "#D0DAFF")

    // MARK: - Text
    static let TextBlue = Color(hex: "#5B7AC5")
    static let TextBrown = Color(hex: "#774B1C")
    static let TextWhite = Color(hex: "#F0F0F0")
    static let TextBlack = Color(hex: "#000000")

    // MARK: - Status
    static let success = Color.blue
    static let warning = Color.orange
    static let error = Color.red
}

// MARK: - Hex Support
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
