import SwiftUI

struct AppTheme: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var primaryColor: Color
    var secondaryColor: Color
    var backgroundColor: Color
    
    enum CodingKeys: CodingKey {
        case id, name, primaryColor, secondaryColor, backgroundColor
    }
    
    init(id: UUID = UUID(), name: String, primaryColor: Color, secondaryColor: Color, backgroundColor: Color) {
        self.id = id
        self.name = name
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        primaryColor = try Color(from: container, forKey: .primaryColor) ?? .clear
        secondaryColor = try Color(from: container, forKey: .secondaryColor) ?? .clear
        backgroundColor = try Color(from: container, forKey: .backgroundColor) ?? .clear
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try primaryColor.encode(to: &container, forKey: .primaryColor)
        try secondaryColor.encode(to: &container, forKey: .secondaryColor)
        try backgroundColor.encode(to: &container, forKey: .backgroundColor)
    }
}

// Extensions for Color to conform to Codable
extension Color {
    private struct RGBA: Codable {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
    }
    
    private var rgba: RGBA? {
        guard let components = cgColor?.components else { return nil }
        let numberOfComponents = cgColor?.numberOfComponents ?? 0
        let red, green, blue, alpha: CGFloat
        
        if numberOfComponents == 2 {
            red = components[0]
            green = components[0]
            blue = components[0]
            alpha = components[1]
        } else if numberOfComponents == 4 {
            red = components[0]
            green = components[1]
            blue = components[2]
            alpha = components[3]
        } else {
            return nil
        }
        
        return RGBA(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    init?(from container: KeyedDecodingContainer<AppTheme.CodingKeys>, forKey key: AppTheme.CodingKeys) throws {
        guard let rgba = try? container.decode(RGBA.self, forKey: key) else { return nil }
        self = Color(red: rgba.red, green: rgba.green, blue: rgba.blue, opacity: rgba.alpha)
    }
    
    func encode(to container: inout KeyedEncodingContainer<AppTheme.CodingKeys>, forKey key: AppTheme.CodingKeys) throws {
        if let rgba = rgba {
            try container.encode(rgba, forKey: key)
        }
    }
}

extension AppTheme {
    static var defaultTheme = AppTheme(name: "Default", primaryColor: .blue, secondaryColor: .green, backgroundColor: .white)
    static var darkTheme = AppTheme(name: "Dark", primaryColor: .white, secondaryColor: .gray, backgroundColor: .black)
    static var lightTheme = AppTheme(name: "Light", primaryColor: .black, secondaryColor: .blue, backgroundColor: .white)
}
