import SwiftUI

struct SideMenuView: View {
    @EnvironmentObject var itemStore: ItemStore
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
    
    var body: some View {
        VStack(alignment: .leading) {
            headerView
            
            Text("Buckets")
                .font(.headline)
                .padding(.leading, 20)
            
            bucketsList
                .padding(.top, 5)
            
            Spacer()
        }
        .frame(width: 300)
        .background(Color.gray.opacity(0.9))
        .edgesIgnoringSafeArea(.vertical)
        .onTapGesture {
            // Prevent taps inside the menu from closing it
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
                    .foregroundColor(.black)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .padding(.leading, 20)
            .padding(.top, 80)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showSettings.toggle()
                }
            }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .padding()
                    .foregroundColor(.black)
            }
            .padding(.trailing, 20)
            .padding(.top, 80)
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
                .listRowBackground(Color.gray.opacity(0.9)) // Ensure consistent background color
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
            } else {
                Text(bucket.name)
                    .font(.headline)
                    .padding(.vertical, 3)
                    .onTapGesture {
                        withAnimation {
                            selectedBucket = bucket
                            selectedCategory = nil
                            menuVisible = false
                        }
                    }
            }
            Spacer()
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
                    .foregroundColor(.black)
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
                    .foregroundColor(.black)
                    .padding()
            }
        }
        .background(selectedBucket?.id == bucket.id ? Color.purple.opacity(0.2) : Color.clear)
        .cornerRadius(8)
    }
    
    private func categoryRow(for category: Category, in bucket: Bucket) -> some View {
        HStack {
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
            } else {
                Text(category.name)
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
    @State static var selectedBucket: Bucket?
    @State static var selectedCategory: Category?
    @State static var menuVisible = false
    @State static var showSettings = false

    static var previews: some View {
        SideMenuView(selectedBucket: $selectedBucket, selectedCategory: $selectedCategory, menuVisible: $menuVisible, showSettings: $showSettings)
            .environmentObject(ItemStore())
    }
}
