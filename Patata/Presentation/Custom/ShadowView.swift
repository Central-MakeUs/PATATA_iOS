//
//  ShadowView.swift
//  Patata
//
//  Created by 김진수 on 8/5/25.
//

import SwiftUI

struct ShadowView: View {
    let opacity: Double
    let start: UnitPoint
    let end: UnitPoint
    let height: Double
    
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.shadowColor.opacity(opacity),
                Color.clear
            ]),
            startPoint: start,
            endPoint: end
        )
        .frame(height: height)
        .allowsHitTesting(false)
    }
}
