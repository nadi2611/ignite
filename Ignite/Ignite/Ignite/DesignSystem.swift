import SwiftUI

struct IgniteTheme {
    // Colors
    static let primary = Color(hex: "#FF4D4D")
    static let secondary = Color(hex: "#FF8C42")
    static let background = Color(hex: "#F9F9F9")
    static let cardBackground = Color.white
    static let textPrimary = Color(hex: "#1A1A2E")
    static let textSecondary = Color(hex: "#6B7280")

    // Gradient
    static let mainGradient = LinearGradient(
        colors: [Color(hex: "#FF4D4D"), Color(hex: "#FF8C42")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Corner radius
    static let cardRadius: CGFloat = 24
    static let buttonRadius: CGFloat = 30
    static let inputRadius: CGFloat = 14

    // Shadow
    static let cardShadow = Shadow(color: .black.opacity(0.1), radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View modifiers

struct PrimaryButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(IgniteTheme.mainGradient)
            .cornerRadius(IgniteTheme.buttonRadius)
    }
}

struct OutlineButtonStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(IgniteTheme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.white)
            .cornerRadius(IgniteTheme.buttonRadius)
            .overlay(
                RoundedRectangle(cornerRadius: IgniteTheme.buttonRadius)
                    .stroke(IgniteTheme.primary, lineWidth: 1.5)
            )
    }
}

struct InputFieldStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(IgniteTheme.inputRadius)
            .font(.body)
    }
}

extension View {
    func primaryButton() -> some View { modifier(PrimaryButtonStyle()) }
    func outlineButton() -> some View { modifier(OutlineButtonStyle()) }
    func inputField() -> some View { modifier(InputFieldStyle()) }
}

// MARK: - Color hex init

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: UInt64
        switch hex.count {
        case 6:
            (r, g, b) = ((int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (r, g, b) = (1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }
}
