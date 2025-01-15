//
//  ButtonModifier.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct ButtonModifier: ViewModifier {
    
    let action: () -> Void
    
    func body(content: Content) -> some View {
        Button(
            action:action,
            label: { content }
        )
    }
}
