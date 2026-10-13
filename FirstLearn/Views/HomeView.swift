import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var activeLesson: Lesson?
    @State private var showSettings = false

    var body: some View {
        let tutor = appState.tutor

        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    TutorSaysView(tutor: tutor, text: greeting(from: tutor))

                    StatsBar(streak: appState.currentStreak(), xp: appState.progress.xp,
                             words: appState.progress.learnedPhraseIDs.count)

                    PathMapView(tutor: tutor) { activeLesson = $0 }
                }
                .padding()
            }
            .navigationTitle(appState.course.title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Settings", systemImage: "gearshape.fill") { showSettings = true }
                }
            }
            .sheet(isPresented: $showSettings) { SettingsView() }
            .fullScreenCover(item: $activeLesson) { LessonView(lesson: $0) }
        }
        .tint(tutor.color)
    }

    private func greeting(from tutor: Tutor) -> String {
        let name = appState.profile?.name ?? ""
        let nextLesson = appState.course.lessons.first { appState.isUnlocked($0) && !appState.isCompleted($0) }
        guard let nextLesson else { return tutor.greeting(for: name) }
        if appState.progress.completedLessonIDs.isEmpty {
            return tutor.greeting(for: name)
        }
        return "Welcome back, \(name)! Next up: \(nextLesson.title)"
    }
}

private struct StatsBar: View {
    let streak: Int
    let xp: Int
    let words: Int

    var body: some View {
        HStack(spacing: 12) {
            stat("🔥", "\(streak)", streak == 1 ? "day" : "days")
            stat("⭐️", "\(xp)", "XP")
            stat("📚", "\(words)", "words")
        }
    }

    private func stat(_ icon: String, _ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(icon).font(.title2)
            Text(value).font(.system(.title3, design: .rounded).weight(.bold))
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    let state = AppState(defaults: UserDefaults(suiteName: "preview")!)
    state.completeOnboarding(name: "Priya", mode: .adult, tutorID: "ajji")
    return HomeView().environment(state)
}
