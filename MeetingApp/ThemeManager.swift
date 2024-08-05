import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme

    init() {
        if let savedTheme = ThemeManager.loadTheme() {
            self.currentTheme = savedTheme
        } else {
            self.currentTheme = AppTheme.defaultTheme
        }
    }

    func applyTheme(_ theme: AppTheme) {
        currentTheme = theme
        ThemeManager.saveTheme(theme)
    }

    private static func saveTheme(_ theme: AppTheme) {
        if let data = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(data, forKey: "selectedAppTheme")
            print("App theme saved successfully.")
        }
    }

    private static func loadTheme() -> AppTheme? {
        if let data = UserDefaults.standard.data(forKey: "selectedAppTheme"),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            print("App theme loaded successfully.")
            return theme
        }
        return nil
    }
}
