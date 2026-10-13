import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var draft: LearnerProfile?
    @State private var confirmReset = false

    var body: some View {
        NavigationStack {
            Form {
                if let draft = Binding($draft) {
                    Section {
                        TextField("Name", text: draft.name)
                        Picker("Learner", selection: draft.mode) {
                            ForEach(LearnerMode.allCases) { Text($0.title).tag($0) }
                        }
                        .pickerStyle(.segmented)
                        Toggle("Show Kannada script (ಕನ್ನಡ)", isOn: draft.showScript)
                    } header: {
                        Text("You")
                    } footer: {
                        if !Speaker.shared.hasKannadaVoice {
                            Text("This iPhone has no Kannada voice, so words are read out from their English spelling.")
                        }
                    }

                    Section("Teacher") {
                        TutorPickerView(selection: draft.tutorID, learnerName: draft.wrappedValue.name)
                            .listRowInsets(EdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12))
                    }
                }

                Section {
                    Button("Start over", role: .destructive) { confirmReset = true }
                } footer: {
                    Text("Clears your name, teacher, streak and all progress.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog("Start over?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Erase everything", role: .destructive) {
                    dismiss()
                    appState.resetEverything()
                }
            } message: {
                Text("This can't be undone.")
            }
        }
        .onAppear { draft = appState.profile }
        .onChange(of: draft) { _, newValue in
            guard var newValue, newValue != appState.profile else { return }
            newValue.name = newValue.name.trimmingCharacters(in: .whitespacesAndNewlines)
            if !newValue.name.isEmpty { appState.updateProfile(newValue) }
        }
    }
}
