import SwiftUI

struct SettingsView: View {
    @Binding var menuVisible: Bool
    @Binding var showSettings: Bool
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Background overlay to dim the main view
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showSettings = false // Dismiss the settings overlay
                }

            // Main settings view
            NavigationView {
                List {
                    NavigationLink(destination: ThemesListView(menuVisible: $menuVisible, showSettings: $showSettings)) {
                        Text("Themes")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    .listRowBackground(themeManager.currentTheme.backgroundColor)
                }
                .navigationTitle("Settings")
                .background(themeManager.currentTheme.backgroundColor.edgesIgnoringSafeArea(.all)) // Background for the navigation view
            }
            .background(themeManager.currentTheme.backgroundColor.edgesIgnoringSafeArea(.all)) // Background for the entire frame
            .frame(width: 300, height: 500)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
        .background(themeManager.currentTheme.backgroundColor.edgesIgnoringSafeArea(.all)) // Background for the entire view
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var menuVisible = false
    @State static var showSettings = true

    static var previews: some View {
        SettingsView(menuVisible: $menuVisible, showSettings: $showSettings)
            .environmentObject(ThemeManager())
    }
}
