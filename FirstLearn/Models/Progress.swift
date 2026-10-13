import Foundation

struct LearnerProfile: Codable, Equatable {
    var name: String
    var mode: LearnerMode
    var tutorID: String
    /// Kannada script is optional; learners start with the English spelling.
    var showScript: Bool

    init(name: String, mode: LearnerMode, tutorID: String, showScript: Bool? = nil) {
        self.name = name
        self.mode = mode
        self.tutorID = tutorID
        self.showScript = showScript ?? (mode == .adult)
    }
}

struct ProgressState: Codable, Equatable {
    var completedLessonIDs: Set<Int> = []
    var learnedPhraseIDs: Set<String> = []
    var xp = 0
    var streak = 0
    var lastActiveDay: Date?

    mutating func recordLesson(
        id: Int,
        phraseIDs: [String],
        xpEarned: Int,
        on date: Date,
        calendar: Calendar = .current
    ) {
        completedLessonIDs.insert(id)
        learnedPhraseIDs.formUnion(phraseIDs)
        xp += xpEarned

        let today = calendar.startOfDay(for: date)
        if let lastActiveDay {
            switch Self.daysBetween(lastActiveDay, and: today, calendar: calendar) {
            case ...0: break
            case 1: streak += 1
            default: streak = 1
            }
        } else {
            streak = 1
        }
        lastActiveDay = today
    }

    /// The streak as it should be shown today: it drops to 0 once a whole day is missed.
    func currentStreak(on date: Date, calendar: Calendar = .current) -> Int {
        guard let lastActiveDay else { return 0 }
        return Self.daysBetween(lastActiveDay, and: date, calendar: calendar) <= 1 ? streak : 0
    }

    private static func daysBetween(_ start: Date, and end: Date, calendar: Calendar) -> Int {
        calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: start),
            to: calendar.startOfDay(for: end)
        ).day ?? 0
    }
}
