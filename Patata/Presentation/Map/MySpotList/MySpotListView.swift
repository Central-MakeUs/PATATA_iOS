//
//  MySpotListView.swift
//  Patata
//
//  Created by 김진수 on 2/3/25.
//

import SwiftUI
import ComposableArchitecture

struct MySpotListView: View {
    @Perception.Bindable var store: StoreOf<MySpotListFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden()
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension MySpotListView {
    private var contentView: some View {
        VStack(spacing: 0) {
            if store.viewState != .home {
                VStack(spacing: 0) {
                    fakeNavgationBar
                    
                    if store.viewState != .home {
                        scrollMenuView
                            .padding(.top, 12)
                            .padding(.horizontal, 15)
                    }
                }
            } else {
                fakeNavgationBar
                    .padding(.bottom, 14)
            }
            
            if store.viewState != .home {
                if store.mapSpotEntity.isEmpty {
                    Spacer()
                    
                    noSpotView
                    
                    Spacer()
                } else {
                    ScrollView(.vertical) {
                        VStack {
                            ForEach(Array(store.mapSpotEntity.enumerated()), id: \.element.id) { index, item in
                                mapSpotView(spot: item, index: index)
                                    .background(.white)
                                    .asButton {
                                        store.send(.viewEvent(.tappedSpot(item.spotId)))
                                    }
                            }
                        }
                        .padding(.top, 12
                        )
                    }
                    .background(.gray10)
                    
                }
            } else {
                ScrollView(.vertical) {
                    VStack {
                        ForEach(Array(store.spotListEntity.enumerated()), id: \.element.id) { index, item in
                            spotListView(spot: item, index: index)
                                .background(.white)
                                .asButton {
                                    store.send(.viewEvent(.tappedSpot(item.spotId)))
                                }
                        }
                    }
                    .padding(.top, 8)
                }
                .background(.gray10)
            }
            
        }
    }
    
    private var fakeNavgationBar: some View {
        Group {
            if store.viewState != .home {
                HStack(spacing: 5) {
                    Image("MapActive")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.blue100)
                        .asButton {
                            store.send(.viewEvent(.tappedBackButton))
                        }
                    
                    HStack {
                        Text("장소 또는 위치명을 검색해 보세요")
                            .textStyle(.bodyS)
                            .foregroundColor(.textDisabled)
                        
                        Spacer()
                        
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.gray70)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 18)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .strokeBorder(.gray20, lineWidth: 1)
                            .background(.gray10)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                    )
                    .asButton {
                        store.send(.viewEvent(.tappedSearch))
                    }
                }
                .padding(.horizontal, 15)
            } else {
                ZStack {
                    HStack {
                        NavBackButton {
                            store.send(.viewEvent(.tappedBackButton))
                        }
                        .padding(.leading, 15)
                        
                        Spacer()
                    }
                    
                    Text("오늘의 추천 스팟")
                        .textStyle(.subtitleL)
                        .foregroundStyle(.textDefault)
                }
            }
        }
    }
    
    private var scrollMenuView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(Array(store.titles.enumerated()), id: \.element) { index, title in
                        let menuItem = MenuItem(title: title, isSelected: store.selectedIndex == index)
                        categoryMenuView(item: menuItem)
                            .fixedSize(horizontal: true, vertical: true)
                            .id(index)
                            .asButton {
                                store.send(.viewEvent(.selectedMenu(index)))
                                withAnimation {
                                    proxy.scrollTo(index, anchor: .center)
                                }
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var noSpotView: some View {
        VStack {
            Image("SearchFail")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 130, height: 150)
            
            VStack(alignment: .center) {
                Text("이런! 주변에 스팟이 없어요")
                Text("파타타와 함께 스팟을 채워가요!")
            }
            .textStyle(.subtitleL)
            .foregroundStyle(.textDisabled)
        }
    }
}

extension MySpotListView {
    private func categoryMenuView(item: MenuItem) -> some View {
        Text(item.title)
            .textStyle(.subtitleS)
            .foregroundColor(item.isSelected ? .black : .textDisabled)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .offset(y: item.isSelected ? -5 : 0)
            .overlay {
                if item.isSelected {
                    Spacer()
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(.black)
                        .offset(y: item.isSelected ? 15 : 0)
                }
            }
        
    }
    
    private func spotListView(spot: TodaySpotListEntity, index: Int) -> some View {
        VStack {
            spotItemListView(spot: spot, index: index)
                .padding(.horizontal, 15)
            
            spotImageView(spotImage: spot.images)
                .padding(.bottom, 15)
        }
    }
    
    private func spotItemListView(spot: TodaySpotListEntity, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                if spot.categoryId == .recommendSpot {
                    Text("작가추천")
                        .textStyle(.captionS)
                        .foregroundStyle(.blue50)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.navy100)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                
                Text(spot.spotName)
                    .textStyle(.subtitleSM)
                    .foregroundStyle(.blue100)
                
                HStack(spacing: 6) {
                    Image(spot.categoryId.getCategoryCase().image ?? "SnapIcon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                    
                    Text(spot.categoryId.getCategoryCase().title)
                        .foregroundStyle(.gray70)
                        .textStyle(.subtitleXS)
                }
                
                Spacer()

                SpotArchiveButton(height: 24, width: 24, isSaved: spot.isScraped) {
                    store.send(.viewEvent(.tappedArchiveButton(index)))
                }
            }
            .padding(.top, 16)
            
            HStack(spacing: 4) {
                Text(spot.distance)
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textSub)
                
                Text("\(spot.spotAddress) \(spot.spotAddressDetail)")
                    .lineLimit(1)
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textInfo)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(Array(spot.tags.enumerated()), id: \.offset) { _, tag in
                    Text("#\(tag)")
                        .hashTagStyle()
                }
            }
        }
    }
    
    private func mapSpotView(spot: MapSpotEntity, index: Int) -> some View {
        VStack {
            mapSpotItemView(spot: spot, index: index)
                .padding(.horizontal, 15)
            
            spotImageView(spotImage: spot.images)
                .padding(.bottom, 15)
        }
    }
    
    private func mapSpotItemView(spot: MapSpotEntity, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                if spot.category == .recommendSpot {
                    Text("작가추천")
                        .textStyle(.captionS)
                        .foregroundStyle(.blue50)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(.navy100)
                        .clipShape(RoundedRectangle(cornerRadius: 22))
                }
                
                Text(spot.spotName)
                    .textStyle(.subtitleS)
                    .foregroundStyle(.blue100)
                
                Image(spot.category.getCategoryCase().image ?? "SnapIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
                
                Text(spot.category.getCategoryCase().title)
                    .foregroundStyle(.gray70)
                    .textStyle(.captionS)
                
                Spacer()

                SpotArchiveButton(height: 24, width: 24, isSaved: spot.isScraped) {
                    store.send(.viewEvent(.tappedArchiveButton(index)))
                }
            }
            .padding(.top, 16)
            
            HStack(spacing: 4) {
                Text(spot.distance)
                    .textStyle(.captionS)
                    .foregroundStyle(.textSub)
                
                Text("\(spot.spotAddress) \(spot.spotAddressDetail)")
                    .lineLimit(1)
                    .textStyle(.captionS)
                    .foregroundStyle(.textInfo)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                ForEach(Array(spot.tags.enumerated()), id: \.offset) { _, tag in
                    Text("#\(tag)")
                        .hashTagStyle()
                }
            }
        }
    }
    
    private func spotImageView(spotImage: [URL?]) -> some View {
        let imageWidth: CGFloat = UIScreen.main.bounds.width - 30
        let imageDefault = "ImageDefault"
        
        return Group {
            if spotImage.count == 1{
                DownImageView(url: spotImage[0], option: .custom(CGSize(width: 600, height: 600)), fallBackImg: imageDefault)
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .frame(height: imageWidth * 0.5)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 15)
            } else if spotImage.count == 2 {
                HStack(spacing: 8) {
                    ForEach(Array(zip(spotImage.indices, spotImage.compactMap { $0 })), id: \.0) { index, image in
                        DownImageView(url: image, option: .max, fallBackImg: imageDefault)
                            .aspectRatio(1, contentMode: .fill)
                            .frame(width: (imageWidth - 8) / 2)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 15)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(Array(zip(spotImage.indices, spotImage.compactMap { $0 })), id: \.0) { index, image in
                            DownImageView(url: image, option: .mid, fallBackImg: imageDefault)
                                .aspectRatio(1, contentMode: .fill)
                                .frame(width: (imageWidth - 8) / 2.5)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(.horizontal, 15)
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}
