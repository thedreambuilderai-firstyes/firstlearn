import SwiftUI

struct TutorPickerView: View {
    @Binding var selection: String
    var learnerName: String

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var selectedTutor: Tutor { Tutor.find(selection) }

    var body: some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Tutor.all) { tutor in
                    TutorCard(tutor: tutor, isSelected: tutor.id == selection)
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.3)) { selection = tutor.id }
                        }
                        .accessibilityAddTraits(.isButton)
                        .accessibilityAddTraits(tutor.id == selection ? .isSelected : [])
                }
            }

            TutorSaysView(
                tutor: selectedTutor,
                text: selectedTutor.greeting(for: learnerName.isEmpty ? "friend" : learnerName)
            )
            .id(selection)
            .transition(.opacity)
        }
    }
}

private struct TutorCard: View {
    let tutor: Tutor
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            TutorAvatarView(tutor: tutor, size: 64)
            Text(tutor.name)
                .font(.system(.headline, design: .rounded))
            Text(tutor.role)
                .font(.system(.subheadline, design: .rounded))
                .foregroundStyle(tutor.color)
            Text(tutor.tagline)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3, reservesSpace: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(isSelected ? tutor.color.opacity(0.12) : Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(isSelected ? tutor.color : .clear, lineWidth: 3)
        )
    }
}

#Preview {
    @Previewable @State var selection = "ajji"
    ScrollView {
        TutorPickerView(selection: $selection, learnerName: "Priya").padding()
    }
}
