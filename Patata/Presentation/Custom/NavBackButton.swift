//
//  NavBackButton.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI

struct NavBackButton: View {
    let tappedButton: () -> Void
    
    var body: some View {
        contentView
    }
}

extension NavBackButton {
    private var contentView: some View {
        Image("PreviousActive")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
            .asButton {
                tappedButton()
            }
    }
}
