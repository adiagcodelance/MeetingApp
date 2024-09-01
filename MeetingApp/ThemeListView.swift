import SwiftUI

struct ThemesListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var menuVisible: Bool
    @Binding var showSettings: Bool

    var body: some View {
        List {
            ForEach([AppTheme.defaultTheme, AppTheme.darkTheme, AppTheme.lightTheme, AppTheme.blackOrangeNeuro]) { theme in
                HStack {
                    Text(theme.name)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Spacer()
                    if theme == themeManager.currentTheme {
                        Image(systemName: "checkmark")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    themeManager.applyTheme(theme)
                }
                .listRowBackground(themeManager.currentTheme.backgroundColor)
            }
        }
        .navigationTitle("Themes")
        .background(themeManager.currentTheme.backgroundColor.edgesIgnoringSafeArea(.all))
        .foregroundColor(themeManager.currentTheme.primaryColor)
    }
}

struct ThemesListView_Previews: PreviewProvider {
    @State static var menuVisible = false
    @State static var showSettings = false

    static var previews: some View {
        ThemesListView(menuVisible: $menuVisible, showSettings: $showSettings)
            .environmentObject(ThemeManager())
    }
}
