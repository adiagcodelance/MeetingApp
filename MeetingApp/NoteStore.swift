import SwiftUI
import Combine

class Note: Identifiable, ObservableObject, Codable {
    var id = UUID()
    @Published var name: String
    @Published var content: String
    var createdDate: Date
    
    enum CodingKeys: CodingKey {
        case id, name, content, createdDate
    }
    
    init(id: UUID = UUID(), name: String, content: String, createdDate: Date = Date()) {
        self.id = id
        self.name = name
        self.content = content
        self.createdDate = createdDate
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        content = try container.decode(String.self, forKey: .content)
        createdDate = try container.decode(Date.self, forKey: .createdDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(content, forKey: .content)
        try container.encode(createdDate, forKey: .createdDate)
    }
}

class Category: Identifiable, ObservableObject, Codable {
    var id = UUID()
    @Published var name: String
    @Published var notes: [Note]
    
    enum CodingKeys: CodingKey {
        case id, name, notes
    }
    
    init(id: UUID = UUID(), name: String, notes: [Note] = []) {
        self.id = id
        self.name = name
        self.notes = notes
    }
    
    // MARK: - Codable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        notes = try container.decode([Note].self, forKey: .notes)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(notes, forKey: .notes)
    }
}

class Theme: Identifiable, ObservableObject, Codable {
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
    @Published var themes: [Theme] = [] {
        didSet {
            saveItems()
        }
    }
    
    init() {
        loadItems()
    }
    
    // Theme Management
    func addTheme(_ theme: Theme) {
        themes.append(theme)
        saveItems()
    }
    
    func deleteTheme(themeId: UUID) {
        themes.removeAll { $0.id == themeId }
        saveItems()
    }
    
    // Category Management
    func addCategory(to themeId: UUID, category: Category) {
        if let themeIndex = themes.firstIndex(where: { $0.id == themeId }) {
            themes[themeIndex].categories.append(category)
            saveItems()
        }
    }
    
    func deleteCategory(from themeId: UUID, categoryId: UUID) {
        if let themeIndex = themes.firstIndex(where: { $0.id == themeId }) {
            themes[themeIndex].categories.removeAll { $0.id == categoryId }
            saveItems()
        }
    }
    
    // Note Management
    func addNote(to categoryId: UUID, in themeId: UUID, note: Note) {
        if let themeIndex = themes.firstIndex(where: { $0.id == themeId }) {
            if let categoryIndex = themes[themeIndex].categories.firstIndex(where: { $0.id == categoryId }) {
                themes[themeIndex].categories[categoryIndex].notes.append(note)
                saveItems()
            }
        }
    }
    
    func deleteNote(from categoryId: UUID, in themeId: UUID, noteId: UUID) {
        if let themeIndex = themes.firstIndex(where: { $0.id == themeId }) {
            if let categoryIndex = themes[themeIndex].categories.firstIndex(where: { $0.id == categoryId }) {
                themes[themeIndex].categories[categoryIndex].notes.removeAll { $0.id == noteId }
                saveItems()
            }
        }
    }
    
    // MARK: - Data Persistence
    func saveItems() {
        if let data = try? JSONEncoder().encode(themes) {
            UserDefaults.standard.set(data, forKey: "themes")
            print("Themes saved successfully.")
        }
    }
    
    private func loadItems() {
        if let data = UserDefaults.standard.data(forKey: "themes"),
           let decodedThemes = try? JSONDecoder().decode([Theme].self, from: data) {
            themes = decodedThemes
            print("Themes loaded successfully: \(themes)")
        }
    }
}
