import SwiftUI

struct ThemesListView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var menuVisible: Bool
    
    var body: some View {
        List {
            ForEach([AppTheme.defaultTheme, AppTheme.darkTheme, AppTheme.lightTheme]) { theme in
                HStack {
                    Text(theme.name)
                    Spacer()
                    if theme.id == themeManager.currentTheme.id {
                        Image(systemName: "checkmark")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    themeManager.applyTheme(theme)
                    menuVisible = false
                }
            }
        }
        .navigationTitle("Themes")
    }
}

struct ThemesListView_Previews: PreviewProvider {
    @State static var menuVisible = false
    
    static var previews: some View {
        ThemesListView(menuVisible: $menuVisible)
            .environmentObject(ThemeManager())
    }
}
