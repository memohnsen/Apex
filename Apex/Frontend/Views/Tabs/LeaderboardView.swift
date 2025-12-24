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
                        
                        ForEach(results, id: \.id) { result in
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
    
    func dateFormat(_ eventDate: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "y-MM-dd"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: eventDate) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM d, y"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let formattedDate = outputFormatter.string(from: date)
        
        return formattedDate
    }
    
    func convert24hourTo12hour(time24hour: String) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        guard let date = inputFormatter.date(from: time24hour) else {
            return nil
        }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "h:mm a"
        outputFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let time12hour = outputFormatter.string(from: date)
        
        return time12hour
    }
}

#Preview {
    LeaderboardView()
}
