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
    var isLoading: Bool { viewModel.isLoading }
    
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
                        
                        CompletedEventsView(events: events, isLoading: isLoading)
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
    var isLoading: Bool
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading){
            Text("Completed Events")
                .bold()
                .font(.title)
                .padding(.horizontal)
            
            if isLoading {
                ForEach(0..<3, id: \.self) { number in
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                            .frame(width: 150, height: 20)
                        
                        Spacer()
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(isAnimating ? 0.2 : 0.05))
                            .frame(width: 80, height: 16)
                    }
                    .padding(.horizontal)
                }
                .cardStyling()
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        isAnimating = true
                    }
                }
            } else {
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
}

#Preview {
    HomeView()
}
