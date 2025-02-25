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
        VStack(spacing: 0) {
            fakeNavgationBar
                .padding(.bottom, 14)
                .background(.white)
            
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    ForEach(Array(store.reportOption.enumerated()), id: \.element) { index, option in
                        reportOptionRow(title: option.description(for: store.viewState), index: index)
                        if option == .other {
                                TextEditor(text: $store.textFieldText.sending(\.bindingTextFieldText))
                                    .textStyle(.subtitleS)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .frame(height: 200)
                                    .background(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .overlay(alignment: .topLeading) {
                                        HStack {
                                            if store.textFieldText.isEmpty {
                                                Text("신고내용을 입력해주세요. (최대 300자)")
                                                    .textStyle(.bodyS)
                                                    .foregroundColor(.textDisabled)
                                                    .padding(.leading, 15)
                                            }
                                        }
                                        .padding(.horizontal, 6)
                                        .padding(.top, 14)
                                    }
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isFocused ? Color.blue : Color.gray, lineWidth: 1)
                                    }
                                    .padding(.horizontal, 15)
                                    .onChange(of: store.textFieldText) { newValue in
                                        store.send(.viewEvent(.textValidation(newValue)))
                                    }
                                    .onChange(of: isFocused) { isFocused in
                                        if isFocused {
                                            store.send(.viewEvent(.tappedCheckButton(3)))
                                        }
                                    }
                            
                            
                            HStack {
                                Spacer()
                                
                                Text("\(store.textFieldText.count)/300")
                                    .textStyle(.captionS)
                                    .foregroundColor(.textDisabled)
                                    .padding(.trailing, 15)
                            }
                        }
                        
                    }
                }
            }
            
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
            
            Text(store.viewState == .post ? "게시글 신고하기" : "사용자 신고하기" )
                .textStyle(.subtitleM)
                .foregroundStyle(.textDefault)
        }
    }
}

extension ReportView {
    private func reportOptionRow(title: String, index: Int) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                Text(title)
                    .textStyle(.subtitleM)
                    .foregroundColor(.black)
                
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
            .padding(.vertical, 20)
            .asButton {
                if title != "기타" {
                    hideKeyboard()
                }
                store.send(.viewEvent(.tappedCheckButton(index)))
            }
            
            if title != "기타" {
                Divider()
                    .background(.gray50)
            }
        }
        .padding(.horizontal, 15)
    }
}
