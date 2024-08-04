//
//  MeetingAppApp.swift
//  MeetingApp
//
//  Created by Aditya Agrawal on 2024-08-01.
//

import SwiftUI

@main
struct MeetingAppApp: App {
    @StateObject private var itemStore = ItemStore() // Initialize ItemStore here

    var body: some Scene {
        WindowGroup {
            ContentViewWrapper()
                .environmentObject(itemStore) // Provide ItemStore to the entire app
        }
    }
}

struct ContentViewWrapper: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                HomeListView()
            }
        }
    }
}

