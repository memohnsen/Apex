//
//  ScoreResultsView.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/23/25.
//

import SwiftUI

struct ScoreResultsView: View {
    @Bindable var apexScore: ApexScore
    
    private func determineQuadrant(x: Int, y: Int) -> QuadrantPosition {
        let midpoint = 125 // Half of 250
        
        if y >= midpoint && x < midpoint {
            return .topLeft
        } else if y >= midpoint && x >= midpoint {
            return .topRight
        } else if y < midpoint && x < midpoint {
            return .bottomLeft
        } else {
            return .bottomRight
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack{
                LinearGradient(colors: [
                    colorForRank(category(apexScore.totalScore)),
                    Color(red: 48/255, green: 41/255, blue: 47/255)
                ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
                
                ScrollView{
                    VStack(alignment: .leading) {
                        VStack(spacing: 6) {
                            Text("\(apexScore.totalScore)")
                                .font(.system(size: 36))
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Text(category(apexScore.totalScore))
                                .font(.system(size: 36))
                                .fontWeight(.semibold)
                                .foregroundColor(colorForRank(category(apexScore.totalScore)))
                            
                            Text("Out of 1000 points")
                                .font(.system(size: 18))
                                .italic()
                                .foregroundColor(.white.opacity(0.5))
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
                        
                        ScoreBySection(title: "Speed", score: apexScore.speedScore, icon: "speed")
                        ScoreBySection(title: "Power", score: apexScore.powerScore, icon: "power")
                        ScoreBySection(title: "Strength", score: apexScore.strengthScore, icon: "strength")
                        ScoreBySection(title: "Endurance", score: apexScore.enduranceScore, icon: "endurance")
                        
                        Text("Athletic Profile")
                            .font(.system(size: 24))
                            .foregroundStyle(.white)
                            .bold()
                            .padding([.top, .horizontal])
                        
                        Rectangle()
                            .fill(.white)
                            .frame(height: 1)
                            .padding([.bottom, .horizontal])
                        
                        AthleticProfileGrid(
                            title: "STRENGTH VS POWER",
                            xAxisLabel: "STRENGTH",
                            yAxisLabel: "POWER",
                            quadrants: [
                                ("EXPLOSIVE", .topLeft),
                                ("POWERHOUSE", .topRight),
                                ("DEVELOPING", .bottomLeft),
                                ("GRINDER", .bottomRight)
                            ],
                            highlightedQuadrant: determineQuadrant(x: apexScore.strengthScore, y: apexScore.powerScore),
                            xScore: apexScore.strengthScore,
                            yScore: apexScore.powerScore
                        )
                        
                        AthleticProfileGrid(
                            title: "SPEED VS ENDURANCE",
                            xAxisLabel: "SPEED",
                            yAxisLabel: "ENDURANCE",
                            quadrants: [
                                ("ENDURANCE", .topLeft),
                                ("COMPLETE", .topRight),
                                ("DEVELOPING", .bottomLeft),
                                ("SPRINTER", .bottomRight)
                            ],
                            highlightedQuadrant: determineQuadrant(x: apexScore.speedScore, y: apexScore.enduranceScore),
                            xScore: apexScore.speedScore,
                            yScore: apexScore.enduranceScore
                        )
                        
                        //Performance Interpretation
                        VStack(alignment: .leading) {
                            Text("Performance Interpretation")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                                .bold()
                                .padding(.top)
                            
                            Rectangle()
                                .fill(.white)
                                .frame(height: 1)
                                .padding(.bottom)
                            
                            Text("Apex: 800+")
                                .padding()
                                .bold()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.orange, .orange], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.bottom, 6)
                            
                            Text("Pro: 700-799")
                                .padding()
                                .bold()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.green, .green], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.bottom, 6)
                            
                            Text("Athletic AF: 600-699")
                                .padding()
                                .bold()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.purple, .purple], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.bottom, 6)
                            
                            
                            Text("Athletic: 400-599")
                                .padding()
                                .bold()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.blue, .blue], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.bottom, 6)
                            
                            Text("Developing: <400")
                                .padding()
                                .bold()
                                .frame(maxWidth: .infinity)
                                .background(LinearGradient(colors: [.gray, .gray], startPoint: .leading, endPoint: .trailing))
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 12))
                                .padding(.bottom, 6)
                        }
                        .padding([.bottom, .horizontal])
                    }
                    .padding(.top)
                }
                .toolbar{
                    ToolbarItem(placement: .topBarTrailing) {
                        Button{
                            
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .navigationTitle("Apex Score")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.dark)
        }
    }
}

struct ScoreBySection: View {
    var title: String
    var score: Int
    var icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 12){
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Text("\(title): \(score)/250")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.bottom, 6)
            
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
        .padding(.horizontal)
        .padding(.bottom, 12)
    }
    
    private func colorForSection(_ title: String) -> Color {
        switch title {
        case "Speed":
            return .green
        case "Power":
            return .orange
        case "Strength":
            return .purple
        case "Endurance":
            return .blue
        default:
            return .blue
        }
    }
}

struct CustomProgressBar: View {
    let value: Int
    let total: Int
    let fillColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 12)
                
                // Fill bar
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [fillColor, fillColor.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * CGFloat(value) / CGFloat(total), height: 12)
                    .animation(.easeInOut(duration: 0.5), value: value)
            }
        }
        .frame(height: 12)
    }
}

enum QuadrantPosition {
    case topLeft, topRight, bottomLeft, bottomRight
}

struct AthleticProfileGrid: View {
    let title: String
    let xAxisLabel: String
    let yAxisLabel: String
    let quadrants: [(String, QuadrantPosition)]
    let highlightedQuadrant: QuadrantPosition
    let xScore: Int
    let yScore: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 16)
                .padding(.bottom, 12)
            
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 1) {
                        // Top Left
                        QuadrantView(
                            label: getLabel(for: .topLeft),
                            isHighlighted: highlightedQuadrant == .topLeft
                        )
                        
                        // Top Right
                        QuadrantView(
                            label: getLabel(for: .topRight),
                            isHighlighted: highlightedQuadrant == .topRight
                        )
                    }
                    
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(height: 1)
                    
                    HStack(spacing: 1) {
                        // Bottom Left
                        QuadrantView(
                            label: getLabel(for: .bottomLeft),
                            isHighlighted: highlightedQuadrant == .bottomLeft
                        )
                        
                        // Bottom Right
                        QuadrantView(
                            label: getLabel(for: .bottomRight),
                            isHighlighted: highlightedQuadrant == .bottomRight
                        )
                    }
                }
            }
            .padding(.horizontal)
            
            Text("\(getLabel(for: highlightedQuadrant).uppercased())")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.orange)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 16)
        }
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
    
    private func getLabel(for position: QuadrantPosition) -> String {
        quadrants.first(where: { $0.1 == position })?.0 ?? ""
    }
}

struct QuadrantView: View {
    let label: String
    let isHighlighted: Bool
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color(red: 40/255, green: 45/255, blue: 50/255))
            
            if isHighlighted {
                Rectangle()
                    .fill(Color.white.opacity(0.15))
            }
            
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(isHighlighted ? .white : Color.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(8)
        }
        .frame(height: 80)
    }
}

#Preview {
    ScoreResultsView(apexScore: ApexScore())
}
