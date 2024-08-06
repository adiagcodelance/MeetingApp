import SwiftUI

class ThemeManager: ObservableObject {
    @Published var currentTheme: AppTheme {
        didSet {
            applyAppearance()
            ThemeManager.saveTheme(currentTheme)
        }
    }

    init() {
        if let savedTheme = ThemeManager.loadTheme() {
            self.currentTheme = savedTheme
        } else {
            self.currentTheme = AppTheme.defaultTheme
        }
        applyAppearance()
    }

    func applyTheme(_ theme: AppTheme) {
        currentTheme = theme
    }

    private func applyAppearance() {
        UITableView.appearance().backgroundColor = UIColor(currentTheme.backgroundColor)
        UITableViewCell.appearance().backgroundColor = UIColor(currentTheme.backgroundColor)
    }

    private static func saveTheme(_ theme: AppTheme) {
        if let data = try? JSONEncoder().encode(theme) {
            UserDefaults.standard.set(data, forKey: "selectedAppTheme")
        }
    }

    private static func loadTheme() -> AppTheme? {
        if let data = UserDefaults.standard.data(forKey: "selectedAppTheme"),
           let theme = try? JSONDecoder().decode(AppTheme.self, from: data) {
            return theme
        }
        return nil
    }
}
