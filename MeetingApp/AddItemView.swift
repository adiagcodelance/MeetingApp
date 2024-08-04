/**import SwiftUI

struct AddItemView: View {
    @EnvironmentObject var itemStore: ItemStore
    @State private var itemName: String = ""
    @State private var noteText: String = ""
    @State private var showAddNoteView: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter item name", text: $itemName)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextField("Enter note text (optional)", text: $noteText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: {
                    if !itemName.isEmpty {
                        itemStore.addItem(name: itemName)
                        if !noteText.isEmpty {
                            if let newItem = itemStore.items.last {
                                itemStore.addNoteToItem(itemId: newItem.id, note: noteText)
                            }
                        }
                        itemName = ""
                        noteText = ""
                    }
                }) {
                    Text("Add Item")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Spacer()
                
                Button(action: {
                    showAddNoteView.toggle()
                }) {
                    Text("Add Note to Selected Item")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showAddNoteView) {
                    AddNoteView()
                        .environmentObject(itemStore)
                }
            }
            .navigationTitle("Add Item")
            .padding()
        }
    }
}
*/
