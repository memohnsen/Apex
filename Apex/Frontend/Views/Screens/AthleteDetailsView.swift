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
    @State private var isAnimating = false
    
    var athlete: Athletes?
    var eventResults: [ApexResults]?
    
    private var displayResults: [ApexResults] {
        if let eventResults = eventResults {
            return eventResults
        }
        return viewModel.specificAthlete
    }
    
    private var isLoading: Bool {
        eventResults == nil && viewModel.specificAthlete.isEmpty && viewModel.isLoading
    }
    
    let columns = [
        GridItem(.adaptive(minimum: 150))
    ]
    
    private func updateScores() {
        guard let firstResult = displayResults.first else { return }
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
                
                if isLoading {
                    ScrollView {
                        VStack{
                            LoadingHeaderSkeleton(isAnimating: $isAnimating)
                            
                            HStack {
                                Text("Category Scores")
                                    .font(.title.bold())
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: columns) {
                                ForEach(0..<4, id: \.self) { _ in
                                    LoadingCategorySkeleton(isAnimating: $isAnimating)
                                }
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Event Scores")
                                    .font(.title.bold())
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ForEach(0..<7, id: \.self) { _ in
                                LoadingEventSkeleton(isAnimating: $isAnimating)
                            }
                        }
                        .padding(.bottom)
                    }
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                            isAnimating = true
                        }
                    }
                } else {
                    ScrollView {
                        VStack{
                            HeaderSection(specificAthlete: displayResults)
                            
                            HStack {
                                Text("Category Scores")
                                    .font(.title.bold())
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            LazyVGrid(columns: columns) {
                                ScoreBySectionGrid(title: "Speed", score: min(displayResults.first?.speed_score ?? 0, 250), icon: "speed")
                                ScoreBySectionGrid(title: "Power", score: min(displayResults.first?.power_score ?? 0, 250), icon: "power")
                                ScoreBySectionGrid(title: "Strength", score: min(displayResults.first?.strength_score ?? 0, 250), icon: "strength")
                                ScoreBySectionGrid(title: "Endurance", score: min(displayResults.first?.endurance_score ?? 0, 250), icon: "endurance")
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Text("Event Scores")
                                    .font(.title.bold())
                                Spacer()
                            }
                            .padding(.horizontal)
                            
                            ScoreByEvent(title: "Fast Forty", score: apexScore.speedScore, icon: "speed", result: displayResults.first?.fast_forty ?? "N/A", max: "4.30", min: "5.40")
                            ScoreByEvent(title: "Max Toss", score: apexScore.tossScore, icon: "power", result: displayResults.first?.max_toss ?? "N/A", max: "75'0\"", min: "37'6\"")
                            ScoreByEvent(title: "The Vertical", score: apexScore.verticalScore, icon: "power", result: displayResults.first?.the_vertical ?? "N/A", max: "45\"", min: "15\"")
                            ScoreByEvent(title: "The Broad", score: apexScore.broadScore, icon: "power", result: displayResults.first?.the_broad ?? "N/A", max: "11'6\"", min: "6'0\"")
                            ScoreByEvent(title: "The Push", score: apexScore.pushScore, icon: "strength", result: displayResults.first?.the_push ?? 0, max: "40", min: "4")
                            ScoreByEvent(title: "The Pull", score: apexScore.pullScore, icon: "strength", result: displayResults.first?.the_pull ?? 0, max: "40", min: "4")
                            ScoreByEvent(title: "The Mile", score: apexScore.enduranceScore, icon: "endurance", result: displayResults.first?.the_mile ?? "N/A", max: "4:30", min: "10:06")
                        }
                        .padding(.bottom)
                    }
                }
            }
            .navigationTitle(athlete?.athlete_name ?? displayResults.first?.athlete_name ?? "N/A")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .task {
                if eventResults == nil, let athleteName = athlete?.athlete_name {
                    await viewModel.fetchSpecificAthlete(name: athleteName)
                }
                updateScores()
            }
        }
    }
}

struct HeaderSection: View {
    var specificAthlete: [ApexResults]
    
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
    
    var body: some View {
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

// MARK: - Loading Skeletons

struct LoadingHeaderSkeleton: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                .frame(height: 32)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(isAnimating ? 0.2 : 0.05))
                .frame(height: 20)
            
            Rectangle()
                .fill(.white.opacity(0.5))
                .frame(height: 1)
            
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.25 : 0.08))
                    .frame(width: 100, height: 18)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.25 : 0.08))
                    .frame(width: 80, height: 18)
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

struct LoadingCategorySkeleton: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 30, height: 30)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 80, height: 24)
            }
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(isAnimating ? 0.2 : 0.05))
                .frame(height: 8)
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

struct LoadingEventSkeleton: View {
    @Binding var isAnimating: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 30, height: 30)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                    .frame(width: 150, height: 24)
            }
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white.opacity(isAnimating ? 0.2 : 0.05))
                .frame(height: 8)
            
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.15 : 0.03))
                    .frame(width: 60, height: 14)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(isAnimating ? 0.15 : 0.03))
                    .frame(width: 60, height: 14)
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

#Preview {
    AthleteDetailsView(athlete: Athletes(id: 1, athlete_name: "Justin Zimmer"))
}
