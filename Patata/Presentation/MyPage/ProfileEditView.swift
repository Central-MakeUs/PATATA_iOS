//
//  ProfileEditView.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import SwiftUI
import ComposableArchitecture

struct ProfileEditView: View {
    @Perception.Bindable var store: StoreOf<ProfileEditFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .background(.gray20)
                .navigationBarBackButtonHidden()
        }
    }
}

extension ProfileEditView {
    private var contentView: some View {
        VStack(alignment: .center, spacing: 0) {
            fakeNavgationBar
                .padding(.bottom, 12)
                .background(.white)
            
            myProfileImage
                .padding(.top, 40)
            
            nickNameView
                .padding(.top, 40)
                .padding(.horizontal, 15)
            
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Text("완료")
                        .foregroundStyle(.white)
                        .textStyle(.subtitleM)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
                .background(store.isValid ? .black : .gray50)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
                .padding(.top, 5)
                
            }
            .background(.white)
        }
    }
    
    private var fakeNavgationBar: some View {
        ZStack {
            HStack {
                NavBackButton {
                    store.send(.viewEvent(.tappedBackButton))
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Text("프로필 수정")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
        }
    }
    
    private var myProfileImage: some View {
        Image(store.profileImage)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(alignment: .bottomTrailing) {
                Image("EditActive")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .foregroundStyle(.white)
                            .shadow(color: .shadowColor, radius: 8)
                    )
            }
        
    }
    
    private var nickNameView: some View {
        VStack {
            HStack {
                Text("닉네임")
                    .textStyle(.subtitleM)
                    .foregroundStyle(.textDefault)
                
                Spacer()
            }
            
            TextField("", text: $store.nickname.sending(\.bindingNickname))
                .textStyle(.subtitleS)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .padding(.horizontal, 16)
                .background(.white)
//                .background(store.isValid ? .white : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    ZStack(alignment: .leading) {
                        if store.nickname.isEmpty {
                            HStack {
                                Text("최소 2글자, 최대 10로 입력해주세요")
                                    .textStyle(.bodyS)
                                    .foregroundColor(.textDisabled)
                                    .padding(.leading, 16)
                                
                                Spacer()
                                
                            }
                        }
                        
                        HStack {
                            Spacer()
                            
                            Image("CircleXActive")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .padding(.trailing, 16)
                                .asButton {
                                    store.send(.viewEvent(.tappedClearNickName))
                                }
                        }
                    }
                    
                    if !store.isValid {
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(.red100, lineWidth: 2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .onChange(of: store.nickname) { newValue in
                    store.send(.validCheckText(newValue))
                }
            
            HStack {
                Text("이미 사용 중인 닉네임입니다.")
                    .foregroundStyle(.red100)
                    .textStyle(.captionM)
                    .opacity(store.isValid ? 0 : 1)
                
                Spacer()
            }
        }
    }
}
