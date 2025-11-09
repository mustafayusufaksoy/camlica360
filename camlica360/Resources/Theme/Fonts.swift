import SwiftUI

/// App typography configuration
struct AppFonts {
    // MARK: - Font Family

    private static let fontFamily = "Roboto"

    // MARK: - Helper to get font name based on weight

    private static func fontName(weight: Font.Weight) -> String {
        switch weight {
        case .bold:
            return "\(fontFamily)-Bold"
        case .semibold:
            return "\(fontFamily)-SemiBold"
        case .medium:
            return "\(fontFamily)-Medium"
        case .regular:
            return "\(fontFamily)-Regular"
        case .light:
            return "\(fontFamily)-Light"
        default:
            return "\(fontFamily)-Regular"
        }
    }

    // MARK: - Display Sizes (Large headings)

    static func display(size: CGFloat = 32, weight: Font.Weight = .bold) -> Font {
        Font.custom(fontName(weight: weight), size: size)
    }

    // MARK: - Extra Large Sizes (xl)

    static func extraLarge(size: CGFloat = 24, weight: Font.Weight = .semibold) -> Font {
        Font.custom(fontName(weight: weight), size: size)
    }

    // MARK: - Large Sizes (lg)

    static func large(size: CGFloat = 20, weight: Font.Weight = .semibold) -> Font {
        Font.custom(fontName(weight: weight), size: size)
    }

    /// Large bold font (20pt)
    static let lgBold = Font.custom(fontName(weight: .bold), size: 20)

    /// Large semibold font (20pt)
    static let lgSemibold = Font.custom(fontName(weight: .semibold), size: 20)

    /// Large regular font (20pt)
    static let lgRegular = Font.custom(fontName(weight: .regular), size: 20)

    // MARK: - Medium Sizes (md)

    /// Medium font (16pt)
    /// Used for: Button text, form titles
    static let mdMedium = Font.custom(fontName(weight: .medium), size: 16)

    /// Regular medium font (16pt)
    static let mdRegular = Font.custom(fontName(weight: .regular), size: 16)

    // MARK: - Small Sizes (sm)

    /// Small medium font (14pt) - for labels
    /// Used for: Input labels, descriptions
    static let smMedium = Font.custom(fontName(weight: .medium), size: 14)

    /// Small regular font (14pt)
    /// Used for: Body text, placeholders
    static let smRegular = Font.custom(fontName(weight: .regular), size: 14)

    // MARK: - Extra Small Sizes (xs)

    /// Extra small regular font (12pt)
    /// Used for: Captions, helper text
    static let xsRegular = Font.custom(fontName(weight: .regular), size: 12)

    /// Extra small medium font (12pt)
    static let xsMedium = Font.custom(fontName(weight: .medium), size: 12)

    // MARK: - Dynamic Sizing

    static func custom(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        Font.custom(fontName(weight: weight), size: size)
    }
}
