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
    
    @State private var filterButtonClicked: Bool = false
    
    @State private var genderOptions: [String] = ["Men", "Women"]
    @State private var gender: String? = "Women"
    @State private var sortBy: String = "name"
    @State private var asc: Bool = true
    
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
                        AthleteList(athletes: athletes)
                    }
                    .padding([.horizontal, .vertical])
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
                ToolbarSpacer()
                ToolbarItem{
                    Menu{
                        Button{
                            sortBy = "name"
                            asc = true
                        } label: {
                            Text("Name: A-Z")
                        }
                        Button{
                            sortBy = "name"
                            asc = false
                        } label: {
                            Text("Name: Z-A")
                        }
                        Button{
                            sortBy = "apex_score"
                            asc = true
                        } label: {
                            Text("Apex Score: Low-High")
                        }
                        Button{
                            sortBy = "apex_score"
                            asc = false
                        } label: {
                            Text("apex_score: High-Low")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
            }
            .task {
                await viewModel.fetchAthletes(gender: gender ?? "Men")
            }
            .sheet(isPresented: $filterButtonClicked) {
                FilterModal(genderOptions: genderOptions, gender: gender ?? "Men")
            }
        }
    }
}

struct FilterModal: View {
    @Environment(\.dismiss) var dismiss
    
    var genderOptions: [String]
    var gender: String
    
    var body: some View {
        NavigationStack{
            VStack{
                Text("bbb")
                
                Spacer()
            }
            .toolbar{
                ToolbarItem{
                    Button(role: .confirm) {
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
    }
}

#Preview {
    AthleteSearchView()
}
