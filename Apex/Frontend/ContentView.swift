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
    @State private var selectedTab: String = "Home"
    @State private var search: String = ""
    @State private var apexScore: ApexScore = ApexScore()
    
    var body: some View {
        TabView(selection: $selectedTab){
            Tab("Home", systemImage: "house", value: "Home") {
                HomeView()
            }
            Tab("Calculator", systemImage: "minus.forwardslash.plus", value: "Calculator") {
                ScoreCalculatorView(apexScore: apexScore)
            }
            Tab("Leaderboard", systemImage: "list.clipboard", value: "Leaderboard") {
                LeaderboardView()
            }
            Tab("Search", systemImage: "magnifyingglass", value: "Start List", role: .search) {
                NavigationStack {
                    AthleteSearchView()
                }
                .searchable(text: $search)
            }
        }
    }
}

#Preview {
    ContentView()
}
