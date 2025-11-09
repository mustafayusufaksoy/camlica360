import SwiftUI

/// App color theme configuration
struct AppColors {
    // MARK: - Primary Colors

    /// Primary color - Deep purple/indigo (#201D66)
    static let primary = Color(hex: "201D66")

    /// Primary dark variant (950)
    static let primary950 = Color(hex: "201D66")

    /// Primary 600 - Chart color (#4F46E5)
    static let primary600 = Color(hex: "4F46E5")

    // MARK: - Neutral Colors

    /// White color
    static let white = Color.white

    /// Black color
    static let black = Color.black

    /// Neutral 950 - Very dark (text)
    static let neutral950 = Color(hex: "0A0A0A")

    /// Neutral 700 - Dark gray
    static let neutral700 = Color(hex: "404040")

    /// Neutral 600 - Medium gray (labels)
    static let neutral600 = Color(hex: "525252")

    /// Neutral 500 - Light gray (placeholders)
    static let neutral500 = Color(hex: "737373")

    /// Neutral 400 - Medium light gray
    static let neutral400 = Color(hex: "A3A3A3")

    /// Neutral 300 - Light gray
    static let neutral300 = Color(hex: "D4D4D4")

    /// Neutral 200 - Very light gray (borders)
    static let neutral200 = Color(hex: "E5E5E5")

    /// Neutral 100 - Extra light gray
    static let neutral100 = Color(hex: "F5F5F5")

    /// Neutral 50 - Very light background (#FAFAFA)
    static let neutral50 = Color(hex: "FAFAFA")

    /// Background color for pages
    static let background = Color(hex: "FAFAFA")

    /// Light gray (borders) - Legacy
    static let lightGray = Color(hex: "E5E5E5")

    /// Medium gray - Legacy, use neutral600 instead
    static let mediumGray = Color(hex: "525252")

    /// Dark gray - Legacy, use neutral700 instead
    static let darkGray = Color(hex: "404040")

    // MARK: - Semantic Colors

    /// Success/positive action
    static let success = Color(UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0))

    /// Error/negative action
    static let error = Color(UIColor(red: 1.0, green: 0.2, blue: 0.2, alpha: 1.0))

    /// Warning color
    static let warning = Color(UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0))

    /// Info color
    static let info = Color(UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0))
}

// MARK: - Color Extension for Hex

extension Color {
    /// Create a color from hex string
    /// - Parameter hex: Hex color code (with or without #)
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let rgb = Int(hex, radix: 16) ?? 0
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
