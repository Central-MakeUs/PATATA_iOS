//
//  PatataMainView.swift
//  Patata
//
//  Created by 김진수 on 1/15/25.
//

import SwiftUI

// ["전체", "작가 추천", "스냅스팟", "시크한 야경", "싱그러운 자연"]
// ["RecommendIcon", "RecommendIcon", "RecommendIcon", "RecommendIcon", "RecommendIcon"]

struct PatataMainView: View {
    let items = ["a", "b", "c"]
    let spacing: CGFloat = 30
    let sideCardVisibleRatio: CGFloat = 0.18
    let scaleEffect: CGFloat = 1.05
    
    @State var selectedIndex = 0
    
    var categoryItems = [
        CategoryItem(
            item: "전체",
            images: "RecommendIcon"
        ),
        CategoryItem(
            item: "작가 추천",
            images: "RecommendIcon"
        ),
        CategoryItem(
            item: "스냅스팟",
            images: "RecommendIcon"
        ),
        CategoryItem(
            item: "시크한 야경",
            images: "RecommendIcon"
        ),
        CategoryItem(
            item: "싱그러운 자연",
            images: "RecommendIcon"
        )
    ]
    
    @State private var contentOffsetX: CGFloat = 0
    @State private var cardWidth: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    @State private var categorySelect: Bool = false
    
    @State private var currentIndex = 0 {
        didSet {
            scrollToCurrentPage()
        }
    }
    
    var body: some View {
        contentView
            .background(.gray20)
    }
}

extension PatataMainView {
    private var contentView: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            let screenHeight = geometry.size.height
            let sideCardWidth = screenWidth * sideCardVisibleRatio
            
            ScrollView(.vertical) {
                HStack {
                    Text("patata")
                        .foregroundStyle(.blue100)
                        .textStyle(.headlineM)
                        .padding(.leading, 15)
                    Spacer()
                }
                paSearchBar
                    .padding(.horizontal, 15)
                
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
                        
                        print(screenHeight)
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
                
                moreButton
                    .padding(.top, 8)
                    .padding(.horizontal, 15)
            }
            
        }
    }
    
    private var paSearchBar: some View {
        HStack {
            Text("검색어를 입력하세요")
                .foregroundStyle(.textDisabled)
                .textStyle(.bodyS)
            
            Spacer()
            
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray70)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .strokeBorder(.gray30, lineWidth: 2)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
        )
        
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
                    ForEach(Array(categoryItems.enumerated()), id: \.element.id) { index, item in
                        CategoryView(categoryItem: item, isSelected: selectedIndex == index) {
                            selectedIndex = index
                        }
                    }
                }
            }
            .scrollDisabled(true)
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
            
            if currentIndex >= items.count {
                contentOffsetX = baseOffset * CGFloat(items.count + 1)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.none) {
                        contentOffsetX = baseOffset
                        currentIndex = 0
                    }
                }
            } else if currentIndex < 0 {
                contentOffsetX = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.none) {
                        contentOffsetX = baseOffset * CGFloat(items.count)
                        currentIndex = items.count - 1
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
                    ForEach(-1..<items.count + 1, id: \.self) { i in
                        let adjustedIndex = i < 0 ? items.count - 1 : (i >= items.count ? 0 : i)
                        let isCurrentIndex = adjustedIndex == (currentIndex % items.count)
                        
                        TodayRecommendView(string: items[adjustedIndex])
                            .frame(width: cardWidth, height: contentHeight)
                            .scaleEffect(isCurrentIndex ? scaleEffect : 1.0)
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

