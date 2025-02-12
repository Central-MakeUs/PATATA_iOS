//
//  SpotDetailContentView.swift
//  Patata
//
//  Created by 김진수 on 1/27/25.
//

import SwiftUI

struct SpotDetailContentView: View {
    
    @State var currentIndex: Int = 0
    var isSaved: Bool = false
    @State var commentText: String = "fdfdf"
    
    var body: some View {
        contentView
    }
}

extension SpotDetailContentView {
    private var contentView: some View {
        ScrollView(.vertical) {
            spotDetailImage
            
            detailView
                .background(.white)
                .cornerRadius(20, corners: [.topLeft, .topRight])
                .offset(y: -30)
            
            VStack {
                commentBar
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
                
                Divider()
                    .frame(height: 0.35)
                    .background(.blue100)
                
                ForEach(0..<5) { index in
                    commentView(nick: "ddd", text: "dsfadffdsfadasfa\ndsfasdfasfadsfas", date: Date(), user: true)
                        .background(.white)
                        .padding(.vertical, 12)
                    
                    if index != 4 {
                        Divider()
                            .frame(height: 0.3)
                            .background(.blue100)
                    }
                }
                
            }
            .background(.white)
            .padding(.top, 0)
            .offset(y: -28)
        }
        .background(.gray20)
    }
    
    private var spotDetailImage: some View {
        TabView(selection: $currentIndex) {
            ForEach(0..<2) { index in
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(index == 0 ? .red : .blue)
            }
        }
        .frame(maxWidth: .infinity)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .aspectRatio(1, contentMode: .fit)
        .overlay(alignment: .bottom) {
            CustomPageIndicator(
                numberOfPages: 2,
                currentIndex: currentIndex
            )
            .padding(.bottom, 40)
        }
    }
    
    private var detailView: some View {
        VStack(spacing: 0) {
            HStack {
                // spotTitleView
                Text("전쟁기념관 벚꽃 길")
                    .textStyle(.headlineS)
                    .foregroundStyle(.textDefault)
                
                Spacer()
                
                SpotArchiveButton(height: 24, width: 24, isSaved: isSaved) {
                    hideKeyboard()
                } onToggleScrap: {
                    print("tap")
                }
            }
            .padding(.top, 33)
            .padding(.horizontal, 30)
            
            // 유저
            HStack {
                Text("정해원투쓰리")
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textDefault)
                
                Spacer()
            }
            .padding(.top, 6)
            .padding(.horizontal, 30)
            
            // 주소와 주소 복사
            HStack {
                Text("서울특별시 용산구 가나다길 441-49 두번째 계단")
                    .textStyle(.captionS)
                    .foregroundStyle(.textDisabled)
                
                Text("주소복사")
                    .textStyle(.captionS)
                    .foregroundStyle(.blue100)
                    .onTapGesture {
                        hideKeyboard()
                        print("tap")
                    }
                
                Spacer()
            }
            .padding(.top, 2)
            .padding(.horizontal, 30)
            
            HStack {
                Text("여기는 Text 공간입니다.")
                    .textStyle(.captionM)
                    .foregroundStyle(.textSub)
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal, 30)
            
            // hashTag
            HStack {
                Text("#가을사진")
                    .hashTagStyle(backgroundColor: .blue10, textColor: .gray80, font: .captionS)
                
                Text("#자연스팟")
                    .hashTagStyle(backgroundColor: .blue10, textColor: .gray80, font: .captionS)
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        }
        
    }
    
    private var commentBar: some View {
        HStack {
            Image("CommentInactive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            // 댓글 수
            Text("2")
                .textStyle(.subtitleS)
                .foregroundStyle(.textInfo)
            
            Spacer()
        }
    }
    
    private var commentTextField: some View {
        HStack {
            TextField(
                "comment",
                text: $commentText,
                prompt: Text("댓글을 입력하세요")
                    .foregroundColor(.textDisabled)
            )
            .onSubmit {
                hideKeyboard()
            }
            .textStyle(.bodyS)
            
            Spacer()
            
            Image("UploadInActive")
                .foregroundStyle(.gray70)
                .asButton {
                    hideKeyboard()
                }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.gray20)
        .clipShape(RoundedRectangle(cornerRadius: 25))
        
    }
}

extension SpotDetailContentView {
    private func commentView(nick: String, text: String, date: Date, user: Bool) -> some View {
        VStack {
            HStack {
                Text(nick)
                    .textStyle(.subtitleM)
                    .foregroundStyle(.textSub)
                
                Spacer()
                
                Text("삭제하기")
                    .textStyle(.captionS)
                    .foregroundStyle(.textInfo)
            }
            .padding(.horizontal, 15)
            
            HStack {
                Text(text)
                    .textStyle(.bodyM)
                    .foregroundStyle(.textSub)
                
                Spacer()
            }
            .padding(.horizontal, 15)
            
            HStack {
                Text(date, style: .date)
                    .textStyle(.captionM)
                
                Text(date, style: .time)
                    .textStyle(.captionM)
                
                Spacer()
            }
            .foregroundStyle(.textInfo)
            .padding(.horizontal, 15)
        }
    }
}
