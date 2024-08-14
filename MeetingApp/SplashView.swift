//
//  SwiftUIView.swift
//  MeetingApp
//
//  Created by Aditya Agrawal on 2024-08-01.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack{
            Color.white
                .ignoresSafeArea() // This ensures the color fills the entire screen

            VStack{
                Text("Event Notes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(50)
            }
            .background(Color.white)
            .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        }
    }
}

struct SplashView_Previews: PreviewProvider{
    static var previews: some View{
        SplashView()
    }
}
