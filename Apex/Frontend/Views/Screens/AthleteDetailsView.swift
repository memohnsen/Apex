//
//  AthleteDetailsView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import SwiftUI

struct AthleteDetailsView: View {
    @Bindable var apexScore: ApexScore = ApexScore()
    @Bindable private var viewModel = ResultsModel()
    var specificAthlete: [ApexResults] { viewModel.specificAthlete }
    
    var athlete: Athletes
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    private func ordinalSuffix(for number: Int) -> String {
        let ones = number % 10
        let tens = (number % 100) / 10
        
        if tens == 1 {
            return "\(number)th"
        }
        
        switch ones {
        case 1:
            return "\(number)st"
        case 2:
            return "\(number)nd"
        case 3:
            return "\(number)rd"
        default:
            return "\(number)th"
        }
    }
    
    private func updateScores() {
        guard let firstResult = specificAthlete.first else { return }
        apexScore.fortyDash = firstResult.fast_forty
        apexScore.maxToss = firstResult.max_toss
        apexScore.theBroad = firstResult.the_broad
        apexScore.verticalJump = firstResult.the_vertical
        apexScore.thePull = String(firstResult.the_pull)
        apexScore.thePush = String(firstResult.the_push)
        apexScore.theMile = firstResult.the_mile
    }
    
    private func plurality(_ count: Int) -> String {
        if count == 1 {
            return ""
        } else {
            return "s"
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView {
                    VStack{
                        VStack {
                            Text("APEX SCORE: \(specificAthlete.first?.apex_score ?? 0)")
                                .font(.title.bold())
                            
                            Text(specificAthlete.first?.event_name ?? "N/A")
                                .italic()
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            
                            Rectangle()
                                .fill(.white.opacity(0.5))
                                .frame(height: 1)
                            
                            HStack {
                                Text("Placing: \(ordinalSuffix(for: specificAthlete.first?.athlete_rank ?? 0))")
                                Spacer()
                                Text("Gender: \(specificAthlete.first?.gender ?? "N/A")")
                            }
                            .font(.headline)
                            
                            if let handle = specificAthlete.first?.instagram_handle,
                               let url = URL(string: "https://instagram.com/\(handle)") {
                                
                                Rectangle()
                                    .fill(.white.opacity(0.5))
                                    .frame(height: 1)
                                
                                Link(handle, destination: url)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 18))
                                    .bold()
                                    .foregroundStyle(.white)
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
                        
                        HStack {
                            Text("Category Scores")
                                .font(.title.bold())
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: columns) {
                            ScoreBySectionGrid(title: "Speed", score: specificAthlete.first?.speed_score ?? 0, icon: "speed")
                            ScoreBySectionGrid(title: "Power", score: specificAthlete.first?.power_score ?? 0, icon: "power")
                            ScoreBySectionGrid(title: "Strength", score: specificAthlete.first?.strength_score ?? 0, icon: "strength")
                            ScoreBySectionGrid(title: "Endurance", score: specificAthlete.first?.endurance_score ?? 0, icon: "endurance")
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("Event Scores")
                                .font(.title.bold())
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        ScoreByEvent(title: "Fast Forty", score: apexScore.speedScore, icon: "speed", result: specificAthlete.first?.fast_forty ?? "N/A", max: "4.21", min: "6.00")
                        ScoreByEvent(title: "Max Toss", score: apexScore.tossScore, icon: "power", result: specificAthlete.first?.max_toss ?? "N/A", max: "75'0\"", min: "37'6\"")
                        ScoreByEvent(title: "The Vertical", score: apexScore.verticalScore, icon: "power", result: specificAthlete.first?.the_vertical ?? "N/A", max: "45\"", min: "16\"")
                        ScoreByEvent(title: "The Broad", score: apexScore.broadScore, icon: "power", result: specificAthlete.first?.the_broad ?? "N/A", max: "11'6\"", min: "6'0\"")
                        ScoreByEvent(title: "The Push", score: apexScore.pushScore, icon: "strength", result: specificAthlete.first?.the_push ?? 0, max: "40", min: "5")
                        ScoreByEvent(title: "The Pull", score: apexScore.pullScore, icon: "strength", result: specificAthlete.first?.the_pull ?? 0, max: "40", min: "5")
                        ScoreByEvent(title: "The Mile", score: apexScore.enduranceScore, icon: "endurance", result: specificAthlete.first?.the_mile ?? "N/A", max: "4:00", min: "10:00")
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle(athlete.athlete_name)
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .task {
                await viewModel.fetchSpecificAthlete(name: athlete.athlete_name)
                updateScores()
            }
        }
    }
}

struct ScoreBySectionGrid: View {
    var title: String
    var score: Int
    var icon: String
    
    var body: some View {
        VStack{
            HStack {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("\(score)/250")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)
            }
            
            CustomProgressBar(
                value: score,
                total: 250,
                fillColor: colorForSection(title)
            )
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
        .padding(.bottom, 12)
    }
}

struct ScoreByEvent: View {
    var title: String
    var score: Int
    var icon: String
    var result: Any
    var max: String
    var min: String
    
    private var maxScore: Int {
        switch title {
        case "The Push", "The Pull":
            return 125
        case "Max Toss", "The Vertical", "The Broad":
            return 83
        default:
            return 250
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12){
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("\(title): \(result)")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.bottom, 6)
            
            CustomProgressBar(value: score, total: maxScore, fillColor: colorForSection(title))
            
            HStack{
                Text("Min \(min)")
                Spacer()
                Text("Max \(max)")
            }
            .foregroundStyle(.secondary)
        }
        .cardStyling()
    }
}

#Preview {
    AthleteDetailsView(athlete: Athletes(id: 1, athlete_name: "Justin Zimmer"))
}
