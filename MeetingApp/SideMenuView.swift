import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var itemStore: ItemStore
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedBucket: Bucket?
    @Binding var selectedCategory: Category?
    @Binding var menuVisible: Bool
    @Binding var showSettings: Bool
    
    @State private var isEditingBucket = false
    @State private var editingBucketId: UUID?
    @State private var isEditingCategory = false
    @State private var editingCategoryId: UUID?
    @State private var newBucketName = ""
    @State private var newCategoryName = ""
    @State private var showIconPicker = false
    @State private var selectedIconColor = Color.gray.description
    @State private var viewOffset: CGFloat = 0

    
    var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(themeManager.currentTheme.backgroundColor)
                    .shadow(color: themeManager.currentTheme.shadowColor, radius: 10, x: 0, y: 5)
                    .onTapGesture {
                        withAnimation {
                            endEditing()
                        }
                    }

                VStack(alignment: .leading) {
                    headerView
                    Divider()
                        .background(themeManager.currentTheme.primaryColor)
                        .padding(.horizontal, 5)
                        .padding(.bottom, 20)

                    Text("Buckets")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.leading, 20)

                    bucketsList
                        .padding(.top, 5)
                    
                    Spacer()
                }
                .padding()
                .offset(y: viewOffset) // Apply the custom offset
                .animation(.easeInOut)
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    withAnimation {
                        viewOffset = -200 // Adjust this value as needed
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
                    withAnimation {
                        viewOffset = 0
                    }
                }
            }
            .edgesIgnoringSafeArea(.vertical)
        }

    private var headerView: some View {
        HStack {
            Button(action: addNewBucket) {
                Image(systemName: "plus")
                    .font(.system(size: 14)) // Reduced font size
                    .padding(8) // Reduced padding
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .padding(.leading, 20)
            .padding(.top, 50)
            
            Spacer()
            
            Button(action: { withAnimation { showSettings.toggle() } }) {
                Image(systemName: "gearshape")
                    .font(.system(size: 12)) // Reduced font size
                    .padding(8) // Reduced padding
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .padding(.trailing, 20)
            .padding(.top, 50)
        }
    }
    
    private var bucketsList: some View {
        List {
            ForEach(itemStore.buckets) { bucket in
                Section(header: bucketHeader(for: bucket)) {
                    ForEach(bucket.categories) { category in
                        categoryRow(for: category, in: bucket)
                    }
                }
                .listRowBackground(themeManager.currentTheme.backgroundColor)
            }
        }
        .listStyle(PlainListStyle())
        .padding(.leading, 10)
    }
    
    private func bucketHeader(for bucket: Bucket) -> some View {
        HStack {
            if isEditingBucket && editingBucketId == bucket.id {
                TextField("Bucket Name", text: $newBucketName, onCommit: { saveBucketName(for: bucket) })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 5)
                    .onAppear { newBucketName = bucket.name }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            } else {
                Text(bucket.name)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.vertical, 3)
                    .onTapGesture { selectBucket(bucket) }
            }
            Spacer()
            HStack {
                addCategoryButton(for: bucket)
                Button(action: { withAnimation { deleteBucket(bucket) } }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14)) // Reduced font size
                        .padding(8) // Reduced padding
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                bucketOptionsMenu(for: bucket)
            }
            .padding(.trailing)
        }
        .cornerRadius(8)
    }
    
    private func categoryRow(for category: Category, in bucket: Bucket) -> some View {
        HStack {
            Image(systemName: "folder")
                .font(.system(size: 14)) // Adjusted icon size
                .foregroundColor(Color(UIColor(hex: category.iconColor) ?? .gray))
                .padding(.trailing, 5)
            
            if isEditingCategory && editingCategoryId == category.id {
                TextField("Category Name", text: $newCategoryName, onCommit: { saveCategoryName(for: category, in: bucket) })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.vertical, 3)
                    .onAppear { newCategoryName = category.name }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            } else {
                Text(category.name)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .onTapGesture { selectCategory(category, in: bucket) }
            }
            
            Spacer()
            
            Button(action: { withAnimation { deleteCategory(category, in: bucket) } }) {
                Image(systemName: "trash")
                    .font(.system(size: 14)) // Reduced font size
                    .padding(8) // Reduced padding
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .buttonStyle(BorderlessButtonStyle())
            
            categoryOptionsMenu(for: category, in: bucket)
        }
        .padding(.all, 5)
        .background(selectedCategory?.id == category.id ? themeManager.currentTheme.secondaryColor.opacity(0.2) : themeManager.currentTheme.backgroundColor)
        .cornerRadius(12)
        .padding(.horizontal, 5)
    }

    private func addNewBucket() {
        withAnimation {
            let newBucket = Bucket(name: "Untitled Bucket")
            itemStore.addBucket(newBucket)
            selectedBucket = newBucket
            selectedCategory = nil
            editingBucketId = newBucket.id
            isEditingBucket = true
        }
    }
    
    private func saveBucketName(for bucket: Bucket) {
        if let index = itemStore.buckets.firstIndex(where: { $0.id == bucket.id }) {
            itemStore.buckets[index].name = newBucketName
            itemStore.saveItems()
        }
        withAnimation { isEditingBucket = false }
    }
    
    private func saveCategoryName(for category: Category, in bucket: Bucket) {
        if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == bucket.id }),
           let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == category.id }) {
            itemStore.buckets[bucketIndex].categories[categoryIndex].name = newCategoryName
            itemStore.saveItems()
        }
        withAnimation { isEditingCategory = false }
    }
    
    private func addCategoryButton(for bucket: Bucket) -> some View {
        Button(action: { addNewCategory(to: bucket) }) {
            Image(systemName: "plus")
                .font(.title2)
                .padding()
                .foregroundColor(themeManager.currentTheme.primaryColor)
        }
    }
    
    private func addNewCategory(to bucket: Bucket) {
        withAnimation {
            let newCategory = Category(name: "Untitled Category")
            if let index = itemStore.buckets.firstIndex(where: { $0.id == bucket.id }) {
                itemStore.addCategory(to: itemStore.buckets[index].id, category: newCategory)
                selectedCategory = newCategory
                saveLastSelectedCategoryID(newCategory.id) // Save selected category
                editingCategoryId = newCategory.id
                isEditingCategory = true
            }
        }
    }
    
    private func bucketOptionsMenu(for bucket: Bucket) -> some View {
        Menu {
            Button(action: { withAnimation { editingBucketId = bucket.id; isEditingBucket = true } }) {
                Label("Rename", systemImage: "pencil")
            }
            Button(action: { withAnimation { deleteBucket(bucket) } }) {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title2)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .padding(12)
                .contentShape(Rectangle())
        }
    }

    
    private func deleteBucket(_ bucket: Bucket) {
        withAnimation {
            itemStore.deleteBucket(bucketId: bucket.id)
            selectedBucket = nil
            selectedCategory = nil
        }
    }
    
    private func categoryOptionsMenu(for category: Category, in bucket: Bucket) -> some View {
        Menu {
            Button(action: { withAnimation { editingCategoryId = category.id; isEditingCategory = true } }) {
                Label("Rename", systemImage: "pencil")
            }
            Button(action: { withAnimation { deleteCategory(category, in: bucket) } }) {
                Label("Delete", systemImage: "trash")
            }
            Button(action: {
                selectedCategory = category
                showIconPicker.toggle()
            }) {
                Label("Change Icon Color", systemImage: "star")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title2)
                .foregroundColor(themeManager.currentTheme.primaryColor)
                .padding(12)
                .contentShape(Rectangle())
        }
    }

    
    private func deleteCategory(_ category: Category, in bucket: Bucket) {
        withAnimation {
            itemStore.deleteCategory(from: bucket.id, categoryId: category.id)
            selectedCategory = nil
        }
    }
    
    private func selectBucket(_ bucket: Bucket) {
        withAnimation {
            selectedBucket = bucket
            selectedCategory = nil
            menuVisible = false
        }
    }
    
    private func selectCategory(_ category: Category, in bucket: Bucket) {
        withAnimation {
            selectedCategory = category
            selectedBucket = bucket
            saveLastSelectedCategoryID(category.id) // Save selected category
            menuVisible = false
        }
    }
    
    private func updateCategoryIconColor() {
        if let selectedBucket = selectedBucket,
           let selectedCategory = selectedCategory {
            itemStore.updateCategoryIconColor(bucketId: selectedBucket.id, categoryId: selectedCategory.id, iconColor: selectedIconColor)
        }
    }
    
    private func endEditing() {
        if isEditingBucket, let editingBucketId = editingBucketId {
            saveBucketName(for: itemStore.buckets.first { $0.id == editingBucketId }!)
        }
        if isEditingCategory, let editingCategoryId = editingCategoryId, let selectedBucket = selectedBucket {
            saveCategoryName(for: selectedBucket.categories.first { $0.id == editingCategoryId }!, in: selectedBucket)
        }
        isEditingBucket = false
        isEditingCategory = false
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
}

extension UIColor {
    convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

struct SideMenuView_Previews: PreviewProvider {
    @State static var selectedBucket: Bucket?
    @State static var selectedCategory: Category?
    @State static var menuVisible = false
    @State static var showSettings = false

    static var previews: some View {
        SideMenuView(selectedBucket: $selectedBucket, selectedCategory: $selectedCategory, menuVisible: $menuVisible, showSettings: $showSettings)
            .environmentObject(ItemStore())
            .environmentObject(ThemeManager())
    }
}
