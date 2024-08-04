import SwiftUI

struct EditNoteView: View {
    @EnvironmentObject var itemStore: ItemStore
    var item: Item
    var noteIndex: Int
    @State private var note: String
    @Environment(\.presentationMode) var presentationMode

    init(item: Item, noteIndex: Int) {
        self.item = item
        self.noteIndex = noteIndex
        self._note = State(initialValue: item.notes[noteIndex])
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Note")) {
                    TextField("Note", text: $note)
                }
            }
            .navigationTitle("Edit Note")
            .navigationBarItems(trailing: Button(action: {
                // Debugging statements
                print("Saving note at index \(noteIndex): \(note)")
                
                // Update the note in the itemStore
                if let itemIndex = itemStore.items.firstIndex(where: { $0.id == item.id }) {
                    itemStore.items[itemIndex].notes[noteIndex] = note
                    // Call saveItems to persist changes
                    itemStore.saveItems()
                    print("Note updated and saved")
                }
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Save")
            })
        }
    }
}

struct EditNote_Preview: PreviewProvider {
    static var previews: some View {
        EditNoteView(item: <#Item#>, noteIndex: <#Int#>)
    }
}

