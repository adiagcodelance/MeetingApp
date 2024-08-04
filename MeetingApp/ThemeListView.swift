import SwiftUI

struct ThemesListView: View {
    @Binding var selectedTheme: Theme?
    @Binding var menuVisible: Bool
    
    @EnvironmentObject var itemStore: ItemStore
    
    var body: some View {
        List {
            ForEach(itemStore.themes) { theme in
                Text(theme.name)
                    .onTapGesture {
                        selectedTheme = theme
                        menuVisible = false
                    }
                    .padding()
                    .background(selectedTheme?.id == theme.id ? Color.purple.opacity(0.2) : Color.clear)
                    .cornerRadius(8)
            }
        }
        .navigationTitle("Themes")
    }
}

struct ThemesListView_Previews: PreviewProvider {
    @State static var selectedTheme: Theme?
    @State static var menuVisible = false
    
    static var previews: some View {
        ThemesListView(selectedTheme: $selectedTheme, menuVisible: $menuVisible)
            .environmentObject(ItemStore())
    }
}
