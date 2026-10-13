import SwiftUI

struct LessonView: View {
    let lesson: Lesson

    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    @State private var steps: [LessonStep] = []
    @State private var index = 0
    @State private var selectedID: Phrase.ID?
    /// Set once the current question is checked.
    @State private var answeredCorrectly: Bool?
    @State private var tutorLine = ""
    @State private var reaction = 0
    /// Phrases answered wrong at least once, so a retry doesn't earn first-try XP.
    @State private var missedIDs: Set<Phrase.ID> = []
    @State private var firstTryCorrect = 0
    @State private var xpEarned: Int?

    private var tutor: Tutor { appState.tutor }
    private var currentStep: LessonStep? { steps.indices.contains(index) ? steps[index] : nil }

    var body: some View {
        VStack(spacing: 0) {
            if let xpEarned {
                LessonCompleteView(
                    tutor: tutor,
                    lesson: lesson,
                    line: tutorLine,
                    xpEarned: xpEarned,
                    streak: appState.currentStreak()
                ) { dismiss() }
            } else {
                header
                if let currentStep {
                    stepContent(currentStep)
                        .id(index)
                        .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)).combined(with: .opacity))
                }
                Spacer(minLength: 0)
                footer
            }
        }
        .tint(tutor.color)
        .sensoryFeedback(trigger: reaction) { _, _ in
            answeredCorrectly == true ? .success : .error
        }
        .onAppear(perform: start)
    }

    // MARK: - Pieces

    private var header: some View {
        HStack(spacing: 16) {
            Button("Close", systemImage: "xmark") { dismiss() }
                .labelStyle(.iconOnly)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.secondary)
            ProgressView(value: Double(index), total: Double(max(steps.count, 1)))
                .scaleEffect(y: 2)
                .animation(.easeInOut, value: index)
        }
        .padding()
    }

    @ViewBuilder
    private func stepContent(_ step: LessonStep) -> some View {
        switch step {
        case .learn(let phrase):
            LearnCardView(phrase: phrase, tutor: tutor, tutorLine: tutorLine, showScript: appState.showScript)
        case .question(let question):
            QuestionView(
                question: question,
                tutor: tutor,
                mode: appState.mode,
                showScript: appState.showScript,
                selectedID: selectedID,
                isRevealed: answeredCorrectly != nil,
                onSelect: select
            )
        }
    }

    @ViewBuilder
    private var footer: some View {
        switch (currentStep, answeredCorrectly) {
        case (.learn?, _):
            Button("Got it!") { advance() }
                .buttonStyle(ChunkyButtonStyle(color: tutor.color))
                .padding()

        case (.question(let question)?, nil):
            Button("Check") { check(question) }
                .buttonStyle(ChunkyButtonStyle(color: tutor.color))
                .disabled(selectedID == nil)
                .opacity(selectedID == nil ? 0.5 : 1)
                .padding()

        case (.question(let question)?, let isCorrect?):
            FeedbackPanel(
                tutor: tutor,
                isCorrect: isCorrect,
                line: tutorLine,
                answer: question.answer,
                onContinue: advance
            )

        case (nil, _):
            EmptyView()
        }
    }

    // MARK: - Flow

    private func start() {
        guard steps.isEmpty else { return }
        var rng = SystemRandomNumberGenerator()
        steps = LessonPlanner.steps(for: lesson, choices: appState.mode.answerChoices, using: &rng)
        tutorLine = tutor.learnLine()
    }

    private func select(_ phrase: Phrase) {
        guard answeredCorrectly == nil, case .question(let question)? = currentStep else { return }
        selectedID = phrase.id
        // Kids get instant feedback on tap: one less button to understand.
        if appState.mode == .kids { check(question) }
    }

    private func check(_ question: Question) {
        guard let selectedID else { return }
        if selectedID == question.answer.id {
            if !missedIDs.contains(question.answer.id) { firstTryCorrect += 1 }
            tutorLine = tutor.praise()
            answeredCorrectly = true
        } else {
            missedIDs.insert(question.answer.id)
            tutorLine = tutor.correction()
            answeredCorrectly = false
            // Ask again at the end so mistakes get practised before finishing.
            var rng = SystemRandomNumberGenerator()
            let retry = LessonPlanner.question(question.kind, for: question.answer, in: lesson.phrases,
                                               choices: question.options.count, using: &rng)
            steps.append(.question(retry))
        }
        reaction += 1
    }

    private func advance() {
        selectedID = nil
        answeredCorrectly = nil
        if index + 1 >= steps.count {
            finish()
            return
        }
        withAnimation(.easeInOut(duration: 0.3)) { index += 1 }
        if case .learn? = currentStep { tutorLine = tutor.learnLine() }
    }

    private func finish() {
        let earned = 10 + firstTryCorrect
        appState.recordLessonCompleted(lesson, xpEarned: earned)
        tutorLine = tutor.completion()
        withAnimation(.spring) { xpEarned = earned }
    }
}

// MARK: - Learn card

private struct LearnCardView: View {
    let phrase: Phrase
    let tutor: Tutor
    let tutorLine: String
    let showScript: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                TutorSaysView(tutor: tutor, text: tutorLine, avatarSize: 52)

                VStack(spacing: 12) {
                    Text(phrase.emoji).font(.system(size: 96))
                    PhraseText(phrase: phrase, showScript: showScript, size: .large)
                    Text(phrase.english)
                        .font(.system(.title3, design: .rounded))
                        .foregroundStyle(.secondary)
                    ListenButtons(phrase: phrase, color: tutor.color)
                }
                .padding(24)
                .frame(maxWidth: .infinity)
                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))

                if let note = phrase.note {
                    Label(note, systemImage: "lightbulb.fill")
                        .font(.callout)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(tutor.color.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding(.horizontal)
        }
        .onAppear { Speaker.shared.say(phrase) }
    }
}

// MARK: - Question

private struct QuestionView: View {
    let question: Question
    let tutor: Tutor
    let mode: LearnerMode
    let showScript: Bool
    let selectedID: Phrase.ID?
    let isRevealed: Bool
    let onSelect: (Phrase) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                prompt
                options
            }
            .padding(.horizontal)
        }
        .onAppear {
            if question.kind == .listen { Speaker.shared.say(question.answer) }
        }
    }

    @ViewBuilder
    private var prompt: some View {
        switch question.kind {
        case .pictureMatch:
            VStack(spacing: 12) {
                Text("What does this mean?").font(.system(.headline, design: .rounded))
                PhraseText(phrase: question.answer, showScript: showScript, size: .large)
                ListenButtons(phrase: question.answer, color: tutor.color)
            }
        case .meaningMatch:
            VStack(spacing: 8) {
                Text("How do you say…").font(.system(.headline, design: .rounded))
                Text(question.answer.emoji).font(.system(size: 80))
                Text(question.answer.english).font(.system(.title2, design: .rounded).weight(.bold))
            }
        case .listen:
            VStack(spacing: 16) {
                Text("Tap what you hear").font(.system(.headline, design: .rounded))
                Button {
                    Speaker.shared.say(question.answer)
                } label: {
                    Image(systemName: "speaker.wave.3.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        .frame(width: 110, height: 110)
                        .background(tutor.color, in: Circle())
                }
                .accessibilityLabel("Play the word again")
            }
        }
    }

    @ViewBuilder
    private var options: some View {
        if question.kind == .pictureMatch {
            let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(question.options) { option in
                    optionButton(option) {
                        VStack(spacing: 6) {
                            Text(option.emoji).font(.system(size: mode == .kids ? 64 : 48))
                            Text(option.english).font(.system(.subheadline, design: .rounded))
                        }
                        .frame(maxWidth: .infinity, minHeight: mode == .kids ? 140 : 110)
                    }
                }
            }
        } else {
            VStack(spacing: 12) {
                ForEach(question.options) { option in
                    optionButton(option) {
                        PhraseText(phrase: option, showScript: showScript, size: .medium)
                            .frame(maxWidth: .infinity, minHeight: mode == .kids ? 72 : 56)
                    }
                }
            }
        }
    }

    private func optionButton<Label: View>(_ option: Phrase, @ViewBuilder label: () -> Label) -> some View {
        let style = OptionStyle(
            isSelected: option.id == selectedID,
            isAnswer: option.id == question.answer.id,
            isRevealed: isRevealed,
            color: tutor.color
        )
        return Button { onSelect(option) } label: {
            label()
                .padding(8)
                .foregroundStyle(.primary)
                .background(style.fill, in: RoundedRectangle(cornerRadius: 16))
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(style.stroke, lineWidth: 3))
        }
        .buttonStyle(.plain)
        .disabled(isRevealed)
    }
}

private struct OptionStyle {
    let isSelected: Bool
    let isAnswer: Bool
    let isRevealed: Bool
    let color: Color

    var stroke: Color {
        if isRevealed && isAnswer { return .correct }
        if isRevealed && isSelected { return .wrong }
        return isSelected ? color : Color(.systemGray4)
    }

    var fill: Color {
        if isRevealed && isAnswer { return Color.correct.opacity(0.15) }
        if isRevealed && isSelected { return Color.wrong.opacity(0.15) }
        return isSelected ? color.opacity(0.12) : Color(.secondarySystemBackground)
    }
}

// MARK: - Shared bits

/// A phrase as the learner sees it: English spelling first, Kannada script underneath if enabled.
private struct PhraseText: View {
    enum Size { case medium, large }

    let phrase: Phrase
    let showScript: Bool
    let size: Size

    var body: some View {
        VStack(spacing: 4) {
            Text(phrase.romanized)
                .font(.system(size == .large ? .largeTitle : .title3, design: .rounded).weight(.bold))
            if showScript {
                Text(phrase.kannada)
                    .font(size == .large ? .title2 : .body)
                    .foregroundStyle(.secondary)
            }
        }
        .multilineTextAlignment(.center)
    }
}

private struct ListenButtons: View {
    let phrase: Phrase
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Button("Listen", systemImage: "speaker.wave.2.fill") { Speaker.shared.say(phrase) }
            Button("Slow", systemImage: "tortoise.fill") { Speaker.shared.say(phrase, slow: true) }
        }
        .buttonStyle(.bordered)
        .tint(color)
    }
}

private struct FeedbackPanel: View {
    let tutor: Tutor
    let isCorrect: Bool
    let line: String
    let answer: Phrase
    let onContinue: () -> Void

    @State private var bounce = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                TutorAvatarView(tutor: tutor, size: 52, reaction: bounce)
                VStack(alignment: .leading, spacing: 4) {
                    Text(line).font(.system(.headline, design: .rounded))
                    if !isCorrect {
                        Text("Answer: \(answer.romanized) = \(answer.english)")
                            .font(.subheadline)
                    }
                }
            }
            Button("Continue", action: onContinue)
                .buttonStyle(ChunkyButtonStyle(color: isCorrect ? .correct : .wrong))
        }
        .padding()
        .background((isCorrect ? Color.correct : Color.wrong).opacity(0.15))
        .transition(.move(edge: .bottom))
        .onAppear { bounce += 1 }
    }
}

// MARK: - Complete

private struct LessonCompleteView: View {
    let tutor: Tutor
    let lesson: Lesson
    let line: String
    let xpEarned: Int
    let streak: Int
    let onDone: () -> Void

    @State private var celebrate = 0

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("🎉").font(.system(size: 72))
            TutorAvatarView(tutor: tutor, size: 120, reaction: celebrate)
            Text(line)
                .font(.system(.title2, design: .rounded).weight(.bold))
                .multilineTextAlignment(.center)
            Text("You finished \"\(lesson.title)\"")
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                summary("⭐️", "+\(xpEarned) XP")
                summary("🔥", "\(streak) day streak")
                summary("📚", "\(lesson.phrases.count) words")
            }
            Spacer()
            Button("Continue", action: onDone)
                .buttonStyle(ChunkyButtonStyle(color: tutor.color))
        }
        .padding(24)
        .onAppear { celebrate += 1 }
        .sensoryFeedback(.success, trigger: celebrate)
    }

    private func summary(_ icon: String, _ text: String) -> some View {
        VStack(spacing: 4) {
            Text(icon).font(.title)
            Text(text).font(.system(.footnote, design: .rounded).weight(.semibold))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    let state = AppState(defaults: UserDefaults(suiteName: "preview")!)
    state.completeOnboarding(name: "Priya", mode: .kids, tutorID: "pandu")
    return LessonView(lesson: state.course.lessons[0]).environment(state)
}
