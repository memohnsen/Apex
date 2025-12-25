//
//  CustomProgressBar.swift
//  Apex
//
//  Created by Maddisen Mohnsen on 12/24/25.
//

import SwiftUI

struct CustomProgressBar: View {
    let value: Int
    let total: Int
    let fillColor: Color
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white.opacity(0.2))
                    .frame(height: 12)
                
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [fillColor.opacity(0.1), fillColor],
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
