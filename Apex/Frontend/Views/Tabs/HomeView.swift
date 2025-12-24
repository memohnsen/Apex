//
//  HomeView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/23/25.
//

import SwiftUI

struct UpcomingEvents: Hashable {
    var event_name: String
    var date: String
}

struct HomeView: View {
    @Bindable private var viewModel = ResultsModel()
    var events: [Events] { viewModel.events }
    
    let upcomingEvents: [UpcomingEvents] = [
        UpcomingEvents(event_name: "To Be Announced", date: "2026-01-01")
    ]
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack(alignment: .leading){
                        NavigationLink(destination: RecordsView()) {
                            Text("Records")
                                .font(.title.bold())
                                .foregroundStyle(.white)
                                .cardStyling()
                        }
                        
                        UpcomingEventsView(upcomingEvents: upcomingEvents)
                        
                        CompletedEventsView(events: events)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("Apex")
            .preferredColorScheme(.dark)
            .task {
                await viewModel.fetchEvents()
            }
        }
    }
}

struct UpcomingEventsView: View {
    var upcomingEvents: [UpcomingEvents]
    let apexURL = URL(string: "https://apexathleteofficial.com/")!
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Upcoming Events")
                .bold()
                .font(.title)
                .padding(.horizontal)
            
            ForEach(upcomingEvents, id: \.self) { event in
                let formattedDate = dateFormat(event.date) ?? "N/A"
                
                Link(destination: apexURL) {
                    HStack {
                        Text(event.event_name)
                            .bold()
                            .font(.system(size: 20))
                        
                        Spacer()
                        
                        Text(formattedDate)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                }
                .cardStyling()
            }
        }
        .padding(.bottom)
    }
}

struct CompletedEventsView: View {
    var events: [Events]
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Completed Events")
                .bold()
                .font(.title)
                .padding(.horizontal)
            
            ForEach(events, id: \.self) { event in
                let formattedDate = dateFormat(event.date) ?? "N/A"

                NavigationLink(destination: EventResultsView(events: events)) {
                    HStack {
                        Text(event.event_name)
                            .bold()
                            .font(.system(size: 20))
                        
                        Spacer()
                        
                        Text(formattedDate)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                }
                .cardStyling()
            }
        }
    }
}

#Preview {
    HomeView()
}
