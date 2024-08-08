import SwiftUI
import EventKit

class CalendarViewModel: ObservableObject {
    @Published var events: [EKEvent] = []
    private let eventStore = EKEventStore()

    func fetchEvents(for date: Date) {
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: date)
        let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        events = eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
    }

    func addEvent(title: String, startDate: Date, endDate: Date) {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        do {
            try eventStore.save(event, span: .thisEvent)
            fetchEvents(for: startDate)
        } catch {
            print("Error saving event: \(error)")
        }
    }

    func getRelatedNotes(for event: EKEvent) -> String {
        // Replace this with actual logic to fetch related notes
        // Here, we're just returning a placeholder
        return "Related notes for event: \(event.title ?? "No title")"
    }
}
