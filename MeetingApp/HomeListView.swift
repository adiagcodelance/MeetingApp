import SwiftUI
import Combine

class SelectedCategoryWrapper: ObservableObject {
    @Published var category: Category?
}

struct HomeListView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedBucket: Bucket?
    @ObservedObject private var selectedCategoryWrapper = SelectedCategoryWrapper()
    @State private var menuVisible = false
    @State private var showSettings = false
    @State private var isEditingNote = false
    
    var body: some View {
        ZStack {
            // Main content
            NavigationView {
                VStack {
                    Text("Notes")
                        .font(.largeTitle)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    if let selectedCategory = selectedCategoryWrapper.category {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(selectedCategory.notes.indices, id: \.self) { noteIndex in
                                    let note = selectedCategory.notes[noteIndex]
                                    NoteCardView(
                                        noteName: Binding(
                                            get: { note.name },
                                            set: { newName in
                                                updateNoteName(newName, at: noteIndex, in: selectedCategory)
                                            }
                                        ),
                                        noteContent: Binding(
                                            get: { note.content },
                                            set: { newContent in
                                                updateNoteContent(newContent, at: noteIndex, in: selectedCategory)
                                            }
                                        ),
                                        createdDate: note.createdDate,
                                        onDelete: {
                                            deleteNote(note.id, from: selectedCategory)
                                        },
                                        isEditing: $isEditingNote
                                    )
                                    .padding(.bottom, 10)
                                    .onTapGesture {
                                        isEditingNote = false
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("Select a category to view notes.")
                            .padding()
                            .foregroundColor(themeManager.currentTheme.secondaryColor)
                    }
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button(action: addNewNote) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .padding()
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                        Button(action: {
                            withAnimation {
                                menuVisible.toggle()
                            }
                        }) {
                            Image(systemName: "sidebar.right")
                                .font(.title2)
                                .padding()
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
                }
                .background(themeManager.currentTheme.backgroundColor)
                .gesture(
                    TapGesture()
                        .onEnded {
                            isEditingNote = false
                            hideKeyboard()
                        }
                )
            }
            .disabled(menuVisible)
            
            // Dismiss area
            if menuVisible {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            menuVisible = false
                        }
                    }
            }
            
            // Side Menu
            HStack {
                Spacer()
                SideMenuView(selectedBucket: $selectedBucket, selectedCategory: $selectedCategoryWrapper.category, menuVisible: $menuVisible, showSettings: $showSettings)
                    .frame(width: 300)
                    .background(themeManager.currentTheme.backgroundColor)
                    .offset(x: menuVisible ? 0 : 300)
                    .transition(.move(edge: .trailing))
                    .zIndex(1)
            }
            .edgesIgnoringSafeArea(.all)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    private func updateNoteName(_ newName: String, at noteIndex: Int, in category: Category) {
        if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == selectedBucket?.id }),
           let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == category.id }) {
            itemStore.buckets[bucketIndex].categories[categoryIndex].notes[noteIndex].name = newName
            itemStore.saveItems()
        }
    }
    
    private func updateNoteContent(_ newContent: String, at noteIndex: Int, in category: Category) {
        if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == selectedBucket?.id }),
           let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == category.id }) {
            itemStore.buckets[bucketIndex].categories[categoryIndex].notes[noteIndex].content = newContent
            itemStore.saveItems()
        }
    }
    
    private func deleteNote(_ noteId: UUID, from category: Category) {
        if let bucketId = selectedBucket?.id {
            itemStore.deleteNote(from: category.id, in: bucketId, noteId: noteId)
            updateSelectedCategory(bucketId: bucketId, categoryId: category.id)
        }
    }
    
    private func addNewNote() {
        if let bucketId = selectedBucket?.id, let categoryId = selectedCategoryWrapper.category?.id {
            withAnimation {
                let newNote = Note(name: "Untitled", content: "Enter note content...")
                itemStore.addNote(to: categoryId, in: bucketId, note: newNote)
                updateSelectedCategory(bucketId: bucketId, categoryId: categoryId)
            }
        }
    }
    
    private func updateSelectedCategory(bucketId: UUID, categoryId: UUID) {
        if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == bucketId }),
           let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == categoryId }) {
            selectedCategoryWrapper.category = itemStore.buckets[bucketIndex].categories[categoryIndex]
        }
    }
}

struct NotchView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.gray.opacity(0.4))
            .frame(width: 8, height: 80)
    }
}

struct ViewOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView()
            .environmentObject(ItemStore())
            .environmentObject(ThemeManager())
    }
}
