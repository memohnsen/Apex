//
//  EventResultsView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import SwiftUI

struct EventResultsView: View {
    @Bindable private var viewModel = ResultsModel()
    var eventResults: [ApexResults] { viewModel.eventResults }
    @State private var genderOptions: [String] = ["Men", "Women"]
    @State private var gender: String = "Men"
    
    var events: [Events]

    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView {
                    VStack{
                        Picker("\(gender)", selection: $gender) {
                            ForEach(genderOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        ResultsSection(eventResults: eventResults)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle(events.first?.event_name ?? "Apex Leaderboard")
            .preferredColorScheme(.dark)
        }
        .task {
            await viewModel.fetchResultsByEvent(gender: gender, event: events.first?.event_name ?? "")
        }
        .onChange(of: gender) {
            Task {
                await viewModel.fetchResultsByEvent(gender: gender, event: events.first?.event_name ?? "")
            }
        }
    }
}

struct ResultsSection: View {
    var eventResults: [ApexResults]
    
    var body: some View {
        ForEach(eventResults, id: \.id) { result in
            NavigationLink(destination: AthleteDetailsView(eventResults: [result])) {
                HStack {
                    HStack{
                        Text("\(result.athlete_rank)")
                            .bold()
                            .font(.title)
                            .padding(.trailing)
                            .foregroundStyle(podiumColors(result.athlete_rank))
                    }
                    Spacer()
                    
                    VStack {
                        Text(result.athlete_name)
                            .font(.system(size: 24))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.white)
                        Text(dateFormat(result.date) ?? "N/A")
                            .foregroundStyle(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("\(result.apex_score)")
                            .bold()
                            .font(.title)
                            .padding(.leading)
                            .foregroundStyle(colorForRank(category(result.apex_score)))
                    }
                }
                .cardStyling()
            }
        }
    }
}

#Preview {
    EventResultsView(events: [Events(event_name: "Austin 2025", date: "2025-10-26")])
}
