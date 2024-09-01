import SwiftUI

struct NoteCardView: View {
    @Binding var noteName: String
    @Binding var noteContent: String
    let createdDate: Date
    let onDelete: () -> Void
    @Binding var isEditing: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .leading) {
            // Title TextField/Display
            if isEditing {
                TextField("Note Title", text: $noteName)
                    .font(.headline)
                    .padding(.bottom, 2)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                    .background(themeManager.currentTheme.backgroundColor)
            } else {
                Text(noteName)
                    .font(.headline)
                    .padding(.bottom, 2)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
            }
            
            // Content TextEditor/Display
            ZStack(alignment: .leading) {
                if noteContent.isEmpty || isEditing == true {
                    Text("Enter note content...")
                        .foregroundColor(themeManager.currentTheme.secondaryColor.opacity(0.5))
                }
                TextEditor(text: $noteContent)
                    .font(.body)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .background(themeManager.currentTheme.backgroundColor)
                    .frame(minHeight: 50)
                    .padding(.vertical, 5)
                    .opacity(noteContent.isEmpty ? 0.25 : 1)
                    .disabled(!isEditing)
            }
            
            HStack {
                Text("Created on \(createdDate, formatter: dateFormatter)")
                    .font(.footnote)
                    .foregroundColor(themeManager.currentTheme.secondaryColor)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.backgroundColor)
        .cornerRadius(10)
        .shadow(color: themeManager.currentTheme.shadowColor, radius: isEditing ? 5 : 0)
        .onTapGesture {
            isEditing = true
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }
}
