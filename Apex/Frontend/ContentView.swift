//
//  ContentView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/23/25.
//

import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    @State private var selectedTab: String = ""
    @State private var apexScore = ApexScore()
    
    var body: some View {
        TabView(selection: $selectedTab){
            Tab("Calculator", systemImage: "pencil.and.list.clipboard", value: "Calculator") {
                ScoreCalculatorView(apexScore: apexScore)
            }
            Tab("Leaderboard", systemImage: "trophy", value: "Leaderboard") {
                LeaderboardView()
            }
        }
    }
}

#Preview {
    ContentView()
}
