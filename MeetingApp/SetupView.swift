//
//  SetupView.swift
//  MeetingApp
//
//  Created by Aditya Agrawal on 2024-08-02.
//

import SwiftUI

struct SetupView: View {
    var body: some View {
        VStack (alignment: .center, spacing: 10) {
            Text("Welcome to Meeting Prototype!")
                .bold()
                .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
                .frame(alignment: .top)
                .padding()
            Text("Lets Start By Getting You Setup!")
                .padding()
            VStack(alignment: .center, spacing: 10){
                Button(action: arrowButtonTapped) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 70)) // Adjust size
                        .foregroundColor(.black) // Customize color
                        .frame(width: 70, height: 70)
                        .padding(0)
                        .background(Color.white) // Background color
                        .clipShape(Circle()) // Make background circular
                        .shadow(radius: 10)
                }
                .padding()
            }
        }
    }
    func arrowButtonTapped(){
        print("Button Pressed")
    }
}

#Preview {
    SetupView()
}
