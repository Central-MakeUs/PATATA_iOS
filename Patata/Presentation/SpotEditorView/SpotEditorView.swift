//
//  SpotEditorView.swift
//  Patata
//
//  Created by 김진수 on 1/30/25.
//

import SwiftUI

struct SpotEditorView: View {
    
    @State private var title: String = ""
    @State private var location: String = ""
    @State private var detail: String = ""
    @State private var hashTag: String = ""
    
    var body: some View {
        contentView
    }
}

extension SpotEditorView {
    private var contentView: some View {
        VStack {
            fakeNav
            
            ScrollView(.vertical) {
                titleText
                    .padding(.vertical, 28)
                    .padding(.horizontal, 15)
                
                locationView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
                
                detailView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
                
                categoryView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
                
                pictureView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
                
                hashtagView
                    .padding(.horizontal, 15)
                    .padding(.bottom, 28)
            }
            .background(.gray20)
            
            VStack {
                spotEditButton
                    .padding(.horizontal, 20)
            }
        }
    }
    
    private var fakeNav: some View {
        ZStack {
            HStack {
                NavBackButton {
                    print("back")
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Text("스팟 추가하기")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            HStack {
                Spacer()
                
                Image("XActive")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 15)
                    .asButton {
                        print("X")
                    }
            }
        }
        
    }
    
    private var titleText: some View {
        VStack {
            titleView("제목을 입력하세요")
            
            textFieldView(bindingText: $title, placeHolder: "제목을 입력하세요 (15자 이내)", key: "title")
        }
    }
    
    private var locationView: some View {
        VStack {
            titleView("상세한 위치를 입력하세요")
            
            HStack {
                Text("아차산로 451 길")
                    .textStyle(.bodyS)
                    .foregroundStyle(.textDisabled)
                    .padding(.leading, 16)
                
                Spacer()
                
                Image("LocationInActive")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 18)
                    .padding(.trailing, 10)
            }
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(.gray30, lineWidth: 2)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
            
            textFieldView(bindingText: $location, placeHolder: "상세한 위치를 입력하세요", key: "location")
        }
    }
    
    private var detailView: some View {
        VStack {
            titleView("간단한 설명을 입력하세요")
            
            TextEditor(text: $detail)
                .textStyle(.subtitleS)
                .frame(maxWidth: .infinity)
                .aspectRatio(2.5, contentMode: .fit)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    VStack(alignment: .leading, spacing: 16) {
                        if detail.isEmpty {
                            Text("장소에 대한 간단한 설명을 남겨하세요 (300자 이하)")
                                .textStyle(.bodyM)
                                .foregroundColor(.textDisabled)
                            
                            Text("부적절한 사진(폭력, 혐오, 선정성 등)은 등록이 금지되며,\n게재 시 경고 또는 이용 제한이 부과될 수 있습니다.")
                                .textStyle(.bodyS)
                                .foregroundColor(.textDisabled)
                        }
                    }
                        .padding(.horizontal, 16)
                        .padding(.top, 12),
                    alignment: .topLeading
                )
        }
    }
    
    private var categoryView: some View {
        VStack {
            titleView("카테고리를 선택해주세요")
            
            HStack {
                Text("카테고리를 선택해주세요")
                    .foregroundColor(.textDisabled)
                    .padding(.leading, 16)
                
                Spacer()
                
                Image("UnderIcon")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 18)
                    .padding(.trailing, 10)
            }
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
    
    private var pictureView: some View {
        VStack {
            titleView("사진을 추가해주세요 (최소 1개)")
            
            ScrollView {
                
                HStack {
                    VStack(alignment: .center) {
                        Image("ImageDefault")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 36)
                            .padding(.top, 15)
                        
                        Text("사진 추가하기")
                            .textStyle(.captionS)
                            .foregroundStyle(.gray60)
                            .padding(.bottom, 15)
                            .padding(.horizontal, 20)
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(.gray30, lineWidth: 1)
                            .background(.gray20)
                    )
                    
                    Spacer()
                    
                }
                
            }
        }
    }
    
    private var hashtagView: some View {
        VStack {
            titleView("해쉬태그를 입력해주세요 (최대 2개)")
            
            textFieldView(bindingText: $hashTag, placeHolder: "#해쉬태그를 입력해주세요", key: "hashTag")
        }
    }
    
    private var spotEditButton: some View {
        // 텍스트필드가 다 채워지면 색 변경
        HStack {
            Spacer()
            
            Text("등록하기")
                .textStyle(.subtitleM)
                .foregroundStyle(.white)
                
            Spacer()
        }
        .padding(.vertical, 14)
        .background(.black)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}

extension SpotEditorView {
    private func textFieldView(bindingText: Binding<String>, placeHolder: String, key: String) -> some View {
        TextField(
            key,
            text: bindingText,
            prompt: Text(
                placeHolder
            ).foregroundColor(
                .textDisabled
            )
        )
        .onSubmit {
            print("submit")
        }
        .textStyle(.subtitleS)
        .frame(maxWidth: .infinity)
        .frame(height: 44)
        .padding(.horizontal, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func titleView(_ text: String) -> some View {
        HStack {
            Text(text)
                .textStyle(.subtitleM)
                .foregroundStyle(.textDefault)
            
            Spacer()
        }
    }
}
