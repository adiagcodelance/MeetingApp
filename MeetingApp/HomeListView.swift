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
    @State private var editingNoteID: UUID? = nil
    @State private var showCalendarMenu = false
    
    var body: some View {
        ZStack {
            // Main content
            NavigationView {
                VStack {
                    Text("Notes")
                        .font(.largeTitle)
                        .padding(.horizontal, 30)
                        .padding(.top, 20) // Added top padding
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    // Add a custom line below the title with specified thickness
                    Rectangle()
                        .frame(height: 2) // Adjust this value for thickness
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.horizontal, 30) // Align the rectangle with the text
                    
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
                                        isEditing: Binding(
                                            get: { editingNoteID == note.id },
                                            set: { newValue in
                                                editingNoteID = newValue ? note.id : nil
                                            }
                                        )
                                    )
                                    .padding(.top, 20)
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
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                showCalendarMenu.toggle()
                            }
                        }) {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .padding()
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                        }
                    }
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
                            editingNoteID = nil
                            hideKeyboard()
                        }
                )
            }
            .disabled(menuVisible || showCalendarMenu)
            
            // Dismiss area
            if menuVisible || showCalendarMenu {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            menuVisible = false
                            showCalendarMenu = false
                        }
                    }
            }
            
            // Side Menu
            HStack {
                if showCalendarMenu {
                    CalendarMenuView()
                        .environmentObject(themeManager)
                        .frame(width: 300)
                        .background(themeManager.currentTheme.backgroundColor)
                        .transition(.move(edge: .leading))
                }
                
                Spacer()
                
                if menuVisible {
                    SideMenuView(selectedBucket: $selectedBucket, selectedCategory: $selectedCategoryWrapper.category, menuVisible: $menuVisible, showSettings: $showSettings)
                        .frame(width: 300)
                        .background(themeManager.currentTheme.backgroundColor)
                        .transition(.move(edge: .trailing))
                }
            }
            .edgesIgnoringSafeArea(.all)
            
            // Settings View Overlay
            if showSettings {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showSettings = false
                    }
                
                SettingsView(menuVisible: $menuVisible, showSettings: $showSettings)
                    .environmentObject(themeManager)
                    .frame(width: 300, height: 500)
                    .background(themeManager.currentTheme.backgroundColor)
                    .cornerRadius(20)
                    .shadow(radius: 20)
                    .zIndex(2)
                    .transition(.scale)
            }
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

struct HomeListView_Previews: PreviewProvider {
    static var previews: some View {
        HomeListView()
            .environmentObject(ItemStore())
            .environmentObject(ThemeManager())
    }
}
