import SwiftUI
import EventKit

class CalendarViewModel: ObservableObject {
    @Published var events: [EKEvent] = []
    private let eventStore = EKEventStore()

    func fetchEvents(for date: Date) {
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let startDate = calendar.startOfDay(for: date)
            let endDate = calendar.date(byAdding: .day, value: 1, to: startDate)!

            let predicate = self.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
            let fetchedEvents = self.eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }
            
            DispatchQueue.main.async {
                self.events = fetchedEvents
            }
        }
    }

    func addEvent(title: String, startDate: Date, endDate: Date) {
        DispatchQueue.global(qos: .userInitiated).async {
            let event = EKEvent(eventStore: self.eventStore)
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = self.eventStore.defaultCalendarForNewEvents
            do {
                try self.eventStore.save(event, span: .thisEvent)
                
                // Fetch events again to update the list
                self.fetchEvents(for: startDate)
            } catch {
                print("Error saving event: \(error)")
            }
        }
    }

    func getRelatedNotes(for event: EKEvent) -> String {
        // Replace this with actual logic to fetch related notes
        // Here, we're just returning a placeholder
        return "Related notes for event: \(event.title ?? "No title")"
    }
}
