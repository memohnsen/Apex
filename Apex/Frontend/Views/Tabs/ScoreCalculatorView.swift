//
//  ScoreCalculatorView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/23/25.
//

import SwiftUI
import Foundation

struct ScoreCalculatorView: View {
    @Bindable var apexScore: ApexScore
    @State private var navigateToResults: Bool = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView{
                    VStack(alignment: .leading, spacing: 0){
                        CategoryHeader(title: "Speed", icon: "speed")
                        DataEntrySection(event: "Fast Forty", description: "Enter your time between 4.21 - 6 seconds", prompt: "Enter time", value: $apexScore.fortyDash)
                        
                        CategoryHeader(title: "Power", icon: "power")
                        DataEntrySection(event: "Max Toss", description: "Enter your distance between 180 - 900 inches", prompt: "Enter distance", value: $apexScore.maxToss)
                        DataEntrySection(event: "The Vertical", description: "Enter your height between 16 - 45 inches", prompt: "Enter distance", value: $apexScore.verticalJump)
                        DataEntrySection(event: "The Broad", description: "Enter your distance between 72 - 147 inches", prompt: "Enter distance", value: $apexScore.theBroad)
                        
                        CategoryHeader(title: "Strength", icon: "strength")
                        DataEntrySection(event: "The Push", description: "Enter your reps between 5 - 49", prompt: "Enter reps", value: $apexScore.thePush)
                        DataEntrySection(event: "The Pull", description: "Enter your reps between 5 - 30", prompt: "Enter reps", value: $apexScore.thePull)
                        
                        CategoryHeader(title: "Endurance", icon: "endurance")
                        DataEntrySection(event: "The Mile", description: "Enter your time between 4 - 10 minutes as minutes and seconds (5:15)", prompt: "Enter time", value: $apexScore.theMile)
                        
                        NavigationLink(destination: ScoreResultsView(apexScore: apexScore)) {
                            Text("Calculate Apex Score")
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(apexScore.hasCompletedForm ? .blue : .gray)
                        .clipShape(.rect(cornerRadius: 12))
                        .padding()
                        .foregroundStyle(.white)
                        .bold()
                        .disabled(!apexScore.hasCompletedForm)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Apex Score")
            .preferredColorScheme(.dark)
        }
    }
}

struct CategoryHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30)
            Text(title)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
        .padding(.horizontal)
        .padding(.top, 20)
        .padding(.bottom, 12)
    }
}

struct DataEntrySection: View {
    var event: String
    var description: String
    var prompt: String
    @Binding var value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            VStack(alignment: .leading, spacing: 6) {
                Text(event)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(2)
            }
            
            TextField(prompt, text: $value)
                .keyboardType(.decimalPad)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))
        }
        .cardStyling()
    }
}

#Preview {
    ScoreCalculatorView(apexScore: ApexScore())
}
