import SwiftUI

extension View {
    func dismissKeyboardOnSwipeDown(perform onDismiss: @escaping () -> Void = {}) -> some View {
        return self.highPriorityGesture(
            DragGesture()
                .onEnded { value in
                    // Detect if the drag gesture is mainly vertical
                    if value.translation.height > 50 && abs(value.translation.width) < 30 {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        onDismiss() // Perform any additional actions on dismiss
                    }
                }
        )
    }
}
