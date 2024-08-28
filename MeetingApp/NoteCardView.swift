import SwiftUI
import EventKit

struct NoteCardView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var noteName: String
    @Binding var noteContent: String
    var createdDate: Date
    var onDelete: () -> Void
    @Binding var isEditing: Bool
    @State private var isEditingName: Bool = false
    @State private var dynamicHeight: CGFloat = 100
    @State private var showAddEventSheet = false

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                TextField("Untitled", text: $noteName)
                    .font(.headline)
                    .padding(.bottom, 2)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .background(isEditingName ? Color.white : Color.clear)
                    .disabled(!isEditingName)
                    .onTapGesture {
                        // No action needed here, editing is controlled by the menu
                    }

                Spacer()
                
                Button(action: {
                    showAddEventSheet = true
                }) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.headline)
                        .padding()
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .sheet(isPresented: $showAddEventSheet) {
                    AddEventFromNoteView(noteTitle: noteName, noteContent: noteContent)
                }
                
                Menu {
                    Button(action: {
                        withAnimation {
                            isEditingName = true
                        }
                    }) {
                        Label("Rename", systemImage: "pencil")
                    }
                    Button(action: onDelete) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.headline)
                        .padding()
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }

            Text("Created on: \(createdDate, formatter: DateFormatter.dateTime)")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 5)
            
            ZStack(alignment: .topLeading) {
                if noteContent.isEmpty {
                    Text("Enter your note content here...")
                        .foregroundColor(themeManager.currentTheme.secondaryColor.opacity(0.5)) // Placeholder color
                        .padding(.leading, 12)
                        .padding(.top, 10)
                }

                TextEditor(text: $noteContent)
                    .font(.body)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(8)
                    //.background(themeManager.currentTheme.noteCardBackgroundColor)
                    .cornerRadius(10)
                    .frame(minHeight: dynamicHeight)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ViewHeightKey.self, value: geometry.size.height)
                        }
                    )
                    .onPreferenceChange(ViewHeightKey.self) { height in
                        dynamicHeight = height
                    }
                    .scrollContentBackground(.hidden)
                    .disabled(!isEditing)
                    .onTapGesture {
                        withAnimation {
                            isEditing = true
                        }
                    }
            }
        }
        .padding()
        //.background(themeManager.currentTheme.noteCardBackgroundColor)
        .cornerRadius(8)
        //.overlay(
           // RoundedRectangle(cornerRadius: 8)
              //  .stroke(themeManager.currentTheme.borderColor, lineWidth: 1)
        //)
        .shadow(color: themeManager.currentTheme.shadowColor, radius: 10, x: 0, y: 5) // Apply soft shadow
        .gesture(DragGesture()
                    .onChanged { _ in
                        withAnimation {
                            isEditing = false
                            isEditingName = false
                        }
                    }
        )
    }
}

//Below this comment we want to possible add keyboard related features that we can sepcifically assign to the note such as formatting, etc. one main feature is to relate the text this indicator is placed next to to become a todo using that line as todo data of sorts.


struct AddEventFromNoteView: View {
    var noteTitle: String
    var noteContent: String
    @Environment(\.presentationMode) var presentationMode
    @State private var eventTitle: String = ""
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    private let eventStore = EKEventStore()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Event Title", text: $eventTitle)
                    DatePicker("Start Date", selection: $startDate)
                    DatePicker("End Date", selection: $endDate)
                }
                Button("Add Event") {
                    addEvent()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationBarTitle("Create Event", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
            .onAppear {
                eventTitle = noteTitle
            }
        }
    }

    private func addEvent() {
        let event = EKEvent(eventStore: eventStore)
        event.title = eventTitle.isEmpty ? noteTitle : eventTitle
        event.startDate = startDate
        event.endDate = endDate
        event.notes = noteContent
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            print("Error saving event: \(error.localizedDescription)")
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 100
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension DateFormatter {
    static var dateTime: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }
}

struct NoteCardView_Previews: PreviewProvider {
    @State static var sampleNoteName = "Untitled"
    @State static var sampleNoteContent = "Enter note content..."
    @State static var isEditing = false
    static var sampleCreatedDate = Date()

    static var previews: some View {
        NoteCardView(
            noteName: $sampleNoteName,
            noteContent: $sampleNoteContent,
            createdDate: sampleCreatedDate,
            onDelete: {},
            isEditing: $isEditing
        )
        .environmentObject(ThemeManager())
    }
}
