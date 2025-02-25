//
//  SplashView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI
import ComposableArchitecture
// task sleep으로 걸기

struct SplashView: View {
    
    @Perception.Bindable var store: StoreOf<SplashFeature>
    
    var body: some View {
        WithPerceptionTracking {
            ZStack(alignment: .topLeading) {
                Color.blue100.ignoresSafeArea(.all)
                
                contentView
                    .padding(.top, 120)
                    .padding(.leading, 30)
                    .onAppear {
                        store.send(.onAppear)
                    }
            }
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
        Image("PatataMainWhite")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 162, height: 48)
    }
}
