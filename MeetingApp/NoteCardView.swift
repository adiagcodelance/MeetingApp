import SwiftUI

struct NoteCardView: View {
    let noteID: UUID
    @Binding var noteName: String
    @Binding var noteContent: String
    @Binding var imageData: Data?
    @Binding var imageName: String
    let createdDate: Date
    let onDelete: () -> Void
    @Binding var isEditing: Bool
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var activeNoteID: UUID?

    @State private var showImagePicker = false
    @State private var showCamera = false
    @State private var showFullImage = false
    @State private var showActionSheet = false
    @FocusState private var isFocused: Bool // Use FocusState to track focus

    var onSave: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if isEditing {
                TextField("Note Title", text: $noteName)
                    .font(.largeTitle)
                    .padding(.bottom, 2)
                    .textFieldStyle(PlainTextFieldStyle())
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
                    .background(themeManager.currentTheme.backgroundColor)
            } else {
                Text(noteName)
                    .font(.largeTitle)
                    .padding(.bottom, 2)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 10)
            }

            ZStack(alignment: .leading) {
                if noteContent.isEmpty && !isFocused {
                    Text("Enter note content...")
                        .foregroundColor(themeManager.currentTheme.secondaryColor.opacity(0.5))
                        .padding(.vertical, 5)
                }
                TextEditor(text: $noteContent)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .background(themeManager.currentTheme.backgroundColor)
                    .frame(minHeight: 50)
                    .padding(.vertical, 5)
                    .opacity(noteContent.isEmpty && !isFocused ? 0.25 : 1)
                    .focused($isFocused) // Track focus state
                    .toolbar {
                        if activeNoteID == noteID {
                            ToolbarItem(placement: .keyboard) {
                                Button(action: {
                                    showActionSheet = true
                                }) {
                                    Image(systemName: "camera")
                                        .font(.title2)
                                        .padding()
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                }
                                .actionSheet(isPresented: $showActionSheet) {
                                    ActionSheet(title: Text("Choose an option"), buttons: [
                                        .default(Text("Select from Library")) {
                                            showImagePicker = true
                                        },
                                        .default(Text("Take a Picture")) {
                                            showCamera = true
                                        },
                                        .cancel()
                                    ])
                                }
                            }
                        }
                    }
            }

            // Display the thumbnail and image name with delete button on top right
            if let uiImage = loadImage() {
                HStack {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                            .onTapGesture {
                                showFullImage = true
                            }

                        Button(action: {
                            imageData = nil
                            imageName = ""
                            onSave()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 14))
                                .foregroundColor(.red)
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .offset(x: 6, y: -6)
                    }

                    if isEditing {
                        TextField("Image Name", text: $imageName)
                            .font(.subheadline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    } else {
                        Text(imageName)
                            .font(.subheadline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                .padding(.vertical, 5)
            }

            HStack {
                Text("Created on \(createdDate, formatter: dateFormatter)")
                    .font(.footnote)
                    .foregroundColor(themeManager.currentTheme.secondaryColor)
                Spacer()
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(themeManager.currentTheme.backgroundColor)
        .cornerRadius(10)
        .shadow(color: themeManager.currentTheme.shadowColor, radius: isEditing ? 5 : 0)
        .onTapGesture {
            isEditing = true
            activeNoteID = noteID
        }
        .sheet(isPresented: $showImagePicker, onDismiss: {
            onSave()
        }) {
            ImagePicker(imageData: $imageData)
        }
        .fullScreenCover(isPresented: $showFullImage) {
            FullImageView(image: loadImage()!, onClose: { showFullImage = false })
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraView(imageData: $imageData, onSave: onSave)
        }
        .onChange(of: isFocused) { newValue in
            if !newValue && noteContent.isEmpty {
                isFocused = false
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }

    private func loadImage() -> UIImage? {
        if let imageData = imageData {
            return UIImage(data: imageData)
        }
        return nil
    }
}
