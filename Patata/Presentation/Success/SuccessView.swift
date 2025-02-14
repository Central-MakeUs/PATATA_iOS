//
//  SuccessView.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import SwiftUI
import ComposableArchitecture

struct SuccessView: View {
    
    @Perception.Bindable var store: StoreOf<SuccessFeature>
    
    var body: some View {
        contentView
            .navigationBarBackButtonHidden()
    }
}

extension SuccessView {
    private var contentView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image("SuccessImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, 50)
            
            Text("스팟이 등록되었어요!")
                .foregroundStyle(.gray100)
                .textStyle(.headlineS)
            
            VStack {
                Text("스팟이 정상적으로 등록되었습니다.")
                Text("다른 스팟들을 둘러보러 가볼까요?")
            }
            .textStyle(.subtitleS)
            .foregroundStyle(.blue50)
            .padding(.top, 10)
            
            Spacer()
            
            HStack {
                Spacer()
                
                Text("확인")
                    .textStyle(.subtitleM)
                    .foregroundStyle(.white)
                    .padding(.vertical, 18)
                
                Spacer()
            }
            .background(.navy100)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.horizontal, 15)
            .padding(.bottom, 30)
            .asButton {
                store.send(.viewEvent(.tappedConfirmButton))
            }
        }
    }
}
