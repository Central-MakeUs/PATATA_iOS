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
    
    var isSaved: Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarHidden(true)
                .presentBottomSheet(isPresented: $store.bottomSheetIsPresent.sending(\.bindingBottomSheetIsPresent)) {
                    if store.spotDetailData.memberName != UserDefaultsManager.nickname {
                        BottomSheetItem(items: ["게시글 신고하기", "사용자 신고하기"]) { _ in
                            store.send(.viewEvent(.bottomSheetClose))
                        }
                    } else {
                        BottomSheetItem(items: ["게시글 수정하기", "게시글 삭제하기"]) { _ in
                            store.send(.viewEvent(.bottomSheetClose))
                        }
                    }
                }
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension SpotDetailView {
    private var contentView: some View {
        VStack {
            fakeNavBar
                .background(.white)
            
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
                    
                    reviewView(items: store.spotDetailData.reviews)
                    
                }
                .background(.white)
                .padding(.top, 0)
                .offset(y: -28)
            }
            .background(.gray20)
            
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
                NavBackButton {
                    hideKeyboard()
                    store.send(.viewEvent(.tappedNavBackButton))
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            HStack {
                Image(store.spotDetailData.categoryId.getCategoryCase().image ?? "ImageDefault")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
                
                Text(store.spotDetailData.categoryId.getCategoryCase().title)
                    .textStyle(.subtitleL)
                    .foregroundStyle(.textDefault)
            }
            
            HStack {
                Spacer()
                
                if store.spotDetailData.memberName != UserDefaultsManager.nickname {
                    Image("ComplaintActive")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .padding(.trailing, 15)
                        .asButton {
                            hideKeyboard()
                            store.send(.viewEvent(.bottomSheetOpen))
                        }
                } else {
                    Image("MoreIcon")
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
    }
    
    private var spotDetailImage: some View {
        TabView(selection: $store.currentIndex.sending(\.bindingCurrentIndex)) {
            ForEach(Array(store.spotDetailData.images.enumerated()), id: \.offset) { _, image in
                DownImageView(url: image, option: .max, fallBackImg: "ImageDefault")
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(maxWidth: .infinity)
        .aspectRatio(1, contentMode: .fit)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .overlay(alignment: .bottom) {
            CustomPageIndicator(
                numberOfPages: store.spotDetailData.images.count,
                currentIndex: store.currentIndex
            )
            .padding(.bottom, 40)
        }
    }
    
    private var detailView: some View {
        VStack(spacing: 0) {
            HStack {
                // spotTitleView
                Text(store.spotDetailData.spotName)
                    .textStyle(.headlineS)
                    .foregroundStyle(.textDefault)
                
                Spacer()
                
                SpotArchiveButton(height: 24, width: 24, isSaved: store.spotDetailData.isScraped) {
                    hideKeyboard()
                } onToggleScrap: {
                    store.send(.viewEvent(.tappedArchiveButton))
                }
            }
            .padding(.top, 33)
            .padding(.horizontal, 30)
            
            // 유저
            HStack {
                Text(store.spotDetailData.memberName)
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textDefault)
                
                Spacer()
            }
            .padding(.top, 6)
            .padding(.horizontal, 30)
            
            // 주소와 주소 복사
            HStack {
                Text(store.spotDetailData.spotAddress)
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
                Text(store.spotDetailData.spotDescription)
                    .textStyle(.captionM)
                    .foregroundStyle(.textSub)
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal, 30)
            
            // hashTag
            HStack {
                ForEach(store.spotDetailData.tags, id: \.self) { tag in
                    Text("#" + tag)
                        .hashTagStyle(backgroundColor: .blue10, textColor: .gray80, font: .captionS)
                }
                
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
            Text(String(store.spotDetailData.reviewCount))
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

extension SpotDetailView {
    private func reviewView(items: [SpotDetailReviewEntity]) -> some View {
        ForEach(Array(items.enumerated()), id: \.element.reviewId) { index, item in
            commentView(nick: item.memberName, text: item.reviewText, date: Date(), user: UserDefaultsManager.nickname == item.memberName)
                .background(.white)
                .padding(.vertical, 12)
            
            if index != items.count - 1 {
                Divider()
                    .frame(height: 0.3)
                    .background(.blue100)
            }
        }
    }
}
