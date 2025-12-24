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
                LinearGradient(colors: [
                    Color(red: 2/255, green: 17/255, blue: 27/255),
                    Color(red: 48/255, green: 41/255, blue: 47/255)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                
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
                    Text(dateFormat(result.date) ?? "N/A")
                        .foregroundStyle(.secondary)
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
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 48/255, green: 41/255, blue: 47/255).opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
            .padding(.horizontal)
            .padding(.bottom, 12)
        }
    }
}

#Preview {
    EventResultsView(events: [Events(event_name: "Austin 2025", date: "2025-10-26")])
}
