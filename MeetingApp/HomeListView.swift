import SwiftUI
import Combine
import EventKit

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
    @State private var recentCategories: [Category] = []
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    HStack {
                        Text("Notes")
                            .font(.largeTitle)
                            .padding(.leading, 30)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .onAppear {
                                requestCalendarAccess { granted in
                                    if granted {
                                        print("Calendar access granted")
                                    } else {
                                        print("Calendar access denied")
                                    }
                                }
                            }
                        Spacer()
                        
                        if !recentCategories.isEmpty {
                            Menu {
                                ForEach(recentCategories.prefix(5), id: \.id) { category in
                                    Button(action: {
                                        selectCategory(category)
                                    }) {
                                        Text(category.name)
                                            .foregroundColor(themeManager.currentTheme.primaryColor)
                                    }
                                }
                            } label: {
                                Text("Recent Category")
                                    .font(.title3)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                Image(systemName: "chevron.down")
                                    .padding(.trailing)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                            }
                            .padding(.trailing, 10)
                           // .background(themeManager.currentTheme.backgroundColor)
                            .shadow(color: themeManager.currentTheme.shadowColor, radius: 5, x: 0, y: 2)
                        }
                    }
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.horizontal, 30)
                    
                    if let selectedCategory = selectedCategoryWrapper.category {
                        ScrollView {
                            VStack(alignment: .leading) {
                                if(selectedCategory.notes .isEmpty){
                                    Text("Click The Plus Button To Add A New Note")
                                        .font(.title3)
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                        .padding(.top, 20)
                                    Button(action: addNewNote) {
                                        Image(systemName: "plus")
                                            .font(.largeTitle)
                                            .padding(.top, 50)
                                            .padding(.leading, 160)
                                            .foregroundColor(themeManager.currentTheme.primaryColor)
                                    }
                                }
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
                            Image(systemName: "line.horizontal.3")
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
                .onAppear {
                    loadLastSelectedCategory()
                }
            }
            .disabled(menuVisible || showCalendarMenu)
            
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
            
            HStack {
                if showCalendarMenu {
                    CalendarMenuView()
                        .environmentObject(themeManager)
                        .frame(width: 280)
                        .background(themeManager.currentTheme.backgroundColor)
                        .transition(.move(edge: .leading))
                }
                
                Spacer()
                
                if menuVisible {
                    SideMenuView(selectedBucket: $selectedBucket, selectedCategory: $selectedCategoryWrapper.category, menuVisible: $menuVisible, showSettings: $showSettings)
                        .frame(width: 350)
                        .background(themeManager.currentTheme.backgroundColor)
                        .transition(.move(edge: .trailing))
                }
            }
            .edgesIgnoringSafeArea(.all)
            
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
    
    
    private func selectCategory(_ category: Category) {
        selectedCategoryWrapper.category = category
        selectedBucket = itemStore.buckets.first(where: { $0.categories.contains(where: { $0.id == category.id }) })
        saveLastSelectedCategoryID(category.id)
        updateRecentCategories(category)
    }

    private func loadLastSelectedCategory() {
        print("Loading last selected category...")
        
        if let lastCategoryIdString = UserDefaults.standard.string(forKey: "LastSelectedCategoryID"),
           let lastCategoryId = UUID(uuidString: lastCategoryIdString) {
            for bucket in itemStore.buckets {
                if let category = bucket.categories.first(where: { $0.id == lastCategoryId }) {
                    print("Found last selected category: \(category.name)")
                    selectedBucket = bucket
                    DispatchQueue.main.async {
                        selectedCategoryWrapper.category = category
                        updateRecentCategories(category)
                    }
                    break
                }
            }
        } else {
            print("No last selected category found.")
        }
    }

    private func saveLastSelectedCategoryID(_ categoryId: UUID?) {
        if let categoryId = categoryId {
            print("Saving last selected category ID: \(categoryId.uuidString)")
            UserDefaults.standard.set(categoryId.uuidString, forKey: "LastSelectedCategoryID")
        } else {
            print("Removing last selected category ID.")
            UserDefaults.standard.removeObject(forKey: "LastSelectedCategoryID")
        }
    }

    private func updateNoteName(_ newName: String, at noteIndex: Int, in category: Category) {
        if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == selectedBucket?.id }),
           let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == category.id }) {
            itemStore.buckets[bucketIndex].categories[categoryIndex].notes[noteIndex].name = newName
            itemStore.saveItems()
            saveLastSelectedCategoryID(category.id)
            updateRecentCategories(category)
        }
    }
    
    private func updateNoteContent(_ newContent: String, at noteIndex: Int, in category: Category) {
        if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == selectedBucket?.id }),
           let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == category.id }) {
            itemStore.buckets[bucketIndex].categories[categoryIndex].notes[noteIndex].content = newContent
            itemStore.saveItems()
            saveLastSelectedCategoryID(category.id)
            updateRecentCategories(category)
        }
    }
    
    private func deleteNote(_ noteId: UUID, from category: Category) {
        if let bucketId = selectedBucket?.id {
            itemStore.deleteNote(from: category.id, in: bucketId, noteId: noteId)
            updateSelectedCategory(bucketId: bucketId, categoryId: category.id)
            updateRecentCategories(category)
        }
    }
    
    private func addNewNote() {
        if let bucketId = selectedBucket?.id, let categoryId = selectedCategoryWrapper.category?.id {
            withAnimation {
                let newNote = Note(name: "Untitled", content: "Enter note content...")
                itemStore.addNote(to: categoryId, in: bucketId, note: newNote)
                updateSelectedCategory(bucketId: bucketId, categoryId: categoryId)
                saveLastSelectedCategoryID(categoryId)
                updateRecentCategories(selectedCategoryWrapper.category)
            }
        }
    }
    
    private func updateSelectedCategory(bucketId: UUID, categoryId: UUID) {
        if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == bucketId }),
           let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == categoryId }) {
            selectedCategoryWrapper.category = itemStore.buckets[bucketIndex].categories[categoryIndex]
        }
    }
    
    private func updateRecentCategories(_ category: Category?) {
        guard let category = category else { return }
        if let index = recentCategories.firstIndex(where: { $0.id == category.id }) {
            recentCategories.remove(at: index)
        }
        recentCategories.insert(category, at: 0)
    }
}

func requestCalendarAccess(completion: @escaping (Bool) -> Void) {
    let eventStore = EKEventStore()

    eventStore.requestAccess(to: .event) { granted, error in
        DispatchQueue.main.async {
            if let error = error {
                print("Failed to request access to calendar: \(error.localizedDescription)")
                completion(false)
            } else {
                completion(granted)
            }
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
