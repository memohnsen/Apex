//
//  Colors.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import SwiftUI

func category(_ score: Int) -> String {
    if score < 400 {
       return "DEVELOPING"
    } else if score < 600 {
        return "ATHLETIC"
    } else if score < 700 {
        return "ATHLETIC AF"
    } else if score < 800 {
        return "PRO"
    } else {
        return "APEX"
    }
}

func colorForRank(_ title: String) -> Color {
    switch title {
    case "APEX":
        return .orange
    case "PRO":
        return .green
    case "ATHLETIC AF":
        return .purple
    case "ATHLETIC":
        return .blue
    default:
        return .white
    }
}

func podiumColors(_ score: Int) -> Color {
    if score == 1 {
        return Color(red: 255/255, green: 191/255, blue: 0/255)
    } else if score == 2 {
        return Color(red: 192/255, green: 192/255, blue: 192/255)
    } else if score == 3 {
        return Color(red: 205/255, green: 127/255, blue: 50/255)
    } else {
        return .white
    }
}

func colorByEvent(_ name: String) -> Color {
    if name == "Fast Forty" {
        return .green
    } else if name == "Max Toss" || name == "The Broad" || name  == "The Vertical" {
        return .orange
    } else if name == "The Mile" {
        return .blue
    } else {
        return .purple
    }
}
