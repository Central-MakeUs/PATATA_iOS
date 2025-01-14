//
//  ExView.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import SwiftUI

extension View {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .lineSpacing(style.lineHeight - style.fontSize)
    }
}
