import SwiftUI
import Combine

class SelectedCategoryWrapper: ObservableObject {
    @Published var category: Category?
}

struct HomeListView: View {
    @EnvironmentObject var itemStore: ItemStore
    @State private var selectedTheme: Theme?
    @ObservedObject private var selectedCategoryWrapper = SelectedCategoryWrapper()
    @State private var menuVisible = false
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Main content
            NavigationView {
                VStack {
                    Text("Notes")
                        .font(.largeTitle)
                        .padding(.horizontal, 30)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if let selectedCategory = selectedCategoryWrapper.category {
                        ScrollView {
                            VStack(alignment: .leading) {
                                ForEach(selectedCategory.notes.indices, id: \.self) { noteIndex in
                                    let note = selectedCategory.notes[noteIndex]
                                    NoteCardView(
                                        noteName: Binding(
                                            get: { note.name },
                                            set: { newName in
                                                if let themeIndex = itemStore.themes.firstIndex(where: { $0.id == selectedTheme?.id }),
                                                   let categoryIndex = itemStore.themes[themeIndex].categories.firstIndex(where: { $0.id == selectedCategory.id }) {
                                                    itemStore.themes[themeIndex].categories[categoryIndex].notes[noteIndex].name = newName
                                                    itemStore.saveItems()
                                                }
                                            }
                                        ),
                                        noteContent: Binding(
                                            get: { note.content },
                                            set: { newContent in
                                                if let themeIndex = itemStore.themes.firstIndex(where: { $0.id == selectedTheme?.id }),
                                                   let categoryIndex = itemStore.themes[themeIndex].categories.firstIndex(where: { $0.id == selectedCategory.id }) {
                                                    itemStore.themes[themeIndex].categories[categoryIndex].notes[noteIndex].content = newContent
                                                    itemStore.saveItems()
                                                }
                                            }
                                        ),
                                        createdDate: note.createdDate,
                                        onDelete: {
                                            if let themeId = selectedTheme?.id {
                                                itemStore.deleteNote(from: selectedCategory.id, in: themeId, noteId: note.id)
                                                updateSelectedCategory(themeId: themeId, categoryId: selectedCategory.id)
                                            }
                                        }
                                    )
                                    .padding(.bottom, 10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    } else {
                        Text("Select a category to view notes.")
                            .padding()
                    }
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            if let themeId = selectedTheme?.id, let categoryId = selectedCategoryWrapper.category?.id {
                                withAnimation {
                                    let newNote = Note(name: "Untitled", content: "Enter note content...")
                                    itemStore.addNote(to: categoryId, in: themeId, note: newNote)
                                    updateSelectedCategory(themeId: themeId, categoryId: categoryId)
                                }
                            }
                        }) {
                            Image(systemName: "plus")
                                .font(.title2)
                                .padding()
                                .foregroundColor(.black
                                )
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        Menu {
                            if let selectedCategory = selectedCategoryWrapper.category {
                                ForEach(selectedCategory.notes) { note in
                                    Text(note.name)
                                }
                            } else {
                                Text("Select a category to view notes")
                            }
                        } label: {
                            HStack {
                                Text(selectedCategoryWrapper.category?.name ?? "Select Category")
                                    .foregroundColor(.black)
                                Image(systemName: "arrow.down")
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .background(Color.white) // Ensure background color to make content opaque
                .disabled(menuVisible) // Disable interactions when menu is open
                .offset(x: menuVisible ? -300 : 0 + dragOffset.width) // Move main content based on menuOffset
                .animation(.easeInOut, value: menuVisible) // Animate changes in menu visibility
            }
            
            // Side Menu
            SideMenuView(selectedTheme: $selectedTheme, selectedCategory: $selectedCategoryWrapper.category, menuVisible: $menuVisible)
                .frame(width: 300) // Set fixed width for the side menu
                .background(Color.gray.opacity(0.9))
                .offset(x: menuVisible ? UIScreen.main.bounds.width - 300 + dragOffset.width : UIScreen.main.bounds.width + dragOffset.width) // Adjust to align with the right side
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            if value.translation.width < -100 {
                                withAnimation {
                                    menuVisible = true // Show menu
                                }
                            } else if value.translation.width > 100 {
                                withAnimation {
                                    menuVisible = false // Hide menu
                                }
                            }
                        }
                )
            
            // Notch Indicator
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    if !menuVisible { // Only show the notch when the menu is hidden
                        NotchView()
                            .padding(.trailing, 10) // Add padding to keep notch visible
                    }
                }
                .frame(maxHeight: .infinity) // Ensure HStack takes full height for vertical centering
            }
            .edgesIgnoringSafeArea(.all) // Ensure notch is visible across the screen
        }
        .edgesIgnoringSafeArea(.all) // Ensure side menu goes over the navigation view
        .gesture(
            DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation
                }
                .onEnded { value in
                    if value.translation.width < -100 {
                        withAnimation {
                            menuVisible = true // Show menu
                        }
                    } else if value.translation.width > 100 {
                        withAnimation {
                            menuVisible = false // Hide menu
                        }
                    }
                }
        )
    }
    
    private func updateSelectedCategory(themeId: UUID, categoryId: UUID) {
        if let themeIndex = itemStore.themes.firstIndex(where: { $0.id == themeId }),
           let categoryIndex = itemStore.themes[themeIndex].categories.firstIndex(where: { $0.id == categoryId }) {
            selectedCategoryWrapper.category = itemStore.themes[themeIndex].categories[categoryIndex]
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
    }
}
