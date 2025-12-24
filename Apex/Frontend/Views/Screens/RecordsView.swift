//
//  RecordsView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import SwiftUI

struct RecordsView: View {
    @Bindable private var viewModel = RecordsModel()
    var records: [ApexRecords] { viewModel.records }
    @State private var genderOptions: [String] = ["Men", "Women"]
    @State private var gender: String = "Men"
    
    private func image(_ name: String) -> String {
        if name == "Fast Forty" {
            return "speed"
        } else if name == "Max Toss" || name == "The Broad" || name  == "The Vertical" {
            return "power"
        } else if name == "The Mile" {
            return "endurance"
        } else {
            return "strength"
        }
    }
    
    private func recordSubText(_ name: String) -> String {
        if name == "Fast Forty" {
            return "seconds"
        } else if name == "Max Toss" || name == "The Broad" || name  == "The Vertical" {
            return "inches"
        } else if name == "The Mile" {
            return "min/mile"
        } else {
            return "reps"
        }
    }
    
    var body: some View {
        NavigationStack{
            ZStack{
                LinearGradient(colors: [
                    Color(red: 2/255, green: 17/255, blue: 27/255),
                    Color(red: 48/255, green: 41/255, blue: 47/255)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                ScrollView{
                    VStack {
                        Picker("\(gender)", selection: $gender) {
                            ForEach(genderOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding()
                        
                        VStack {
                            ForEach(records, id: \.id) { record in
                                VStack{
                                    HStack{
                                        Image(image(record.event_name))
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 30, height: 30)
                                        Text(record.event_name)
                                            .font(.title)
                                            .bold()
                                        
                                        Spacer()
                                    }
                                    Spacer()
                                    
                                    Text("\(record.record_value) \(recordSubText(record.event_name))")
                                        .font(.system(size: 24))
                                        .bold()
                                        .padding(.vertical)
                                    
                                    Spacer()
                                    
                                    Text(record.record_holder)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 18))
                                        .bold()
                                    
                                    if let handle = record.instagram_handle,
                                       let url = URL(string: "https://instagram.com/\(handle)") {
                                        Link(handle, destination: url)
                                            .multilineTextAlignment(.center)
                                            .font(.system(size: 18))
                                            .bold()
                                            .foregroundStyle(.white)
                                    }
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    LinearGradient(colors: [
                                        .gray,
                                        colorByEvent(record.event_name)
                                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                                .clipShape(.rect(cornerRadius: 12))
                            }
                            .padding(.vertical, 4)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Apex Records")
            .preferredColorScheme(.dark)
        }
        .task {
            await viewModel.fetchRecords(gender: gender)
        }
        .onChange(of: gender) {
            Task {
                await viewModel.fetchRecords(gender: gender)
            }
        }
    }
}

#Preview {
    RecordsView()
}
