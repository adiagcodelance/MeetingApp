import SwiftUI

struct NoteCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var noteName: String
    @Binding var noteContent: String
    var createdDate: Date
    var onDelete: () -> Void
    @Binding var isEditing: Bool
    @State private var isEditingName: Bool = false
    @State private var dynamicHeight: CGFloat = 100

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Untitled", text: $noteName)
                    .font(.headline)
                    .padding(.bottom, 2)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .background(isEditingName ? Color.white : Color.clear)
                    .disabled(!isEditingName)
                    .onTapGesture {
                        // No action needed here, editing is controlled by the menu
                    }

                Spacer()

                Menu {
                    Button(action: {
                        withAnimation {
                            isEditingName = true
                        }
                    }) {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .padding()
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }

            Text("Created on: \(createdDate, formatter: DateFormatter.dateTime)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 5)

            ZStack(alignment: .topLeading) {
                TextEditor(text: $noteContent)
                    .font(.body)
                    .foregroundColor(themeManager.currentTheme.secondaryColor)
                    .padding(8)
                    .background(themeManager.currentTheme.noteCardBackgroundColor)
                    .cornerRadius(10)
                    .frame(minHeight: dynamicHeight)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ViewHeightKey.self, value: geometry.size.height)
                        }
                    )
                    .onPreferenceChange(ViewHeightKey.self) { height in
                        dynamicHeight = height
                    }
                    .scrollContentBackground(.hidden)
                    .disabled(!isEditing)
                    .animation(.easeInOut, value: isEditing)
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                        }
                    }

                Text(noteContent) // Mirror the content to calculate dynamic height
                    .font(.body)
                    .padding(8)
                    .opacity(0) // Hide the mirrored content
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ViewHeightKey.self, value: geometry.size.height)
                        }
                    )
            }
        }
        .padding()
        .background(themeManager.currentTheme.noteCardBackgroundColor)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        )
        .shadow(color: themeManager.currentTheme.shadowColor, radius: 10, x: 0, y: 5) // Apply soft shadow
        .gesture(DragGesture()
                    .onChanged { _ in
                        withAnimation {
                            isEditing = false
                            isEditingName = false
                        }
                    }
        )
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 100
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension DateFormatter {
    static var dateTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct NoteCardView_Previews: PreviewProvider {
    @State static var sampleNoteName = "Untitled"
    @State static var sampleNoteContent = "Enter note content..."
    @State static var isEditing = false
    static var sampleCreatedDate = Date()

    static var previews: some View {
        NoteCardView(
            noteName: $sampleNoteName,
            noteContent: $sampleNoteContent,
            createdDate: sampleCreatedDate,
            onDelete: {},
            isEditing: $isEditing
        )
        .environmentObject(ThemeManager())
    }
}
