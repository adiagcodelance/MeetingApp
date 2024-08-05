import SwiftUI

struct NoteCardView: View {
    @Binding var noteName: String
    @Binding var noteContent: String
    var createdDate: Date
    var onDelete: () -> Void
    @Binding var isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Untitled", text: $noteName, onEditingChanged: { editing in
                    isEditing = editing
                })
                .font(.headline)
                .padding(.bottom, 2)
                
                
                Spacer()
                
                Menu {
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .padding()
                }
            }
            
            
            Text("Created on: \(createdDate, formatter: DateFormatter.dateTime)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 5)
            
            TextEditor(text: $noteContent)
                .font(.body)
                .foregroundColor(.primary)
                .padding(8)
                .background(isEditing ? Color.white : Color.clear)
                .cornerRadius(8)
                .frame(minHeight: 100)
                .onTapGesture {
                    isEditing = true
                }
        }
        .padding()
        .background(isEditing ? Color.white : Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isEditing ? Color.blue : Color.clear, lineWidth: 1)
        )
    }
}

struct NoteCardView_Previews: PreviewProvider {
    @State static var sampleNoteName = "Untitled"
    @State static var sampleNoteContent = "Enter note content..."
    @State static var isEditing = false
    static var sampleCreatedDate = Date()

    static var previews: some View {
        NoteCardView(noteName: $sampleNoteName, noteContent: $sampleNoteContent, createdDate: sampleCreatedDate, onDelete: {
            // Sample delete action
        }, isEditing: $isEditing)
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
