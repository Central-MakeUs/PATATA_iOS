//
//  CustomPageIndicator.swift
//  Patata
//
//  Created by 김진수 on 1/22/25.
//

import SwiftUI

struct CustomPageIndicator: View {
    let numberOfPages: Int
    let currentIndex: Int
    
    var body: some View {
        contentView
    }
}

extension CustomPageIndicator {
    private var contentView: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { index in
                Circle()
                    .fill(currentIndex == index ? Color.blue100 : Color.gray50)
                    .frame(width: 8, height: 8)
            }
        }
    }
}
