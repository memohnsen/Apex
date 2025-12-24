//
//  LeaderboardView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/23/25.
//

import SwiftUI

struct LeaderboardView: View {
    @Bindable private var viewModel = ResultsModel()
    var results: [ApexResults] { viewModel.results }
    @State private var genderOptions: [String] = ["Men", "Women"]
    @State private var gender: String = "Men"

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
                        
                        LeaderboardSection(results: results)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Apex Leaderboard")
            .preferredColorScheme(.dark)
        }
        .task {
            await viewModel.fetchResults(gender: gender)
        }
        .onChange(of: gender) {
            Task {
                await viewModel.fetchResults(gender: gender)
            }
        }
    }
}

struct LeaderboardSection: View {
    var results: [ApexResults]
    
    var body: some View {
        ForEach(results, id: \.id) { result in
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
    LeaderboardView()
}
