import SwiftUI

struct CameraButtonToolbar: View {
    var onCameraButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: onCameraButtonTapped) {
                Image(systemName: "camera")
                    .font(.system(size: 10))
            }
            .accessibilityLabel("Take a picture")
            Spacer()
        }
        .frame(height: 20)
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
        .padding()
    }
}
