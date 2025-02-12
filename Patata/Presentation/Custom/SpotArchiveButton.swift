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
    let viewState: ViewState
    
    enum ViewState {
        case home
        case other
    }
    
    @Binding var isSaved: Bool
    
    var otherGesture: (() -> Void)?
    
    private let animationDuration: Double = 0.1
    private var animationScale: CGFloat {
        isSaved ? 1.5 : 0.7
    }
    @State private var animate = false
    
    init(height: CGFloat, width: CGFloat, viewState: ViewState = .other, isSaved: Binding<Bool>, otherGesture: (() -> Void)? = nil) {
        self.height = height
        self.width = width
        self.viewState = viewState
        self._isSaved = isSaved
        self.otherGesture = otherGesture
    }
    
    var body: some View {
        Image(isSaved ? "ArchiveActive" : (viewState == .home ? "HomeArchiveIcon": "ArchiveInactive"))
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: width, height: height)
            .foregroundStyle(isSaved ? .black : .white)
            .asButton {
                if let otherGesture {
                    otherGesture()
                }
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
