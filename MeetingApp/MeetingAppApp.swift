import SwiftUI

@main
struct MeetingAppApp: App {
    @StateObject private var itemStore = ItemStore()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
                .environmentObject(itemStore)
                .environmentObject(themeManager)
                .onAppear(perform: updateAppIcon)
        }
    }
    
    private func updateAppIcon() {
        let iconName = (UITraitCollection.current.userInterfaceStyle == .dark) ? "AppIcon-Dark" : "AppIcon-Light"
        if UIApplication.shared.alternateIconName != iconName {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    print("Failed to set alternate app icon: \(error.localizedDescription)")
                } else {
                    print("App icon changed to \(iconName)")
                }
            }
        }
    }
}

struct ContentViewWrapper: View {
    @State private var showSplash = true
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                HomeListView()
                    .onAppear {
                        updateAppIcon(newColorScheme: colorScheme)
                    }
                    .onChange(of: colorScheme) { newColorScheme in
                        updateAppIcon(newColorScheme: newColorScheme)
                    }
            }
        }
    }
    
    private func updateAppIcon(newColorScheme: ColorScheme) {
        let iconName = (newColorScheme == .dark) ? "AppIcon-Dark" : "AppIcon-Light"
        if UIApplication.shared.alternateIconName != iconName {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    print("Failed to set alternate app icon: \(error.localizedDescription)")
                } else {
                    print("App icon changed to \(iconName)")
                }
            }
        }
    }
}

struct ContentViewWrapper_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewWrapper()
            .environmentObject(ItemStore())
            .environmentObject(ThemeManager())
    }
}
