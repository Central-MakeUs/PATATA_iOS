//
//  RecommendSpotIconMark.swift
//  Patata
//
//  Created by 김진수 on 2/8/25.
//

import SwiftUI

struct RecommendSpotIconMark: View {
    var body: some View {
        recommendSpotIcon
    }
}

extension RecommendSpotIconMark {
    private var recommendSpotIcon: some View {
        ZStack(alignment: .topTrailing) {
            Image("RecommendSpotIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 75, height: 100)
                .offset(x: -5)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: 5))
                path.addLine(to: CGPoint(x: 5, y: 5))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.closeSubpath()
            }
            .foregroundStyle(.blue100)
            .frame(width: 5, height: 5)
        }
    }
}
