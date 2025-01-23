//
//  PatataMainView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI
import ComposableArchitecture

struct PatataMainView: View {
    @Perception.Bindable var store: StoreOf<PatataMainFeature>
    
    let spacing: CGFloat = 30
    let sideCardVisibleRatio: CGFloat = 0.18
    let scaleEffect: CGFloat = 1.05
    
    @State private var contentOffsetX: CGFloat = 0
    @State private var cardWidth: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    @State private var currentIndex = 0 {
        didSet {
            scrollToCurrentPage()
        }
    }
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .background(.gray20)
        }
    }
}

extension PatataMainView {
    private var contentView: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let sideCardWidth = screenWidth * sideCardVisibleRatio
            
            WithPerceptionTracking {
                ScrollView(.vertical) {
                    HStack {
                        Text("patata")
                            .foregroundStyle(.blue100)
                            .textStyle(.headlineM)
                            .padding(.leading, 15)
                        Spacer()
                    }
                    
                    PASearchBar(placeHolder: "검색어를 입력하세요")
                        .padding(.horizontal, 15)
                        .asButton {
                            store.send(.viewEvent(.tappedSearch))
                        }
                    
                    bestSpotBar
                        .padding(.top, 25)
                        .padding(.horizontal, 15)
                    
                    setSizeRecommendSpots(sideCardWidth: sideCardWidth)
                        .shadow(radius: 4)
                        .padding(.top, 30)
                        .onAppear {
                            cardWidth = screenWidth * 0.65
                            contentHeight = screenHeight / 2.1
                            
                            let initialOffset = -(cardWidth + spacing)
                            contentOffsetX = initialOffset
                        }
                    
                    spotCategory
                        .shadow(radius: 8)
                        .padding(.horizontal, 15)
                        .padding(.top, 35)
                    
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
            
            HStack {
                ForEach(0..<5) { _ in
                    categoryView
                        .frame(height: 80)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 12)
                        )
                }
            }
        }
    }
    
    private var categoryView: some View {
        VStack(alignment: .center) {
            Image("RecommendIcon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 29, height: 36)
                .padding(.all, 5)
            
            Text("작가 추천")
                .textStyle(.captionS)
                .foregroundStyle(.textDefault)
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
        withAnimation(.linear(duration: 0.3)) {
            let baseOffset = -(cardWidth + spacing)
            
            if currentIndex >= store.recommendItem.item.count {
                contentOffsetX = baseOffset * CGFloat(store.recommendItem.item.count + 1)
//                Task.sleep(for: .now() + 0.3)
                Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    withAnimation(.none) {
                        contentOffsetX = baseOffset
                        currentIndex = 0
                    }
                }
            } else if currentIndex < 0 {
                contentOffsetX = 0
                Task {
                    try? await Task.sleep(for: .milliseconds(300))
                    withAnimation(.none) {
                        contentOffsetX = baseOffset * CGFloat(store.recommendItem.item.count)
                        currentIndex = store.recommendItem.item.count - 1
                    }
                }
            } else {
                contentOffsetX = baseOffset * CGFloat(currentIndex + 1)
            }
        }
    }
    
    private func setSizeRecommendSpots(sideCardWidth: CGFloat) -> some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(-1..<store.recommendItem.item.count + 1, id: \.self) { i in
                        let adjustedIndex = i < 0 ? store.recommendItem.item.count - 1 : (i >= store.recommendItem.item.count ? 0 : i)
                        let isCurrentIndex = adjustedIndex == (currentIndex % store.recommendItem.item.count)
                        
                        TodayRecommendView(string: store.recommendItem.item[adjustedIndex])
                            .frame(width: cardWidth, height: contentHeight)
                            .scaleEffect(isCurrentIndex ? scaleEffect : 1.0)
                            .onTapGesture {
                                store.send(.viewEvent(.tappedSpot))
                            }
                    }
                }
                .offset(x: contentOffsetX)
                .padding(.horizontal, sideCardWidth)
                .padding(.vertical, 10)
            }
            .scrollDisabled(true)
            .frame(height: contentHeight * scaleEffect + 20)
            .padding(.top, 10)
            .padding(.bottom, 10)
            
            Spacer()
        }
        .frame(height: contentHeight)
        .gesture(
            DragGesture()
                .onEnded { value in
                    if value.translation.width < 0 && value.translation.width < -30 {
                        currentIndex += 1
                    } else if value.translation.width > 0 && value.translation.width > 30 {
                        currentIndex -= 1
                    }
                }
        )
    }
}
