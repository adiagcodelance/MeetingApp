//
//  SideMenuView.swift
//  MeetingApp
//
//  Created by Aditya Agrawal on 2024-08-02.
//

import SwiftUI

struct SideMenuView: View {
    var body: some View {
        VStack(alignment: .leading) {
            List {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Content")/*@END_MENU_TOKEN@*/
            }
        }
        .frame(maxWidth: 300) // Adjust width of the side menu
        .background(Color.gray.opacity(0.9))
        .offset(x: 0) // Start with menu hidden
    }
}

#Preview {
    SideMenuView()
}
