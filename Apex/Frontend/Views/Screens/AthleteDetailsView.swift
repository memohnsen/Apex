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
                BackgroundColor()
                
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
