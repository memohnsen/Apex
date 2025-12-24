//
//  AthleteDetailsView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import SwiftUI

struct AthleteDetailsView: View {
    var athlete: Athletes
    
    var body: some View {
        NavigationStack{
            ZStack{
                LinearGradient(colors: [
                    Color(red: 2/255, green: 17/255, blue: 27/255),
                    Color(red: 48/255, green: 41/255, blue: 47/255)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                
                ScrollView {
                    VStack{
                        
                    }
                }
            }
            .navigationTitle(athlete.athlete_name)
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}

#Preview {
    AthleteDetailsView(athlete: Athletes(id: 1, athlete_name: "Justin Zimmer"))
}
