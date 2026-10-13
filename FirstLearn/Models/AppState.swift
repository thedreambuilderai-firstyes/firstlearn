import Foundation
import Observation

/// The app's single source of truth: who is learning, with which tutor, and how far they've got.
@Observable
final class AppState {
    let course: Course
    private(set) var profile: LearnerProfile?
    private(set) var progress: ProgressState

    @ObservationIgnored private let defaults: UserDefaults
    private static let profileKey = "firstlearn.profile"
    private static let progressKey = "firstlearn.progress"

    init(defaults: UserDefaults = .standard, course: Course = .load()) {
        self.defaults = defaults
        self.course = course
        profile = Self.read(LearnerProfile.self, key: Self.profileKey, from: defaults)
        progress = Self.read(ProgressState.self, key: Self.progressKey, from: defaults) ?? ProgressState()
    }

    var tutor: Tutor { Tutor.find(profile?.tutorID) }
    var mode: LearnerMode { profile?.mode ?? .adult }
    var showScript: Bool { profile?.showScript ?? true }

    func currentStreak(now: Date = .now) -> Int {
        progress.currentStreak(on: now)
    }

    // MARK: - Lessons

    func isCompleted(_ lesson: Lesson) -> Bool {
        progress.completedLessonIDs.contains(lesson.id)
    }

    /// A lesson opens once the one before it is done.
    func isUnlocked(_ lesson: Lesson) -> Bool {
        guard lesson.isAvailable, let index = course.lessons.firstIndex(of: lesson) else { return false }
        return index == 0 || isCompleted(course.lessons[index - 1])
    }

    func recordLessonCompleted(_ lesson: Lesson, xpEarned: Int, now: Date = .now) {
        progress.recordLesson(
            id: lesson.id,
            phraseIDs: lesson.phrases.map(\.id),
            xpEarned: xpEarned,
            on: now
        )
        write(progress, key: Self.progressKey)
    }

    // MARK: - Profile

    func completeOnboarding(name: String, mode: LearnerMode, tutorID: String) {
        updateProfile(LearnerProfile(name: name, mode: mode, tutorID: tutorID))
    }

    func updateProfile(_ newProfile: LearnerProfile) {
        profile = newProfile
        write(newProfile, key: Self.profileKey)
    }

    func resetEverything() {
        profile = nil
        progress = ProgressState()
        defaults.removeObject(forKey: Self.profileKey)
        defaults.removeObject(forKey: Self.progressKey)
    }

    // MARK: - Persistence

    private func write<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func read<T: Decodable>(_ type: T.Type, key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}
