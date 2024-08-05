import SwiftUI

@main
struct MeetingAppApp: App {
    @StateObject private var itemStore = ItemStore()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            HomeListView()
                .environmentObject(itemStore)
                .environmentObject(themeManager)
        }
    }
}
import SwiftUI

struct ContentViewWrapper: View {
    @State private var showSplash = true
    
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
