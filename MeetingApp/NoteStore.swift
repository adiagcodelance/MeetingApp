import SwiftUI
import Combine

class Note: Identifiable, ObservableObject, Codable {
    var id = UUID()
    @Published var name: String
    @Published var content: String
    @Published var imageData: Data? // For image storage
    @Published var imageName: String // For the image name
    var createdDate: Date
    
    enum CodingKeys: CodingKey {
        case id, name, content, imageData, imageName, createdDate
    }
    
    init(id: UUID = UUID(), name: String, content: String, imageData: Data? = nil, imageName: String = "", createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.content = content
        self.imageData = imageData
        self.imageName = imageName
        self.createdDate = createdDate
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        imageName = try container.decode(String.self, forKey: .imageName)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(content, forKey: .content)
        try container.encode(imageData, forKey: .imageData)
        try container.encode(imageName, forKey: .imageName)
        try container.encode(createdDate, forKey: .createdDate)
    }
}

class Category: Identifiable, ObservableObject, Codable {
    var id = UUID()
    @Published var name: String
    @Published var notes: [Note]
    @Published var iconColor: String
    
    enum CodingKeys: CodingKey {
        case id, name, notes, iconColor
    }
    
    init(id: UUID = UUID(), name: String, notes: [Note] = [], iconColor: String = Color.gray.description) {
        self.id = id
        self.name = name
        self.notes = notes
        self.iconColor = iconColor
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decode([Note].self, forKey: .notes)
        iconColor = try container.decode(String.self, forKey: .iconColor)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
        try container.encode(iconColor, forKey: .iconColor)
    }
}

class Bucket: Identifiable, ObservableObject, Codable {
    var id = UUID()
    @Published var name: String
    @Published var categories: [Category]
    
    enum CodingKeys: CodingKey {
        case id, name, categories
    }
    
    init(id: UUID = UUID(), name: String, categories: [Category] = []) {
        self.id = id
        self.name = name
        self.categories = categories
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        categories = try container.decode([Category].self, forKey: .categories)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(categories, forKey: .categories)
    }
}

class ItemStore: ObservableObject {
    @Published var buckets: [Bucket] = [] {
        didSet {
            saveItems()
        }
    }
    
    init() {
        loadItems()
    }
    
    // Bucket Management
    func addBucket(_ bucket: Bucket) {
        buckets.append(bucket)
        saveItems()
    }
    
    func deleteBucket(bucketId: UUID) {
        buckets.removeAll { $0.id == bucketId }
        saveItems()
    }
    
    // Category Management
    func addCategory(to bucketId: UUID, category: Category) {
        if let bucketIndex = buckets.firstIndex(where: { $0.id == bucketId }) {
            buckets[bucketIndex].categories.append(category)
            saveItems()
        }
    }
    
    func deleteCategory(from bucketId: UUID, categoryId: UUID) {
        if let bucketIndex = buckets.firstIndex(where: { $0.id == bucketId }) {
            buckets[bucketIndex].categories.removeAll { $0.id == categoryId }
            saveItems()
        }
    }
    
    // Note Management
    func addNote(to categoryId: UUID, in bucketId: UUID, note: Note) {
        if let bucketIndex = buckets.firstIndex(where: { $0.id == bucketId }) {
            if let categoryIndex = buckets[bucketIndex].categories.firstIndex(where: { $0.id == categoryId }) {
                buckets[bucketIndex].categories[categoryIndex].notes.append(note)
                saveItems()
            }
        }
    }
    func updateNoteImageData(for noteId: UUID, in categoryId: UUID, in bucketId: UUID, with imageData: Data?) {
           if let bucketIndex = buckets.firstIndex(where: { $0.id == bucketId }),
              let categoryIndex = buckets[bucketIndex].categories.firstIndex(where: { $0.id == categoryId }),
              let noteIndex = buckets[bucketIndex].categories[categoryIndex].notes.firstIndex(where: { $0.id == noteId }) {
               buckets[bucketIndex].categories[categoryIndex].notes[noteIndex].imageData = imageData
               saveItems()
               objectWillChange.send() // Notify observers of the change
           }
       }
    
    func deleteNote(from categoryId: UUID, in bucketId: UUID, noteId: UUID) {
        if let bucketIndex = buckets.firstIndex(where: { $0.id == bucketId }) {
            if let categoryIndex = buckets[bucketIndex].categories.firstIndex(where: { $0.id == categoryId }) {
                buckets[bucketIndex].categories[categoryIndex].notes.removeAll { $0.id == noteId }
                saveItems()
            }
        }
    }
    
    // MARK: - Data Persistence
    func saveItems() {
        if let data = try? JSONEncoder().encode(buckets) {
            UserDefaults.standard.set(data, forKey: "buckets")
            print("Data saved: \(buckets)") // Debug: Check what's being saved
        } else {
            print("Failed to encode data for saving.")
        }
    }

    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "buckets"),
           let decodedBuckets = try? JSONDecoder().decode([Bucket].self, from: data) {
            buckets = decodedBuckets
            print("Data loaded: \(buckets)") // Debug: Check what's being loaded
        } else {
            print("Failed to load data.")
        }
    }

    
    // Extension for updating category icon color
    func updateCategoryIconColor(bucketId: UUID, categoryId: UUID, iconColor: String) {
        if let bucketIndex = buckets.firstIndex(where: { $0.id == bucketId }) {
            if let categoryIndex = buckets[bucketIndex].categories.firstIndex(where: { $0.id == categoryId }) {
                buckets[bucketIndex].categories[categoryIndex].iconColor = iconColor
                saveItems()
                objectWillChange.send()
            }
        }
    }
}
