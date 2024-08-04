//
//  SetupFormView.swift
//  MeetingApp
//
//  Created by Aditya Agrawal on 2024-08-02.
//

import SwiftUI

struct SetupFormView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var tempalteOptionSelected : String = "Select Template"
    let options = ["Select Template", "Basic", "Custom"]
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 10) {
                Spacer()
                
                Text("Pick Your Preferred Template Style")
                    .font(.largeTitle)
                    .padding(.bottom, 20)
                    .frame(alignment: .top)
                
                Picker("Select an option", selection: $tempalteOptionSelected){
                    ForEach(options, id: \.self){
                        option in Text(option).tag(option)
                    }
                    .foregroundColor(Color.black)
                }
                // Your form fields go here
                TextField("Enter your name", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Enter your email", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .padding()
            
            VStack {
                HStack {
                    Button(action: {
                        // Dismiss the current view and go back to SetupView
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left.circle.fill")
                            .font(.system(size: 50)) // Adjust size
                            .foregroundColor(.black) // Customize color
                            .frame(width: 50, height: 50)
                            .padding(0)
                            .background(Color.white) // Background color
                            .clipShape(Circle()) // Make background circular
                            .shadow(radius: 10)
                    }
                    .padding() // Padding to move to the top-left corner
                    Spacer()
                }
                Spacer() // Push the HStack to the bottom
                
                HStack {
                    Spacer() // Push the button to the right
                    Button(action: {
                        // Perform the desired action for this button
                    }) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 50)) // Adjust size
                            .foregroundColor(.black) // Customize color
                            .frame(width: 50, height: 50)
                            .padding(0)
                            .background(Color.white) // Background color
                            .clipShape(Circle()) // Make background circular
                            .shadow(radius: 10)
                    }
                    .padding() // Padding to position it in the bottom-right corner
                }
            }
            .padding()
        }
    }
}

#Preview {
    SetupFormView()
}
