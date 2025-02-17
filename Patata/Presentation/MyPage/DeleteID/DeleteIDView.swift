//
//  DeleteIDView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture

struct DeleteIDView: View {
    @Perception.Bindable var store: StoreOf<DeleteIDFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden()
        }
    }
}

extension DeleteIDView {
    private var contentView: some View {
        VStack(spacing: 0) {
            fakeNavBar
                .padding(.bottom, 12)
                .background(.white)
            
            VStack(spacing: 4) {
                HStack {
                    Text("파타타를 떠나신다니 너무 아쉬워요")
                        .foregroundStyle(.textDefault)
                        .textStyle(.subtitleM)
                    
                    Image("NoAddIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                    
                    Spacer()
                }
                
                HStack {
                    Text("탈퇴하기 전 아래 내용을 꼭 확인해주세요!")
                        .textStyle(.captionM)
                        .foregroundStyle(.textInfo)
                    
                    Spacer()
                }
            }
            .padding(.top, 30)
            .padding(.horizontal, 15)
            
            VStack {
                HStack {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 4, height: 4)
                        .foregroundStyle(.black)
                    
                    Text("회원님의 모든 활동 정보는 다른 회원들이 식별할 수 없도록 바로 삭제되며, 삭제된 데이터는 복구할 수 없습니다.")
                        .textStyle(.subtitleS)
                        .foregroundStyle(.textInfo)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 4, height: 4)
                        .foregroundStyle(.black)
                    
                    Text("탈퇴 후 7일 동안 다시 가입할 수 없어요.")
                        .textStyle(.subtitleS)
                        .foregroundStyle(.textInfo)
                    
                    Spacer()
                }
            }
            .padding(.top, 50)
            .padding(.horizontal, 15)
            
            Spacer()
            
            VStack(spacing: 20) {
                HStack {
                    if !store.checkIsValid {
                        Circle()
                            .fill(Color.white)
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.gray, lineWidth: 1)
                            )
                            .frame(width: 24, height: 24)
                    } else {
                        Image("CircleCheck")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    }
                    
                    Text("안내사항을 확인하였으며, 이에 동의합니다.")
                        .textStyle(.subtitleS)
                        .foregroundStyle(store.checkIsValid ? .textDefault : .textDisabled)
                    
                    Spacer()
                }
                .padding(.top, 12)
                .asButton {
                    store.send(.viewEvent(.tappedCheckButton))
                }
                
                HStack {
                    Spacer()
                    
                    Text("확인")
                        .textStyle(.subtitleM)
                        .foregroundStyle(.white)
                        .padding(.vertical, 16)
                    
                    Spacer()
                }
                .background(store.checkIsValid ? .navy100 : .gray50)
                .clipShape(RoundedRectangle(cornerRadius: 38))
                .asButton {
                    if store.checkIsValid {
                        store.send(.viewEvent(.tappedDeleteID))
                    }
                }
                .padding(.bottom, 20)
            }
            .padding(.horizontal, 15)
            .background(.white)
        }
        .background(.gray10)
    }
    
    private var fakeNavBar: some View {
        ZStack {
            HStack {
                NavBackButton {
                    hideKeyboard()
                    store.send(.viewEvent(.tappedBackButton))
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Text("회원 탈퇴")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
        }
    }
}
