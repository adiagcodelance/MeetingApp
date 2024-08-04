import SwiftUI

struct SettingsView: View {
    @Binding var selectedTheme: Theme?
    @Binding var menuVisible: Bool
    @Binding var showSettings: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showSettings = false // Dismiss the settings overlay
                }
            
            NavigationView {
                List {
                    NavigationLink(destination: ThemesListView(selectedTheme: $selectedTheme, menuVisible: $menuVisible)) {
                        Text("Themes")
                    }
                }
                .navigationTitle("Settings")
            }
            .frame(width: 300, height: 500)
            .background(Color.white)
            .cornerRadius(20)
            .shadow(radius: 20)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @State static var selectedTheme: Theme?
    @State static var menuVisible = false
    @State static var showSettings = true
    
    static var previews: some View {
        SettingsView(selectedTheme: $selectedTheme, menuVisible: $menuVisible, showSettings: $showSettings)
    }
}
