import SwiftUI
import EventKit

struct CalendarMenuView: View {
    @ObservedObject var viewModel = CalendarViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedDate = Date()
    @State private var showAddEventSheet = false
    @State private var showCalendarByMonth = false
    @State private var selectedEvent: EKEvent? = nil
    @State private var relatedNotes: String = ""

    var body: some View {
        NavigationView {
            VStack {
                // Header with navigation buttons
                HStack {
                    Button(action: {
                        withAnimation {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? Date()
                            viewModel.fetchEvents(for: selectedDate)
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .padding()
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    Spacer()
                    
                    Text(selectedDate, style: .date)
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? Date()
                            viewModel.fetchEvents(for: selectedDate)
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .padding()
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                }
                .padding(.horizontal)
                .background(themeManager.currentTheme.backgroundColor)
                
                // Today Button, Add Event Button, and Calendar by Month Button
                HStack {
                    Button(action: {
                        selectedDate = Date()
                        viewModel.fetchEvents(for: selectedDate)
                    }) {
                        Image(systemName: "calendar.day.timeline.leading")
                            .font(.title2)
                            .padding()
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        showAddEventSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding()
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    .sheet(isPresented: $showAddEventSheet) {
                        AddEventView(viewModel: viewModel, selectedDate: $selectedDate)
                    }

                    Spacer()
                    
                    Button(action: {
                        showCalendarByMonth = true
                    }) {
                        CalendarMonthIcon(date: selectedDate)
                            .font(.title2)
                            .padding()
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    .sheet(isPresented: $showCalendarByMonth) {
                        CalendarByMonthView(viewModel: viewModel, selectedDate: $selectedDate, selectedEvent: $selectedEvent, relatedNotes: $relatedNotes)
                    }
                }
                .padding(.horizontal)
                
                // Event List
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(viewModel.events, id: \.eventIdentifier) { event in
                            EventCardView(event: event)
                                .padding(.vertical, 5)
                                .onTapGesture {
                                    selectedEvent = event
                                    relatedNotes = viewModel.getRelatedNotes(for: event)
                                }
                        }
                    }
                    .padding(.horizontal)
                }
                .background(themeManager.currentTheme.backgroundColor)
                .onAppear {
                    viewModel.fetchEvents(for: selectedDate)
                }

                // Divider
                Divider()
                    .background(themeManager.currentTheme.primaryColor)
                    .padding(.vertical, 10)
                
                // Related Notes
                if let selectedEvent = selectedEvent {
                    VStack(alignment: .leading) {
                        Text("Related Notes")
                            .font(.headline)
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                            .padding(.leading)

                        ScrollView {
                            Text(relatedNotes)
                                .padding()
                                .background(themeManager.currentTheme.secondaryColor)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        .background(themeManager.currentTheme.backgroundColor)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Calendar Events")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.top, 20)
                }
            }
            .background(themeManager.currentTheme.backgroundColor.edgesIgnoringSafeArea(.all))
        }
    }
}

struct CalendarMonthIcon: View {
    var date: Date
    private var monthSymbols: [String] {
        DateFormatter().monthSymbols
    }
    
    var body: some View {
        let month = Calendar.current.component(.month, from: date)
        VStack {
            Image(systemName: "calendar")
            Text(monthSymbols[month - 1].prefix(3))
                .font(.caption)
        }
    }
}

struct EventCardView: View {
    var event: EKEvent
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(event.startDate, style: .time)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            .frame(width: 80, alignment: .leading)
            
            VStack(alignment: .leading) {
                Text(event.title ?? "No Title")
                    .font(.subheadline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text(event.startDate, style: .date)
                    .font(.caption)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            Spacer()
        }
        .padding()
        .background(themeManager.currentTheme.secondaryColor)
        .cornerRadius(10)
        .frame(maxWidth: .infinity)
    }
}

struct AddEventView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var title: String = ""
    @Binding var selectedDate: Date
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(3600)
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Event Details")) {
                    TextField("Title", text: $title)
                    DatePicker("Start Date", selection: $startDate)
                    DatePicker("End Date", selection: $endDate)
                }
                Button("Add Event") {
                    viewModel.addEvent(title: title, startDate: startDate, endDate: endDate)
                    presentationMode.wrappedValue.dismiss()
                    viewModel.fetchEvents(for: selectedDate)
                }
            }
            .navigationBarTitle("Add Event", displayMode: .inline)
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct CalendarByMonthView: View {
    @ObservedObject var viewModel: CalendarViewModel
    @EnvironmentObject var themeManager: ThemeManager
    @Binding var selectedDate: Date
    @Binding var selectedEvent: EKEvent?
    @Binding var relatedNotes: String
    @State private var selectedDay: Date? = nil
    @State private var showAddEventSheet = false
    
    private var daysInMonth: [Date] {
        let calendar = Calendar.current
        let range = calendar.range(of: .day, in: .month, for: selectedDate)!
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        return range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    var body: some View {
        VStack {
            // Month navigation buttons
            HStack {
                Button(action: {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) ?? Date()
                        viewModel.fetchEvents(for: selectedDate)
                    }
                }) {
                    Image(systemName: "chevron.left")
                        .padding()
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                
                Spacer()
                
                Text(monthYearFormatter.string(from: selectedDate))
                    .font(.headline)
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        selectedDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) ?? Date()
                        viewModel.fetchEvents(for: selectedDate)
                    }
                }) {
                    Image(systemName: "chevron.right")
                        .padding()
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            .padding(.horizontal)
            .background(themeManager.currentTheme.backgroundColor)
            
            // Calendar Grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 7), spacing: 5) {
                ForEach(daysInMonth, id: \.self) { day in
                    Text("\(Calendar.current.component(.day, from: day))")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(8)
                        .background(day == selectedDay ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.backgroundColor)
                        .foregroundColor(day == selectedDay ? .white : themeManager.currentTheme.primaryColor)
                        .cornerRadius(5)
                        .overlay(
                            Rectangle()
                                .stroke(themeManager.currentTheme.primaryColor, lineWidth: 0.5)
                        )
                        .onTapGesture {
                            selectedDay = day
                            viewModel.fetchEvents(for: day)
                        }
                }
            }
            .padding(.horizontal)
            
            // Divider
            Divider()
                .background(themeManager.currentTheme.primaryColor)
                .padding(.vertical, 10)
            
            // New Event Button
            HStack {
                Spacer()
                
                Button(action: {
                    showAddEventSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding()
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                .sheet(isPresented: $showAddEventSheet) {
                    AddEventView(viewModel: viewModel, selectedDate: $selectedDate)
                }
                
                Spacer()
            }
            .padding(.horizontal)
            
            // Event List for Selected Day
            if let selectedDay = selectedDay {
                VStack(alignment: .leading) {
                    Text("Events")
                        .font(.headline)
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                        .padding(.leading)
                    
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.events, id: \.eventIdentifier) { event in
                                EventCardView(event: event)
                                    .padding(.vertical, 5)
                                    .onTapGesture {
                                        selectedEvent = event
                                        relatedNotes = viewModel.getRelatedNotes(for: event)
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .background(themeManager.currentTheme.backgroundColor)
                    
                    // Divider
                    Divider()
                        .background(themeManager.currentTheme.primaryColor)
                        .padding(.vertical, 10)
                    
                    // Related Notes
                    if let selectedEvent = selectedEvent {
                        VStack(alignment: .leading) {
                            Text("Related Notes")
                                .font(.headline)
                                .foregroundColor(themeManager.currentTheme.primaryColor)
                                .padding(.leading)
                            
                            ScrollView {
                                Text(relatedNotes)
                                    .padding()
                                    .background(themeManager.currentTheme.secondaryColor)
                                    .cornerRadius(10)
                                    .padding(.horizontal)
                            }
                            .background(themeManager.currentTheme.backgroundColor)
                        }
                    }
                }
            }
        }
        .background(themeManager.currentTheme.backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear {
            viewModel.fetchEvents(for: selectedDate)
        }
    }
    
    private var monthYearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }
}

struct CalendarMenuView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarMenuView()
            .environmentObject(ThemeManager())
    }
}
