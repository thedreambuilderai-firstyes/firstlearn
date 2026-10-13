import Foundation

/// A single word or phrase the learner picks up.
struct Phrase: Codable, Identifiable, Hashable {
    let id: String
    /// Kannada script, e.g. "ನಮಸ್ಕಾರ".
    let kannada: String
    /// Learner-friendly English spelling, e.g. "Namaskara".
    let romanized: String
    let english: String
    /// Stand-in picture until illustrated art exists.
    let emoji: String
    /// Optional culture or usage tip shown on the learn card.
    let note: String?
}

struct Lesson: Codable, Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let emoji: String
    /// Empty means the lesson is planned but not written yet ("Coming soon").
    let phrases: [Phrase]

    var isAvailable: Bool { !phrases.isEmpty }
}

struct Course: Codable {
    let language: String
    let title: String
    /// "draft" until a native Kannada speaker has reviewed the content.
    let reviewStatus: String
    let lessons: [Lesson]
}

extension Course {
    static func load(from bundle: Bundle = .main, named name: String = "Course") -> Course {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            fatalError("\(name).json is missing from the app bundle")
        }
        do {
            return try JSONDecoder().decode(Course.self, from: Data(contentsOf: url))
        } catch {
            fatalError("Could not read \(name).json: \(error)")
        }
    }
}
