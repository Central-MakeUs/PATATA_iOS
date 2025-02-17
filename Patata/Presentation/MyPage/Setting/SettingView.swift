//
//  SettingView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture

struct SettingView: View {
    
    @Perception.Bindable var store: StoreOf<SettingFeature>
    
    var body: some View {
        contentView
            .navigationBarBackButtonHidden()
    }
}

extension SettingView {
    private var contentView: some View {
        VStack(spacing: 0) {
            fakeNavBar
                .padding(.bottom, 12)
                .background(.white)
            
            HStack {
                Text("약관 및 정책")
                    .textStyle(.subtitleS)
                    .foregroundStyle(.textDefault)
                    .padding(.vertical, 16)
                    .padding(.leading, 15)
                
                Spacer()
            }
            VStack(spacing: 1) {
                settingBar("이용약관")
                
                settingBar("개인정보 수집 및 이용 동의")
                
                settingBar("오픈소스 라이선스")
                
                settingBar("버전")
            }
            
            HStack {
                Text("서비스 안내")
                    .textStyle(.subtitleS)
                    .foregroundStyle(.textDefault)
                    .padding(.vertical, 16)
                    .padding(.leading, 15)
                
                Spacer()
            }
            
            VStack(spacing: 1) {
                settingBar("PATATA 팀 정보 찾아가기")
                
                settingBar("공지사항")
                
                settingBar("FAQ")
                
                settingBar("문의하기")
            }
            
            Spacer()
            
            bottomView
        }
        .background(.gray10)
    }
    
    private var bottomView: some View {
        HStack(spacing: 30) {
            Text("로그아웃")
                .foregroundColor(.gray)
                .asButton {
                    store.send(.viewEvent(.tappedLogout))
                }
            
            Text("|")
                .foregroundColor(.gray)
            
            Text("회원탈퇴")
                .foregroundColor(.gray)
        }
        .textStyle(.captionM)
        .foregroundStyle(.textDisabled)
        .padding(.vertical, 16)
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
            
            Text("설정")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
        }
    }
}

extension SettingView {
    private func settingBar(_ text: String) -> some View {
        HStack {
            Text(text)
                .textStyle(.bodyS)
                .foregroundStyle(.black)
                .padding(.vertical, 16)
                .padding(.leading, 15)
            
            Spacer()
            
            Image("NextActive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 20, height: 20)
                .padding(.trailing, 15)
        }
        .background(.white)
        
    }
}
