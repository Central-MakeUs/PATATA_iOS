//
//  HashTagModifier.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct HashTagModifier: ViewModifier {
    let backgroundColor: Color
    let textColor: Color
    let font: TextStyle
    let verticalPadding: CGFloat
    let horizontalPadding: CGFloat
    let cornerRadius: CGFloat
    
    func body(content: Content) -> some View {
        
        content
            .textStyle(font)
            .foregroundColor(textColor)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            
    }
}

extension Text {
    func hashTagStyle(backgroundColor: Color = .blue10, textColor: Color = .gray80, font: TextStyle = .captionS, verticalPadding: CGFloat = 4, horizontalPadding: CGFloat = 10, cornerRadius: CGFloat = 10) -> some View {
        self.modifier(HashTagModifier(backgroundColor: backgroundColor, textColor: textColor, font: font, verticalPadding: verticalPadding, horizontalPadding: horizontalPadding, cornerRadius: cornerRadius))
    }
}

