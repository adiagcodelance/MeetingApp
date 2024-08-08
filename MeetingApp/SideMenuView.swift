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
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.currentTheme.backgroundColor)
                .shadow(color: themeManager.currentTheme.shadowColor, radius: 10, x: 0, y: 5)

            VStack(alignment: .leading) {
                headerView
                Divider()
                    .background(themeManager.currentTheme.primaryColor) // Customize the color if needed
                    .padding(.horizontal, 5) // Add horizontal padding if needed
                    .padding(.bottom, 20)

                Text("Buckets")
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.leading, 20)
                
                bucketsList
                    .padding(.top, 5)
                
                Spacer()
            }
            .frame(width: 320) // Increase the frame width
            .padding() // Add padding inside the rounded rectangle
        }
        .edgesIgnoringSafeArea(.vertical)
        .gesture(
            TapGesture()
                .onEnded {
                    // Quit editing mode when tapping outside the text fields
                    withAnimation {
                        isEditingBucket = false
                        isEditingCategory = false
                    }
                }
        )
        .sheet(isPresented: $showIconPicker) {
            IconPickerView(selectedIconColor: $selectedIconColor, showIconPicker: $showIconPicker)
                .environmentObject(themeManager) // Provide the ThemeManager environment object
                .onDisappear {
                    // Update the icon color for the category when the picker is dismissed
                    if let selectedBucket = selectedBucket,
                       let selectedCategory = selectedCategory {
                        itemStore.updateCategoryIconColor(bucketId: selectedBucket.id, categoryId: selectedCategory.id, iconColor: selectedIconColor)
                    }
                }
        }
    }
    
    private var headerView: some View {
        HStack {
            Button(action: {
                withAnimation {
                    let newBucket = Bucket(name: "Untitled Bucket")
                    itemStore.addBucket(newBucket)
                    selectedBucket = newBucket
                    selectedCategory = nil
                    editingBucketId = newBucket.id
                    isEditingBucket = true
                }
            }) {
                Image(systemName: "plus")
                    .font(.title2)
                    .padding()
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .padding(.leading, 20)
            .padding(.top, 50)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showSettings.toggle()
                }
            }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .padding()
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
                TextField("Bucket Name", text: $newBucketName, onCommit: {
                    if let index = itemStore.buckets.firstIndex(where: { $0.id == bucket.id }) {
                        itemStore.buckets[index].name = newBucketName
                        itemStore.saveItems()
                    }
                    withAnimation {
                        isEditingBucket = false
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 5)
                .onAppear {
                    newBucketName = bucket.name
                }
                .foregroundColor(themeManager.currentTheme.primaryColor)
            } else {
                Text(bucket.name)
                    .font(.headline)
                    .padding(.vertical, 3)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .onTapGesture {
                        withAnimation {
                            selectedBucket = bucket
                            selectedCategory = nil
                            menuVisible = false
                        }
                    }
            }
            Spacer()
            HStack {
                Button(action: {
                    withAnimation {
                        let newCategory = Category(name: "Untitled Category")
                        if let index = itemStore.buckets.firstIndex(where: { $0.id == bucket.id }) {
                            itemStore.addCategory(to: itemStore.buckets[index].id, category: newCategory)
                            selectedCategory = newCategory
                            editingCategoryId = newCategory.id
                            isEditingCategory = true
                        }
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding()
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                Menu {
                    Button(action: {
                        withAnimation {
                            editingBucketId = bucket.id
                            isEditingBucket = true
                        }
                    }) {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(action: {
                        withAnimation {
                            itemStore.deleteBucket(bucketId: bucket.id)
                            selectedBucket = nil
                            selectedCategory = nil
                        }
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.trailing, -8)
                }
            }
            .padding(.trailing)
        }
        .background(selectedBucket?.id == bucket.id ? themeManager.currentTheme.secondaryColor.opacity(0.2) : Color.clear)
        .cornerRadius(8)
    }
    
    private func categoryRow(for category: Category, in bucket: Bucket) -> some View {
        HStack {
            Image(systemName: "folder") // Display the category icon
                .foregroundColor(Color(UIColor(hex: category.iconColor) ?? .gray))
                .padding(.trailing, 5)
            if isEditingCategory && editingCategoryId == category.id {
                TextField("Category Name", text: $newCategoryName, onCommit: {
                    if let bucketIndex = itemStore.buckets.firstIndex(where: { $0.id == bucket.id }),
                       let categoryIndex = itemStore.buckets[bucketIndex].categories.firstIndex(where: { $0.id == category.id }) {
                        itemStore.buckets[bucketIndex].categories[categoryIndex].name = newCategoryName
                        itemStore.saveItems()
                    }
                    withAnimation {
                        isEditingCategory = false
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 3)
                .onAppear {
                    newCategoryName = category.name
                }
                .foregroundColor(themeManager.currentTheme.primaryColor)
            } else {
                Text(category.name)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .onTapGesture {
                        withAnimation {
                            selectedCategory = category
                            selectedBucket = bucket
                            menuVisible = false
                        }
                    }
            }
            Spacer()
            Menu {
                Button(action: {
                    withAnimation {
                        editingCategoryId = category.id
                        isEditingCategory = true
                    }
                }) {
                    Label("Rename", systemImage: "pencil")
                }
                Button(action: {
                    withAnimation {
                        itemStore.deleteCategory(from: bucket.id, categoryId: category.id)
                        selectedCategory = nil
                    }
                }) {
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
            }
        }
        .background(selectedCategory?.id == category.id ? themeManager.currentTheme.secondaryColor.opacity(0.2) : themeManager.currentTheme.backgroundColor)
        .cornerRadius(8)
        .padding(.trailing, 8) // Adjust this padding to align the buttons
    }
}

// Utility extension to convert hex string to UIColor
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
