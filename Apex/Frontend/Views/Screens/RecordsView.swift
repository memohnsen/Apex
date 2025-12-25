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
    var isLoading: Bool { viewModel.isLoading }
    @State private var genderOptions: [String] = ["Men", "Women"]
    @State private var gender: String = "Men"
    
    var body: some View {
        NavigationStack{
            ZStack{
                BackgroundColor()
                
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
                            RecordSection(records: records, isLoading: isLoading)
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

struct RecordSection: View {
    var records: [ApexRecords]
    var isLoading: Bool
    @State private var isAnimating: Bool = false
    
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
        if isLoading {
            ForEach(0..<7, id: \.self) { number in
                VStack(spacing: 12) {
                    HStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                            .frame(width: 30, height: 30)
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(isAnimating ? 0.3 : 0.1))
                            .frame(width: 120, height: 24)
                        
                        Spacer()
                    }
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(isAnimating ? 0.25 : 0.08))
                        .frame(height: 28)
                    
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(isAnimating ? 0.2 : 0.05))
                        .frame(width: 150, height: 20)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [
                        .gray.opacity(0.3),
                        .gray.opacity(0.1)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(.rect(cornerRadius: 12))
                .padding(.vertical, 4)
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
        } else {
            ForEach(records, id: \.id) { record in
                NavigationLink(destination: AthleteDetailsView(athlete: Athletes(id: record.id, athlete_name: record.record_holder))) {
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
                    .foregroundStyle(.white)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(colors: [
                        colorByEvent(record.event_name).opacity(0.1),
                        colorByEvent(record.event_name)
                    ], startPoint: .topLeading, endPoint: .bottomTrailing)
                )
                .clipShape(.rect(cornerRadius: 12))
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    RecordsView()
}
