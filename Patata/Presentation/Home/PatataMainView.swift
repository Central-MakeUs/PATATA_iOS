//
//  PatataMainView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

//

import SwiftUI
import ComposableArchitecture

struct PatataMainView: View {
    @Perception.Bindable var store: StoreOf<PatataMainFeature>
    
    @State var categoryRatio: CGFloat = .zero
    
    private let spacing: CGFloat = 30
    private let sideCardVisibleRatio: CGFloat = 0.18
    private let scaleEffect: CGFloat = 1.1
    
    @State private var contentOffsetX: CGFloat = 0
    @State private var cardWidth: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    
    @State private var currentIndex = 0 {
        didSet {
            scrollToCurrentPage()
        }
    }
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .background(.gray20)
                .navigationBarBackButtonHidden()
        }
    }
}

extension PatataMainView {
    private var contentView: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let sideCardWidth = screenWidth * sideCardVisibleRatio
            
            VStack {
                fakeNavgationBar
                
                WithPerceptionTracking {
                    ScrollView(.vertical) {
                        PASearchBar(placeHolder: "검색어를 입력하세요")
                            .padding(.horizontal, 15)
                            .asButton {
                                store.send(.viewEvent(.tappedSearch))
                            }
                        
                        bestSpotBar
                            .padding(.top, 18)
                            .padding(.horizontal, 15)
                        
                        setSizeRecommendSpots(sideCardWidth: sideCardWidth)
                            .padding(.vertical, 16)
                            .onAppear {
                                if cardWidth == 0 {
                                    
                                    cardWidth = screenWidth * 0.65
                                    contentHeight = cardWidth * 1.345
                                    
                                    contentOffsetX = -(cardWidth + spacing)
                                }
                            }
                        
                        spotCategory
                            .padding(.horizontal, 15)
                            .padding(.top, 8)
                        
                        categoryRecommendView
                            .padding(.horizontal, 15)
                            .padding(.top, 35)
                        
                        CategoryRecommendView()
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .padding(.horizontal, 15)
                            .padding(.top, 15)
                            .onTapGesture {
                                store.send(.viewEvent(.tappedSpot))
                            }
                        
                        moreButton
                            .padding(.top, 8)
                            .padding(.horizontal, 15)
                            .padding(.bottom, 10)
                            .asButton {
                                store.send(.viewEvent(.tappedAddButton))
                            }
                    }
                }
            }
        }
    }
    
    private var fakeNavgationBar: some View {
        HStack {
            Text("patata")
                .foregroundStyle(.blue100)
                .textStyle(.headlineM)
                .padding(.leading, 15)
            Spacer()
        }
    }
    
    private var bestSpotBar: some View {
        HStack {
            Text("오늘의 추천 스팟")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
            
            Spacer()
            
            HStack(spacing: 0) {
                Text("더보기")
                    .textStyle(.bodyS)
                    .foregroundStyle(.textInfo)
                
                Image("NextInactive")
            }
        }
    }
    
    private var spotCategory: some View {
        VStack {
            HStack {
                Text("스팟 카테고리")
                    .textStyle(.subtitleL)
                    .foregroundStyle(.textDefault)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(1..<6) { index in
                    categoryView(categoryItem: store.categoryItems[index])
                        .frame(maxWidth: .infinity)
                        .aspectRatio(1.22, contentMode: .fit)
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                        .shadow(color: .shadowColor, radius: 8)
                }
            }
        }
    }
    
    private var categoryRecommendView: some View {
        VStack {
            HStack {
                Text("카테고리별 추천")
                    .textStyle(.subtitleL)
                    .foregroundStyle(.textDefault)
                
                Spacer()
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(Array(store.categoryItems.enumerated()), id: \.element.id) { index, item in
                        CategoryView(categoryItem: item, isSelected: store.selectedIndex == index) {
                            store.send(.viewEvent(.selectCategory(index)))
                        }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var moreButton: some View {
        HStack(spacing: 0) {
            Spacer()
            
            Text("더보기")
                .textStyle(.subtitleM)
                .padding(.vertical, 8)
            
            Image("NextActive")
            
            Spacer()
        }
        .foregroundStyle(.textDefault)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension PatataMainView {
    private func scrollToCurrentPage() {
        let baseOffset = -(cardWidth + spacing)
        let totalCount = store.recommendItem.item.count
        
        withAnimation(.linear(duration: 0.3)) {
            contentOffsetX = baseOffset * CGFloat(currentIndex + 1)
        }
        
        // 끝에 도달했을 때 반대편으로 이동
        if currentIndex >= totalCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.none) {
                    contentOffsetX = baseOffset
                    currentIndex = 0
                }
            }
        } else if currentIndex < 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.none) {
                    contentOffsetX = baseOffset * CGFloat(totalCount)
                    currentIndex = totalCount - 1
                }
            }
        }
    }
    
    private func setSizeRecommendSpots(sideCardWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(-1..<store.recommendItem.item.count + 1, id: \.self) { i in
                        let adjustedIndex = i < 0 ? store.recommendItem.item.count - 1 : (i >= store.recommendItem.item.count ? 0 : i)
                        
                        let progress = -dragOffset / (cardWidth + spacing)
                        
                        let scale: CGFloat = {
                            let totalCount = store.recommendItem.item.count
                            let normalizedCurrentIndex = ((currentIndex % totalCount) + totalCount) % totalCount
                            let normalizedAdjustedIndex = ((adjustedIndex % totalCount) + totalCount) % totalCount
                            
                            let isCurrentCard = normalizedAdjustedIndex == normalizedCurrentIndex
                            let isNextCard = normalizedAdjustedIndex == (normalizedCurrentIndex + 1) % totalCount
                            let isPrevCard = normalizedAdjustedIndex == (normalizedCurrentIndex - 1 + totalCount) % totalCount
                            
                            if isCurrentCard {
                                return scaleEffect - (abs(progress) * (scaleEffect - 1.0))
                            } else if (isNextCard && dragOffset < 0) || (isPrevCard && dragOffset > 0) {
                                return 1.0 + (abs(progress) * (scaleEffect - 1.0))
                            }
                            return 1.0
                        }()
                        
                        TodayRecommendView(string: store.recommendItem.item[adjustedIndex])
                            .frame(width: cardWidth, height: contentHeight)
                            .shadow(color: .shadowColor, radius: 8)
                            .scaleEffect(scale)
                            .animation(.smooth, value: dragOffset)
                            .onTapGesture {
                                store.send(.viewEvent(.tappedSpot))
                            }
                    }
                }
                .offset(x: contentOffsetX + dragOffset)
                .padding(.horizontal, sideCardWidth)
                .frame(height: contentHeight * scaleEffect + 50)
                .simultaneousGesture(

                    DragGesture(minimumDistance: 1)
                        .onChanged { value in
                            let verticalDrag = abs(value.translation.height)
                            let horizontalDrag = abs(value.translation.width)
                            
                            if verticalDrag > horizontalDrag {
                                return
                            }
                            
                            let velocityThreshold: CGFloat = 800
                            let velocity = abs(value.predictedEndTranslation.width - value.translation.width)
                            
                            if velocity < velocityThreshold {
                                withAnimation(.linear(duration: 0.1)) {
                                    dragOffset = value.translation.width
                                }
                            } else {
                                dragOffset = value.translation.width
                            }
                        }
                        .onEnded { value in
                            let verticalDrag = abs(value.translation.height)
                            let horizontalDrag = abs(value.translation.width)
                            
                            if verticalDrag > horizontalDrag {
                                withAnimation(.smooth(duration: 0.3)) {
                                    dragOffset = 0
                                }
                                return
                            }
                            
                            withAnimation(.smooth(duration: 0.3)) {
                                dragOffset = 0
                                if value.translation.width < -30 {
                                    currentIndex += 1
                                } else if value.translation.width > 30 {
                                    currentIndex -= 1
                                }
                            }
                        }
                )
            }
            .scrollDisabled(true)
            .frame(height: contentHeight * scaleEffect + 20)
            .padding(.vertical, 10)
        }
        .frame(height: contentHeight * scaleEffect)
    }
    
    private func categoryView(categoryItem: CategoryItem) -> some View {
        VStack(alignment: .center, spacing: 8) {
            Image(categoryItem.images)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 29, height: 36)
            
            Text(categoryItem.item)
                .textStyle(.captionS)
                .foregroundStyle(.textDefault)
        }
        .padding(.vertical, 8)
    }
}
