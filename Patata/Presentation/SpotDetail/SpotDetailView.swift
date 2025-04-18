//
//  SpotDetailView.swift
//  Patata
//
//  Created by 김진수 on 1/22/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

// 어떤 카테고리와 그 해당하는 이미지를 받아야됨

// 일단 맵에서 불러오는지 확인해야됨 -> 맵 일때는 뷰를 그리기전에 scrollEnable의 값에 따라 보여주는 화면이 다르기 때문이다.
// 그럼 굳이 값을 두 개로 나눌 필요가 있냐 -> 

struct SpotDetailView: View {
    
    @Perception.Bindable var store: StoreOf<SpotDetailFeature>
    
    @State private var sizeState: CGSize = .zero
    @State var selectedIndex: Int = 0
    @State var otherIndex: Int = 0
    
    var body: some View {
        WithPerceptionTracking {
            ZStack {
                contentView
                    .navigationBarHidden(true)
                    .customAlert(isPresented: $store.alertIsPresent.sending(\.bindingAlertIsPresent), title: "게시물을 삭제하시겠습니까?", message: "한 번 삭제된 게시물은 복원할 수 없습니다.", cancelText: "취소", confirmText: "삭제") {
                        store.send(.viewEvent(.tappedDeleteButton))
                    }
                    .presentBottomSheet(isPresented: $store.bottomSheetIsPresent.sending(\.bindingBottomSheetIsPresent)) {
                        if !store.spotDetailData.isAuthor {
                            BottomSheetItem(items: ["게시글 신고하기", "사용자 신고하기"], tapChange: false, selectedIndex: $selectedIndex) { text in
                                store.send(.viewEvent(.bottomSheetClose(text)))
                            }
                        } else {
                            BottomSheetItem(delete: true, items: ["게시글 수정하기", "게시글 삭제하기"], tapChange: false, selectedIndex: $otherIndex) { text in
                                store.send(.viewEvent(.bottomSheetClose(text)))
                            }
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
        VStack(spacing: 0) {
            ScrollView(.vertical) {
                ZStack(alignment: .top) {
                    spotDetailImage
                        .offset(y: -8)
                    
                    VStack {
                        Color.clear
                            .frame(height: max(0, sizeState.height - 30))
                        
                        detailView
                            .background(.white)
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                        
                        VStack {
                            commentBar
                                .padding(.top, 10)
                                .padding(.horizontal, 15)
                            
                            Color.gray10
                                .frame(height: 1)
                            
                            if store.reviewData.isEmpty {
                                HStack {
                                    Spacer()
                                    
                                    Text("첫 후기를 남겨보세요!")
                                        .textStyle(.subtitleM)
                                        .foregroundStyle(.textDisabled)
                                    
                                    Spacer()
                                }
                                .frame(height: 150)
                                .background(.white)
                                .padding(.top, 0)
                            }
                            reviewView(items: store.reviewData)
                            
                        }
                        .background(.white)
                        .padding(.top, 0)
                    }
                }
            }
            .redacted(reason: store.spotDetailData.spotName.isEmpty ? .placeholder : [])
            .refreshable {
                store.send(.viewCycle(.onAppear))
            }
            .safeAreaInset(edge: .top) {
                fakeNavBar
                    .padding(.bottom, 14)
                    .background(
                        Color.white
                            .opacity(0.85)
                            .ignoresSafeArea(.all)
                    )
                    .background(
                        BlurView(style: .systemThinMaterial)
                            .opacity(0.8)
                            .ignoresSafeArea(.all)
                    )
            }
            .background(.gray10)
            
            VStack(spacing: 0) {
                Color.black
                    .opacity(0.3)
                    .frame(height: 0.8)
                    .blur(radius: 3)
                    .offset(y: -6)
                
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
                    .textStyle(.subtitleM)
                    .foregroundStyle(.textDefault)
            }
            
            HStack {
                Spacer()
                
                if !store.spotDetailData.isAuthor {
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
        ZStack(alignment: .topTrailing) {
            TabView(selection: $store.currentIndex.sending(\.bindingCurrentIndex)) {
                ForEach(Array(store.spotDetailData.images.enumerated()), id: \.offset) { _, image in
                    DownImageView(url: image, option: .custom(CGSize(width: 650, height: 650)), fallBackImg: "ImageDefault")
                        .aspectRatio(131/140, contentMode: .fit)
                        .frame(maxWidth: UIScreen.main.bounds.width)
                        .frame(height: UIScreen.main.bounds.height * 0.7)
                        .background(.gray30)
                        .clipped()
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .sizeState(size: $sizeState)
            .background(.black)
            .overlay(alignment: .bottom) {
                Group {
                    if store.spotDetailData.images.count != 1 {
                        CustomPageIndicator(
                            numberOfPages: store.spotDetailData.images.count,
                            currentIndex: store.currentIndex,
                            viewState: .spotDetail
                        )
                        .padding(.bottom, 40)
                    }
                }
            }
            
            if store.spotDetailData.categoryId == .recommendSpot {
                RecommendSpotIconMark()
                    .offset(x: -20, y: -5)
            }
        }
    }
    
    private var detailView: some View {
        VStack(spacing: 0) {
            HStack {
                // spotTitleView
                Text(store.spotDetailData.spotName.isEmpty ? "spotDetail" : store.spotDetailData.spotName)
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
                Text(store.spotDetailData.spotName.isEmpty ? "spotDetail" : store.spotDetailData.memberName)
                    .textStyle(.subtitleS)
                    .foregroundStyle(.textDefault)
                
                Spacer()
            }
            .padding(.top, 6)
            .padding(.horizontal, 30)
            
            // 주소와 주소 복사
            HStack {
                Text(store.spotDetailData.spotName.isEmpty ? "spotDetail" : store.spotDetailData.spotAddress)
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textDisabled)
                
                Text("주소복사")
                    .textStyle(.subtitleXS)
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
                Text(store.spotDetailData.spotName.isEmpty ? "spotDetail" : store.spotDetailData.spotDescription)
                    .textStyle(.bodySM)
                    .foregroundStyle(.textSub)
                
                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal, 30)
            
            // hashTag
            HStack {
                ForEach(Array(store.spotDetailData.tags.enumerated()), id: \.offset) { index, tag in
                    Text("#" + tag)
                        .hashTagStyle(backgroundColor: .blue10, textColor: .gray80, font: .captionS, verticalPadding: 8, horizontalPadding: 12, cornerRadius: 20)
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
            Text(String(store.reviewData.count))
                .textStyle(.subtitleS)
                .foregroundStyle(.textInfo)
            
            Spacer()
        }
    }
    
    private var commentTextField: some View {
        HStack {
//            TextField(
//                "comment",
//                text: $store.commentText.sending(\.bindingCommentText),
//                prompt: Text("댓글을 입력하세요")
//                    .foregroundColor(.textDisabled)
//            )
//            .onSubmit {
//                hideKeyboard()
//                store.send(.viewEvent(.tappedOnSubmit))
//            }
//            .textStyle(.bodyS)
            
            DisablePasteTextField(
                text: $store.commentText.sending(\.bindingCommentText),
                isFocused: nil, // nil로 설정하여 내부 포커스 관리를 비활성화
                placeholder: "댓글을 입력하세요",  // 비워두기 - 오버레이에서 처리
                placeholderColor: .textDisabled,
                edge: UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0),
                keyboardType: .default,
                onCommit: {
                    hideKeyboard()
                    store.send(.viewEvent(.tappedOnSubmit))
                }
            )
            .frame(height: 34)
            
            Spacer()
            
            if store.commentText.isEmpty {
                Image("UploadInActive")
                    .padding(.trailing, 8)
                    .asButton {
                        hideKeyboard()
                    }
            } else {
                Image("UploadActive")
                    .padding(.trailing, 8)
                    .asButton {
                        hideKeyboard()
                        store.send(.viewEvent(.tappedOnSubmit))
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(.gray10)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }
}

extension SpotDetailView {
    private func commentView(nick: String, text: String, date: String, user: Bool, reviewId: Int, index: Int) -> some View {
        VStack {
            HStack {
                Text(nick)
                    .textStyle(.subtitleSM)
                    .foregroundStyle(nick == UserDefaultsManager.nickname ? .blue100 : .textSub)
                
                Spacer()
                
                if user {
                    Text("삭제하기")
                        .textStyle(.captionS)
                        .foregroundStyle(.textInfo)
                        .asButton {
                            store.send(.viewEvent(.tappedDeleteReview(reviewId: reviewId, index: index)))
                        }
                } else {
                    Text("신고하기")
                        .textStyle(.captionS)
                        .foregroundStyle(.red100)
                        .asButton {
                            store.send(.viewEvent(.tappedReviewReport(index)))
                        }
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 6)
            
            HStack {
                Text(store.spotDetailData.spotName.isEmpty ? "spotDetail" : text)
                    .textStyle(.bodySM)
                    .foregroundStyle(.textSub)
                
                Spacer()
            }
            .padding(.horizontal, 15)
            
            HStack {
                Text(store.spotDetailData.spotName.isEmpty ? "spotDetail" : date)
                    .textStyle(.captionS)
                
                Spacer()
            }
            .foregroundStyle(.textInfo)
            .padding(.horizontal, 15)
            .padding(.top, 2)
        }
    }
}

extension SpotDetailView {
    private func reviewView(items: [SpotDetailReviewEntity]) -> some View {
        ForEach(Array(items.enumerated()), id: \.element.reviewId) { index, item in
            commentView(nick: item.memberName, text: item.reviewText, date: item.reviewData, user: UserDefaultsManager.nickname == item.memberName, reviewId: item.reviewId, index: index)
                .background(.white)
                .padding(.vertical, 12)
            
            if index != items.count - 1 {
                Color.gray10
                    .frame(height: 2)
            }
        }
    }
}
