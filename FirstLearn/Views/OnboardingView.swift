import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    private enum Step: Int, CaseIterable {
        case welcome, name, mode, tutor
    }

    @State private var step = Step.welcome
    @State private var name = ""
    @State private var mode = LearnerMode.adult
    @State private var tutorID = Tutor.all[0].id
    @FocusState private var nameFocused: Bool

    private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

    var body: some View {
        VStack(spacing: 20) {
            if step != .welcome {
                HStack {
                    Button("Back", systemImage: "chevron.left") { go(to: step.rawValue - 1) }
                        .labelStyle(.iconOnly)
                        .font(.title3.weight(.semibold))
                    ProgressView(value: Double(step.rawValue), total: Double(Step.allCases.count - 1))
                        .tint(Tutor.find(tutorID).color)
                }
            }

            ScrollView {
                content
                    .frame(maxWidth: .infinity)
                    .padding(.top, step == .welcome ? 60 : 12)
            }
            .scrollBounceBehavior(.basedOnSize)

            Button(step == .tutor ? "Start learning" : "Next") { next() }
                .buttonStyle(ChunkyButtonStyle(color: step == .tutor ? Tutor.find(tutorID).color : .accentColor))
                .disabled(step == .name && trimmedName.isEmpty)
                .opacity(step == .name && trimmedName.isEmpty ? 0.5 : 1)
        }
        .padding(24)
    }

    @ViewBuilder
    private var content: some View {
        switch step {
        case .welcome:
            VStack(spacing: 20) {
                Text("ಕನ್ನಡ")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.accentColor)
                Text("Learn Kannada with someone who cares")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .multilineTextAlignment(.center)
                Text("Pick a teacher, learn 5 minutes a day, and have fun doing it.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                HStack(spacing: -10) {
                    ForEach(Tutor.all) { TutorAvatarView(tutor: $0, size: 60) }
                }
                .padding(.top, 12)
            }

        case .name:
            VStack(alignment: .leading, spacing: 16) {
                Text("What should your teacher call you?")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                TextField("Your name", text: $name)
                    .font(.title3)
                    .textContentType(.givenName)
                    .submitLabel(.next)
                    .focused($nameFocused)
                    .onSubmit { if !trimmedName.isEmpty { next() } }
                    .padding()
                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
            }
            .onAppear { nameFocused = true }

        case .mode:
            VStack(alignment: .leading, spacing: 16) {
                Text("Who is learning?")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                ForEach(LearnerMode.allCases) { option in
                    ModeCard(mode: option, isSelected: option == mode)
                        .onTapGesture { withAnimation(.spring(duration: 0.3)) { mode = option } }
                        .accessibilityAddTraits(.isButton)
                }
            }

        case .tutor:
            VStack(alignment: .leading, spacing: 16) {
                Text("Choose your teacher")
                    .font(.system(.title2, design: .rounded).weight(.bold))
                Text("You can switch any time in Settings.")
                    .foregroundStyle(.secondary)
                TutorPickerView(selection: $tutorID, learnerName: trimmedName)
            }
        }
    }

    private func next() {
        if step == .tutor {
            appState.completeOnboarding(name: trimmedName, mode: mode, tutorID: tutorID)
        } else {
            go(to: step.rawValue + 1)
        }
    }

    private func go(to rawValue: Int) {
        guard let target = Step(rawValue: rawValue) else { return }
        nameFocused = false
        withAnimation(.easeInOut) { step = target }
    }
}

private struct ModeCard: View {
    let mode: LearnerMode
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 16) {
            Text(mode.emoji).font(.system(size: 44))
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.title).font(.system(.title3, design: .rounded).weight(.semibold))
                Text(mode.subtitle).font(.subheadline).foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isSelected ? Color.accentColor : .secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? Color.accentColor : .clear, lineWidth: 3)
        )
    }
}

#Preview {
    OnboardingView()
        .environment(AppState(defaults: UserDefaults(suiteName: "preview")!))
}
