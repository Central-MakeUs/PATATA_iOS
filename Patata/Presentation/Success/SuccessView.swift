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
        WithPerceptionTracking {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.white, Color.blue10]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                contentView
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

extension SuccessView {
    private var contentView: some View {
        VStack(alignment: .center) {
            Spacer()
            
            Image("SuccessImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 228, height: 300)
            
            if store.viewState == .spot {
                Text("스팟이 등록되었어요!")
                    .foregroundStyle(.gray100)
                    .textStyle(.headlineS)
                
                VStack(spacing: 0) {
                    Text("스팟이 정상적으로 등록되었습니다.")
                    Text("다른 스팟들을 둘러보러 가볼까요?")
                }
                .textStyle(.subtitleS)
                .foregroundStyle(.blue50)
                .padding(.top, 10)
            } else if store.viewState == .first {
                Text("가입이 완료되었어요!")
                    .foregroundStyle(.gray100)
                    .textStyle(.headlineS)
                
                VStack {
                    Text("파타타 회원이 되신 것을 환영해요.")
                    Text("타타와 함께 최고의 스팟을 찾아봐요!")
                }
                .textStyle(.subtitleS)
                .foregroundStyle(.blue50)
                .padding(.top, 6)
                
                VStack(spacing: 4) {
                    Text("스팟생성 및 댓글 작성 시 부적절한 내용이나 악의적인 사용을 삼가해 주세요.")
                    Text("신고 접수 시 즉시 이용이 제한되며, 24시간 이내 검토 후 게시글 및 댓글이 삭제될 수 있습니다.")
                }
                .textStyle(.captionS)
                .foregroundStyle(.gray60)
                .multilineTextAlignment(.center)
                .padding(.top, 60)
                .padding(.horizontal, 20)
            }
            
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
