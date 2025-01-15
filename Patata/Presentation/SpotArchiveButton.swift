//
//  SpotArchiveButton.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

struct SpotArchiveButton: View {
    let height: CGFloat
    let width: CGFloat
    
    @Binding var isSaved: Bool
    
    private let animationDuration: Double = 0.1
    private var animationScale: CGFloat {
        isSaved ? 1.5 : 0.7
    }
    @State private var animate = false
    
    var body: some View {
        Image(isSaved ? "ArchiveActive" : "ArchiveInactive")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
            .foregroundStyle(isSaved ? .black : .white)
            .asButton {
                self.animate = true
                self.isSaved.toggle()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                    self.animate = false
                    
                }
            }
            .scaleEffect(animate ? animationScale : 1)
            .animation(.easeIn(duration: animationDuration), value: isSaved)
    }
}
