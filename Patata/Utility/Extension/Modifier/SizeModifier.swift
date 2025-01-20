//
//  SizeModifier.swift
//  Patata
//
//  Created by 김진수 on 1/21/25.
//

import SwiftUI

struct SizeModifier: ViewModifier {
    @Binding var size: CGSize
    
    func body(content: Content) -> some View {
        return content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            size = geometry.size
                        }
                }
            )
    }
}
