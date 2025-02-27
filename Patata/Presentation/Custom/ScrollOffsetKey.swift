//
//  ScrollOffsetKey.swift
//  Patata
//
//  Created by 김진수 on 2/28/25.
//

import SwiftUICore

struct ScrollOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
