//
//  SpotDetailView.swift
//  Patata
//
//  Created by 김진수 on 1/22/25.
//

import SwiftUI
import ComposableArchitecture

// 어떤 카테고리와 그 해당하는 이미지를 받아야됨

// 일단 맵에서 불러오는지 확인해야됨 -> 맵 일때는 뷰를 그리기전에 scrollEnable의 값에 따라 보여주는 화면이 다르기 때문이다.
// 그럼 굳이 값을 두 개로 나눌 필요가 있냐 -> 

struct SpotDetailView: View {
    
    @Perception.Bindable var store: StoreOf<SpotDetailFeature>
    
    @Environment(\.isScrollEnabled) var scrollEnable
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarHidden(true)
                .presentBottomSheet(isPresented: $store.bottomSheetIsPresent.sending(\.bindingBottomSheetIsPresent)) {
                    BottomSheetItem(items: ["게시글 신고하기", "사용자 신고하기"]) { _ in
                        store.send(.viewEvent(.bottomSheetClose))
                    }
                }
        }
    }
}

extension SpotDetailView {
    private var contentView: some View {
        VStack {
            if !store.isHomeCoordinator && scrollEnable {
                fakeNavBar
                    .background(.white)
            } else if store.isHomeCoordinator {
                fakeNavBar
                    .background(.white)
            }
            
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
            .scrollDisabled(store.isHomeCoordinator ? false : (scrollEnable ? false : true))
            
            VStack {
                commentTextField
                    .padding(.top, 5)
                    .padding(.horizontal, 15)
                    .padding(.bottom, 10)
            }

        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    private var fakeNavBar: some View {
        ZStack {
            HStack {
//                NavBackButton {
//                    hideKeyboard()
//                    store.send(.viewEvent(.tappedNavBackButton))
//                }
//                .padding(.leading, 15)
                
                if scrollEnable {
                    Image("XActive")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(.leading, 15)
                        .asButton {
                            store.send(.viewEvent(.tappedDismissIcon))
                        }
                } else {
                    NavBackButton {
                        hideKeyboard()
                        store.send(.viewEvent(.tappedNavBackButton))
                    }
                    .padding(.leading, 15)
                }
                
                Spacer()
            }
            
            Text("작가 추천")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            HStack {
                Spacer()
                
                Image("ComplaintActive")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    .padding(.trailing, 15)
                    .asButton {
                        hideKeyboard()
                        store.send(.viewEvent(.bottomSheetOpen))
                    }
            }
        }
    }
    
    private var spotDetailImage: some View {
        TabView(selection: $store.currentIndex.sending(\.bindingCurrentIndex)) {
            ForEach(0..<2) { index in
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .foregroundStyle(index == 0 ? .red : .blue)
            }
        }
        .frame(maxWidth: .infinity)
        .scrollDisabled(false)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .aspectRatio(1, contentMode: .fit)
        .overlay(alignment: .bottom) {
            CustomPageIndicator(
                numberOfPages: 2,
                currentIndex: store.currentIndex
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
                
                SpotArchiveButton(height: 24, width: 24, isSaved: $store.saveIsTapped.sending(\.bindingSaveIsTapped)) {
                    hideKeyboard()
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
                text: $store.commentText.sending(\.bindingCommentText),
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

extension SpotDetailView {
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
