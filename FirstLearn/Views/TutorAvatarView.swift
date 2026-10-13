import SwiftUI

/// The tutor's face. Placeholder emoji art; swap for Rive animations later.
/// Changing `reaction` makes the tutor do a little bounce.
struct TutorAvatarView: View {
    let tutor: Tutor
    var size: CGFloat = 72
    var reaction = 0

    var body: some View {
        Text(tutor.emoji)
            .font(.system(size: size * 0.58))
            .frame(width: size, height: size)
            .background(Circle().fill(tutor.color.opacity(0.18)))
            .overlay(Circle().stroke(tutor.color, lineWidth: max(2, size / 28)))
            .phaseAnimator([1.0, 1.18, 1.0], trigger: reaction) { content, scale in
                content.scaleEffect(scale)
            } animation: { _ in
                .spring(duration: 0.25)
            }
            .accessibilityLabel("\(tutor.name), \(tutor.role)")
    }
}

/// The tutor's avatar with a speech bubble next to it.
struct TutorSaysView: View {
    let tutor: Tutor
    let text: String
    var avatarSize: CGFloat = 64
    var reaction = 0

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            TutorAvatarView(tutor: tutor, size: avatarSize, reaction: reaction)
            Text(text)
                .font(.system(.body, design: .rounded))
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemBackground))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(tutor.color.opacity(0.5), lineWidth: 1.5)
                )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ForEach(Tutor.all) { tutor in
            TutorSaysView(tutor: tutor, text: tutor.greeting(for: "Priya"))
        }
    }
    .padding()
}
