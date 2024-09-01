import SwiftUI

struct AppTheme: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var primaryColor: Color
    var secondaryColor: Color
    var backgroundColor: Color
    var noteCardBackgroundColor: Color
    var borderColor: Color
    var shadowColor: Color
    
    enum CodingKeys: CodingKey {
        case id, name, primaryColor, secondaryColor, backgroundColor, noteCardBackgroundColor, borderColor, shadowColor
    }
    
    init(id: UUID = UUID(), name: String, primaryColor: Color, secondaryColor: Color, backgroundColor: Color,  noteCardBackgroundColor: Color, borderColor: Color, shadowColor: Color) {
        self.id = id
        self.name = name
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.backgroundColor = backgroundColor
        self.noteCardBackgroundColor = noteCardBackgroundColor
        self.borderColor = borderColor
        self.shadowColor = shadowColor
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        primaryColor = try Color(hex: container.decode(String.self, forKey: .primaryColor))
        secondaryColor = try Color(hex: container.decode(String.self, forKey: .secondaryColor))
        backgroundColor = try Color(hex: container.decode(String.self, forKey: .backgroundColor))
        noteCardBackgroundColor = try Color(hex: container.decode(String.self, forKey: .noteCardBackgroundColor))
        borderColor = try Color(hex: container.decode(String.self, forKey: .borderColor))
        shadowColor = try Color(hex: container.decode(String.self, forKey: .shadowColor))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(primaryColor.toHex(), forKey: .primaryColor)
        try container.encode(secondaryColor.toHex(), forKey: .secondaryColor)
        try container.encode(backgroundColor.toHex(), forKey: .backgroundColor)
        try container.encode(noteCardBackgroundColor.toHex(), forKey: .noteCardBackgroundColor)
        try container.encode(borderColor.toHex(), forKey: .borderColor)
        try container.encode(shadowColor.toHex(), forKey: .shadowColor)
    }
    
    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let defaultTheme = AppTheme(
            name: "Default",
            primaryColor: .blue,
            secondaryColor: .green,
            backgroundColor: .white,
            noteCardBackgroundColor: .white,
            borderColor: .white,
            shadowColor: Color.black.opacity(0.1)
        )

        static let darkTheme = AppTheme(
            name: "Dark",
            primaryColor: .white,
            secondaryColor: .gray,
            backgroundColor: .black,
            noteCardBackgroundColor: Color(hex: "#1C1C1C"), // Dark Gray for note cards
            borderColor: .white,
            shadowColor: Color.black.opacity(0.2) // Slightly stronger shadow for dark mode
        )

        static let lightTheme = AppTheme(
            name: "Light",
            primaryColor: .black,
            secondaryColor: .blue,
            backgroundColor: .white,
            noteCardBackgroundColor: .white,
            borderColor: Color.black.opacity(0.1), // Subtle border for light mode
            shadowColor: Color.black.opacity(0.1)
        )

        static let blackOrangeNeuro = AppTheme(
            name: "Black Orange Neuro",
            primaryColor: Color(hex: "#FFA500"), // Orange
            secondaryColor: Color(hex: "#FFFFFF"), // White
            backgroundColor: Color(hex: "#1C1C1C"), // Almost Black for Neuromorphic background
            noteCardBackgroundColor: Color(hex: "#2C2C2C"), // Dark Gray for note cards
            borderColor: Color.white.opacity(0.2), // Soft white border for contrast
            shadowColor: Color.black.opacity(0.2) // Deeper shadow for Neuromorphism
        )
}

// Color extension for Hex conversion
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8 * 17) & 0xFF, (int >> 4 * 17) & 0xFF, (int * 17) & 0xFF)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    func toHex() -> String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 0]
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        let a = Float(components.count > 3 ? components[3] : 1.0)
        return String(format: "%02lX%02lX%02lX%02lX", Int(a * 255), Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
