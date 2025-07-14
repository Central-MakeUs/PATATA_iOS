//
//  NetworkErrorView.swift
//  Patata
//
//  Created by 김진수 on 2/28/25.
//

import SwiftUI
import ComposableArchitecture

struct NetworkErrorView: View {
    
    @Perception.Bindable var store: StoreOf<NetworkErrorFeature>
    
    var body: some View {
        contentView
    }
}

extension NetworkErrorView {
    private var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            Image("NoNetwork")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .center, spacing: 4) {
                Text("네트워크 연결이")
                Text("원활하지 않습니다.")
            }
            .textStyle(.headlineS)
            .foregroundStyle(.textDefault)
            .padding(.top, 36)
            
            Text("네트워크 상태를 확인 후 다시 시도해주세요.")
                .textStyle(.bodyM)
                .foregroundStyle(.textInfo)
                .padding(.top, 16)
            
            HStack {
                Spacer()
                
                Text("스팟 둘러보러 가기")
                    .textStyle(.subtitleM)
                    .foregroundStyle(.white)
                    .padding(.vertical, 14)
                
                Spacer()
            }
            .background(.black)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .padding(.bottom, 20)
            .padding(.top, 36)
            .padding(.horizontal, 75)
            .asButton {
                store.send(.viewEvent(.tappedButton))
            }
        }
    }
}
