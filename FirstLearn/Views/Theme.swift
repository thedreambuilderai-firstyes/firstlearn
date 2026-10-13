import SwiftUI

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }

    static let correct = Color(hex: 0x3FA34D)
    static let wrong = Color(hex: 0xE0663E)
}

extension Tutor {
    var color: Color { Color(hex: colorHex) }
}

/// Large, rounded, full-width button used for the main action on every screen.
struct ChunkyButtonStyle: ButtonStyle {
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color, in: RoundedRectangle(cornerRadius: 16))
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(duration: 0.2), value: configuration.isPressed)
    }
}
