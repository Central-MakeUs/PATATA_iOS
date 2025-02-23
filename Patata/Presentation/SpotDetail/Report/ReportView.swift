//
//  ReportView.swift
//  Patata
//
//  Created by 김진수 on 2/18/25.
//

import SwiftUI
import ComposableArchitecture

struct ReportView: View {
    
    @Perception.Bindable var store: StoreOf<ReportFeature>
    
    @FocusState private var isFocused: Bool

    init(store: StoreOf<ReportFeature>) {
        self.store = store
        _isFocused = FocusState()
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.gray20
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
            
            WithPerceptionTracking {
                contentView
                    .navigationBarBackButtonHidden()
                    .onTapGesture {
                        hideKeyboard()
                    }
            }
        }
    }
}

extension ReportView {
    private var contentView: some View {
        VStack {
            fakeNavgationBar
                .padding(.bottom, 14)
                .background(.white)
            
            ForEach(Array(store.reportOption.enumerated()), id: \.element) { index, option in
                reportOptionRow(title: option.description(for: store.viewState), index: index)
                if option == .other {
                    TextEditor(text: $store.textFieldText.sending(\.bindingTextFieldText))
                        .textStyle(.subtitleS)
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 1)
                                .padding(.horizontal, 15)
                        )
                        .onChange(of: store.textFieldText) { newValue in
                            store.send(.viewEvent(.textValidation(newValue)))
                        }
                        .onChange(of: isFocused) { isFocused in
                            if isFocused == true {  // 옵셔널 비교
                                store.send(.viewEvent(.tappedCheckButton(3)))
                            }
                        }
                        .overlay(
                            HStack {
                                if store.textFieldText.isEmpty {
                                    Text("신고내용을 입력해주세요. (최대 300자)")
                                        .textStyle(.bodyS)
                                        .foregroundColor(.textDisabled)
                                        .padding(.leading, 15)
                                    
                                    Spacer()
                                }
                            }
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                            
                            
                        ,  alignment: .topLeading)
                    
                    HStack {
                        Spacer()
                        Text("\(store.textFieldText.count)/300")
                            .textStyle(.captionS)
                            .foregroundColor(.textDisabled)
                            .padding(.trailing, 15)
                    }
                }
                
            }
            
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    
                    Text("신고하기")
                        .textStyle(.subtitleM)
                        .foregroundStyle(.white)
                        .padding(.vertical, 14)
                    
                    Spacer()
                }
                .background(store.buttonIsValid ? .black : .gray50)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.bottom, 20)
                .padding(.top, 8)
                .padding(.horizontal, 15)
                .asButton {
                    if store.buttonIsValid {
                        store.send(.viewEvent(.tappedConfirmButton))
                    }
                }
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
            
            Text(store.viewState == .user ? "사용자 신고하기" : "게시글 신고하기")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
        }
    }
}

extension ReportView {
    private func reportOptionRow(title: String, index: Int) -> some View {
        VStack {
            HStack {
                Text(title)
                    .textStyle(.subtitleL)
                    .foregroundColor(.black)
                    .padding(.vertical, 24)
                
                if title == "기타" {
                    Text("(직접 작성)")
                        .foregroundStyle(.textInfo)
                        .textStyle(.subtitleXS)
                }
                
                Spacer()
                
                Circle()
                    .strokeBorder(Color.gray, lineWidth: 1)
                    .background(
                        Circle()
                            .fill(store.selectedIndex == index ? Color.blue100 : Color.clear)
                            .padding(5)
                    )
                    .frame(width: 24, height: 24)
            }
            .asButton {
                if title != "기타" {
                    hideKeyboard()
                }
                store.send(.viewEvent(.tappedCheckButton(index)))
            }
            
            if title != "기타" {
                Divider()
                    .foregroundStyle(.gray50)
            }
        }
        .padding(.horizontal, 15)
    }
}
