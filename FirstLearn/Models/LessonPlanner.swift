import Foundation

struct Question: Hashable {
    enum Kind: Hashable {
        /// See the Kannada word, pick the picture.
        case pictureMatch
        /// See the picture and English, pick the Kannada word.
        case meaningMatch
        /// Hear the word, pick the Kannada word.
        case listen
    }

    let kind: Kind
    let answer: Phrase
    let options: [Phrase]
}

enum LessonStep: Hashable {
    case learn(Phrase)
    case question(Question)
}

/// Turns a lesson's phrase list into a playable sequence:
/// learn two phrases, quiz them with pictures, repeat, then a mixed review round.
enum LessonPlanner {
    static func steps<G: RandomNumberGenerator>(
        for lesson: Lesson,
        choices: Int,
        using rng: inout G
    ) -> [LessonStep] {
        let phrases = lesson.phrases
        var steps: [LessonStep] = []

        for start in stride(from: 0, to: phrases.count, by: 2) {
            let chunk = Array(phrases[start..<min(start + 2, phrases.count)])
            steps += chunk.map { .learn($0) }
            for phrase in chunk.shuffled(using: &rng) {
                steps.append(.question(question(.pictureMatch, for: phrase, in: phrases, choices: choices, using: &rng)))
            }
        }

        let reviewKinds: [Question.Kind] = [.meaningMatch, .listen]
        for (offset, phrase) in phrases.shuffled(using: &rng).enumerated() {
            let kind = reviewKinds[offset % reviewKinds.count]
            steps.append(.question(question(kind, for: phrase, in: phrases, choices: choices, using: &rng)))
        }

        return steps
    }

    static func question<G: RandomNumberGenerator>(
        _ kind: Question.Kind,
        for answer: Phrase,
        in pool: [Phrase],
        choices: Int,
        using rng: inout G
    ) -> Question {
        let distractors = pool
            .filter { $0.id != answer.id }
            .shuffled(using: &rng)
            .prefix(max(choices - 1, 0))
        let options = ([answer] + distractors).shuffled(using: &rng)
        return Question(kind: kind, answer: answer, options: options)
    }
}
