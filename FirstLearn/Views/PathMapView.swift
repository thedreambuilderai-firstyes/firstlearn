import SwiftUI

/// The winding path of lessons. Done lessons are ticked, the next one glows, later ones are locked.
struct PathMapView: View {
    @Environment(AppState.self) private var appState
    let tutor: Tutor
    let onSelect: (Lesson) -> Void

    var body: some View {
        VStack(spacing: 28) {
            ForEach(Array(appState.course.lessons.enumerated()), id: \.element.id) { index, lesson in
                let state = nodeState(for: lesson)
                LessonNode(lesson: lesson, state: state, color: tutor.color)
                    .offset(x: sin(Double(index) * .pi / 2.5) * 80)
                    .onTapGesture { if state.isPlayable { onSelect(lesson) } }
                    .accessibilityAddTraits(state.isPlayable ? .isButton : [])
            }
        }
        .padding(.vertical)
    }

    private func nodeState(for lesson: Lesson) -> LessonNode.NodeState {
        if !lesson.isAvailable { return .comingSoon }
        if appState.isCompleted(lesson) { return .completed }
        return appState.isUnlocked(lesson) ? .next : .locked
    }
}

private struct LessonNode: View {
    enum NodeState {
        case completed, next, locked, comingSoon

        var isPlayable: Bool { self == .completed || self == .next }
    }

    let lesson: Lesson
    let state: NodeState
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                Text(lesson.emoji)
                    .font(.system(size: 36))
                    .frame(width: 80, height: 80)
                    .background(Circle().fill(fill))
                    .overlay(Circle().stroke(stroke, style: StrokeStyle(lineWidth: 4, dash: state == .comingSoon ? [6, 6] : [])))
                    .saturation(state.isPlayable ? 1 : 0)
                    .opacity(state.isPlayable ? 1 : 0.6)
                    .phaseAnimator([1.0, 1.08]) { content, scale in
                        content.scaleEffect(state == .next ? scale : 1)
                    } animation: { _ in
                        .easeInOut(duration: 0.9)
                    }

                badge
            }

            Text(lesson.title)
                .font(.system(.subheadline, design: .rounded).weight(.semibold))
            Text(state == .comingSoon ? "Coming soon" : lesson.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 160)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Lesson \(lesson.id), \(lesson.title), \(accessibilityState)")
    }

    private var fill: Color {
        switch state {
        case .completed: color.opacity(0.35)
        case .next: color.opacity(0.2)
        case .locked, .comingSoon: Color(.tertiarySystemFill)
        }
    }

    private var stroke: Color {
        state.isPlayable ? color : Color(.systemGray3)
    }

    @ViewBuilder
    private var badge: some View {
        switch state {
        case .completed:
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.white, Color.correct)
        case .locked:
            Image(systemName: "lock.circle.fill")
                .font(.title2)
                .foregroundStyle(.white, Color(.systemGray))
        case .next, .comingSoon:
            EmptyView()
        }
    }

    private var accessibilityState: String {
        switch state {
        case .completed: "completed"
        case .next: "ready to start"
        case .locked: "locked"
        case .comingSoon: "coming soon"
        }
    }
}
