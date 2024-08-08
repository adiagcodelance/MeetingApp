import SwiftUI

struct IconPickerView: View {
    @Binding var selectedIconColor: String
    @Binding var showIconPicker: Bool
    @EnvironmentObject var themeManager: ThemeManager
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    let icon = "folder" // Same icon for all colors
    
    var body: some View {
        ZStack {
            // Background overlay to dim the main view
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showIconPicker = false // Dismiss the icon picker overlay
                }

            // Main icon picker view
            VStack {
                Text("Select an Icon Color")
                    .font(.headline)
                    .padding()
                    .foregroundColor(themeManager.currentTheme.primaryColor) // Apply theme color
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 20) {
                    ForEach(colors, id: \.self) { color in
                        Image(systemName: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .padding()
                            .foregroundColor(color.opacity(0.8))
                            .cornerRadius(10)
                            .onTapGesture {
                                selectedIconColor = color.description
                                showIconPicker = false
                            }
                    }
                }
                .padding()
            }
            .frame(width: 300, height: 500) // Match the frame size with SettingsView
            .background(themeManager.currentTheme.backgroundColor)
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding()
        }
    }
}

struct IconPickerView_Previews: PreviewProvider {
    @State static var selectedIconColor: String = Color.red.description // Initialize with a default color
    @State static var showIconPicker = true

    static var previews: some View {
        IconPickerView(selectedIconColor: $selectedIconColor, showIconPicker: $showIconPicker)
            .environmentObject(ThemeManager())
    }
}
