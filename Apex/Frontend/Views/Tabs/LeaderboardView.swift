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
    var isLoading: Bool { viewModel.isLoading }
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
                        
                        LeaderboardSection(results: results, isLoading: isLoading)
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
    var isLoading: Bool
    @State private var isAnimating: Bool = false
    
    var body: some View {
        if isLoading {
            ForEach(0..<10, id: \.self) { number in
                HStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                        .frame(width: 40, height: 20)
                    
                    Spacer()
                    
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
                                .foregroundStyle(colorForRank(category(result.apex_score)).opacity(0.9))
                        }
                        
                    }
                    .cardStyling()
                }
            }
        }
    }
}

#Preview {
    LeaderboardView()
}
