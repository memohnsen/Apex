//
//  AthleteSearch.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import SwiftUI

struct AthleteSearchView: View {
    @Bindable private var viewModel = ResultsModel()
    var athletes: [Athletes] { viewModel.athletes }
    var events: [Events] { viewModel.events }
    
    @State private var filterButtonClicked: Bool = false
    @State private var genderOptions: [String] = ["All", "Men", "Women"]
    @State private var gender: String = "All"
    @State private var event: String = "All"
    @State private var sortBy: String = "name"
    @State private var asc: Bool = true
    
    private var filteredAthletes: [Athletes] {
        var filtered = athletes
        
        // Filter by gender if not "All"
        if gender != "All" {
            filtered = filtered.filter { athlete in
                // We'll need to add gender to Athletes model or filter on backend
                true // For now, keep all (will be filtered by backend fetch)
            }
        }
        
        // Filter by event if not "All"
        if event != "All" {
            // Event filtering would need event info in Athletes model
            // For now, this will be handled by backend fetch
        }
        
        return filtered
    }
    
    private var sortedAthletes: [Athletes] {
        let sorted = filteredAthletes.sorted { athlete1, athlete2 in
            if sortBy == "name" {
                if asc {
                    return athlete1.athlete_name < athlete2.athlete_name
                } else {
                    return athlete1.athlete_name > athlete2.athlete_name
                }
            } else {
                let score1 = athlete1.apex_score ?? 0
                let score2 = athlete2.apex_score ?? 0
                if asc {
                    return score1 < score2
                } else {
                    return score1 > score2
                }
            }
        }
        return sorted
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
                ScrollView {
                    VStack{
                        AthleteList(athletes: sortedAthletes)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Apex Athletes")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
            .toolbar{
                ToolbarItem{
                    Button{
                        filterButtonClicked = true
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                    }
                }
            }
            .task {
                await viewModel.fetchAthletes(gender: gender)
                await viewModel.fetchEvents()
            }
            .onChange(of: filterButtonClicked) {
                Task {
                    await viewModel.fetchAthletes(gender: gender)
                }
            }
            .sheet(isPresented: $filterButtonClicked) {
                FilterModal(genderOptions: $genderOptions, gender: $gender, events: events, event: $event, filterButtonClicked: $filterButtonClicked, sortBy: $sortBy, asc: $asc)
                    .presentationDetents([.medium])
            }
        }
    }
}

struct FilterModal: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var genderOptions: [String]
    @Binding var gender: String
    var events: [Events]
    @Binding var event: String
    @Binding var filterButtonClicked: Bool
    @Binding var sortBy: String
    @Binding var asc: Bool
    
    private var sortOptions: [String] {
        ["Name: A-Z", "Name: Z-A", "Score: 0-1000", "Score: 1000-0"]
    }
    
    private var currentSortSelection: String {
        if sortBy == "name" && asc {
            return "Name: A-Z"
        } else if sortBy == "name" && !asc {
            return "Name: Z-A"
        } else if sortBy == "apex_score" && asc {
            return "Score: 0-1000"
        } else {
            return "Score: 1000-0"
        }
    }   
    
    private func updateSort(selection: String) {
        switch selection {
        case "Name: A-Z":
            sortBy = "name"
            asc = true
        case "Name: Z-A":
            sortBy = "name"
            asc = false
        case "Score: 0-1000":
            sortBy = "apex_score"
            asc = true
        case "Score: 1000-0":
            sortBy = "apex_score"
            asc = false
        default:
            break
        }
    }
    
    var body: some View {
        NavigationStack{
            ScrollView {
                HStack {
                    Text("Gender:")
                    Spacer()
                    Picker(gender, selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                .cardStyling()
                
                HStack {
                    Text("Competition:")
                    Spacer()
                    Picker(event, selection: $event) {
                        Text("All").tag("All")
                        ForEach(events, id: \.self) { ev in
                            Text(ev.event_name).tag(ev.event_name)
                        }
                    }
                }
                .cardStyling()
                
                HStack {
                    Text("Sort By:")
                    Spacer()
                    Picker(currentSortSelection, selection: Binding(
                        get: { currentSortSelection },
                        set: { updateSort(selection: $0) }
                    )) {
                        ForEach(sortOptions, id: \.self) { option in
                            Text(option).tag(option)
                        }
                    }
                }
                .cardStyling()
                
                
                Spacer()
            }
            .toolbar{
                ToolbarItem{
                    Button(role: .confirm) {
                        filterButtonClicked = false
                        dismiss()
                    } label: {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.white)
                    }
                }
            }
        }
    }
}

struct AthleteList: View {
    var athletes: [Athletes]
    
    var body: some View {
        ForEach(athletes, id: \.id) {athlete in
            NavigationLink(destination: AthleteDetailsView(athlete: athlete)) {
                HStack{
                    Text(athlete.athlete_name)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .cardStyling()
            }
        }
    }
}

#Preview {
    AthleteSearchView()
}
