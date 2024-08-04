import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var itemStore: ItemStore
    @Binding var selectedTheme: Theme?
    @Binding var selectedCategory: Category?
    @Binding var menuVisible: Bool
    
    @State private var isEditingTheme = false
    @State private var editingThemeId: UUID?
    @State private var isEditingCategory = false
    @State private var editingCategoryId: UUID?
    @State private var newThemeName = ""
    @State private var newCategoryName = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    let newTheme = Theme(name: "Untitled Theme")
                    itemStore.addTheme(newTheme)
                    selectedTheme = newTheme
                    selectedCategory = nil
                    editingThemeId = newTheme.id
                    isEditingTheme = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding()
                        .foregroundColor(.black)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding([.leading, .top], 20)
                Spacer()
            }
            
            Text("Themes")
                .font(.headline)
                .padding([.leading, .top], 20)
            
            themesList
                .padding(.top, 10)
            
            Spacer()
        }
        .frame(width: 300)
        .background(Color.gray.opacity(0.9))
        .edgesIgnoringSafeArea(.vertical)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if value.translation.width < 0 {
                        withAnimation {
                            menuVisible = false
                        }
                    }
                }
        )
    }
    
    private var themesList: some View {
        List {
            ForEach(itemStore.themes) { theme in
                Section(header: themeHeader(for: theme)) {
                    ForEach(theme.categories) { category in
                        categoryRow(for: category, in: theme)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.9)) // Ensure consistent background color
            }
        }
        .listStyle(PlainListStyle())
        .padding(.leading, 10)
    }
    
    private func themeHeader(for theme: Theme) -> some View {
        HStack {
            if isEditingTheme && editingThemeId == theme.id {
                TextField("Theme Name", text: $newThemeName, onCommit: {
                    if let index = itemStore.themes.firstIndex(where: { $0.id == theme.id }) {
                        itemStore.themes[index].name = newThemeName
                        itemStore.saveItems()
                    }
                    isEditingTheme = false
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
                .onAppear {
                    newThemeName = theme.name
                }
            } else {
                Text(theme.name)
                    .font(.headline)
                    .padding(.vertical, 5)
                    .onTapGesture {
                        selectedTheme = theme
                        selectedCategory = nil
                        withAnimation {
                            menuVisible = false
                        }
                    }
            }
            Spacer()
            Button(action: {
                let newCategory = Category(name: "Untitled Category")
                if let index = itemStore.themes.firstIndex(where: { $0.id == theme.id }) {
                    itemStore.addCategory(to: itemStore.themes[index].id, category: newCategory)
                    selectedCategory = newCategory
                    editingCategoryId = newCategory.id
                    isEditingCategory = true
                }
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding()
                    .foregroundColor(.black)
            }
            Menu {
                Button(action: {
                    editingThemeId = theme.id
                    isEditingTheme = true
                }) {
                    Label("Rename", systemImage: "pencil")
                }
                Button(action: {
                    itemStore.deleteTheme(themeId: theme.id)
                    selectedTheme = nil
                    selectedCategory = nil
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .background(selectedTheme?.id == theme.id ? Color.purple.opacity(0.2) : Color.clear)
        .cornerRadius(8)
    }
    
    private func categoryRow(for category: Category, in theme: Theme) -> some View {
        HStack {
            if isEditingCategory && editingCategoryId == category.id {
                TextField("Category Name", text: $newCategoryName, onCommit: {
                    if let themeIndex = itemStore.themes.firstIndex(where: { $0.id == theme.id }),
                       let categoryIndex = itemStore.themes[themeIndex].categories.firstIndex(where: { $0.id == category.id }) {
                        itemStore.themes[themeIndex].categories[categoryIndex].name = newCategoryName
                        itemStore.saveItems()
                    }
                    isEditingCategory = false
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
                .onAppear {
                    newCategoryName = category.name
                }
            } else {
                Text(category.name)
                    .onTapGesture {
                        selectedCategory = category
                        selectedTheme = theme
                        withAnimation {
                            menuVisible = false
                        }
                    }
            }
            Spacer()
            Menu {
                Button(action: {
                    editingCategoryId = category.id
                    isEditingCategory = true
                }) {
                    Label("Rename", systemImage: "pencil")
                }
                Button(action: {
                    itemStore.deleteCategory(from: theme.id, categoryId: category.id)
                    selectedCategory = nil
                }) {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.title2)
                    .foregroundColor(.black)
            }
        }
        .background(selectedCategory?.id == category.id ? Color.purple.opacity(0.2) : Color.gray.opacity(0.9)) // Ensure consistent background color
        .cornerRadius(8)
    }
}

struct SideMenuView_Previews: PreviewProvider {
    @State static var selectedTheme: Theme?
    @State static var selectedCategory: Category?
    @State static var menuVisible = false

    static var previews: some View {
        SideMenuView(selectedTheme: $selectedTheme, selectedCategory: $selectedCategory, menuVisible: $menuVisible)
            .environmentObject(ItemStore())
    }
}
