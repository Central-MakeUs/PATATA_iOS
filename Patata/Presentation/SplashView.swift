//
//  SplashView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

// task sleep으로 걸기

struct SplashView: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.blue100.ignoresSafeArea(.all)
            
            contentView
                .padding(.top, 120)
                .padding(.leading, 30)
        }
    }
}

extension SplashView {
    private var contentView: some View {
        VStack(alignment: .leading) {
            subTitleView
            titleView
        }
    }
    
    private var subTitleView: some View {
        HStack(spacing: 0) {
            Text("사진 스팟")
                .foregroundStyle(.white)
                .textStyle(.subtitleL)
            Text("의 모든 것")
                .foregroundStyle(.white)
                .textStyle(.subtitleM)
        }
    }
    
    private var titleView: some View {
        Text("patata")
            .foregroundStyle(.white)
            .textStyle(.headlineL)
    }
}
