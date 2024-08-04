import SwiftUI

struct NoteCardView: View {
    @Binding var noteName: String
    @Binding var noteContent: String
    var createdDate: Date // Add createdDate property
    var onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Untitled", text: $noteName)
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
                .background(Color.white)
                .cornerRadius(8)
                .frame(minHeight: 100) // Ensure the editor has some initial height
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
    }
}

struct NoteCardView_Previews: PreviewProvider {
    @State static var sampleNoteName = "Untitled"
    @State static var sampleNoteContent = "Enter note content..."
    static var sampleCreatedDate = Date()

    static var previews: some View {
        NoteCardView(noteName: $sampleNoteName, noteContent: $sampleNoteContent, createdDate: sampleCreatedDate, onDelete: {
            // Sample delete action
        })
    }
}



// DateFormatter extension to provide a short date format
extension DateFormatter {
    static var dateTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}
