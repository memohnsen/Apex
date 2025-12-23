//
//  Header.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/23/25.
//

import SwiftUI

struct Header: View {
    var subtitle: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Apex")
                .font(.system(size: 56, weight: .black))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(red: 0.8, green: 0.9, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            if subtitle != nil {
                Text(subtitle ?? "")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                    .fontWeight(.medium)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 10)
    }
}

#Preview {
    Header()
}
