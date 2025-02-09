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
        }
    }
}

extension MySpotListView {
    private var contentView: some View {
        VStack(spacing: 0) {
            VStack {
                fakeNavgationBar
                
                if store.viewState == .map {
                    scrollMenuView
                        .padding(.top, 10)
                        .padding(.horizontal, 15)
                }
            }
            .padding(.bottom, 12)
            .background(.white)
            
            ScrollView(.vertical) {
                VStack {
                    spotItemListView
                        .padding(.horizontal, 15)
                    
                    spotItemImageView
                        .padding(.bottom, 15)
                }
                .background(.white)
                .padding(.vertical, 15)
            }
            .background(.gray20)
        }
    }
    
    private var fakeNavgationBar: some View {
        Group {
            if store.viewState == .map {
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
                            .asButton {
                                print("imageOnSubmit")
                            }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.gray20)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
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
                .padding(.horizontal, 15)
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
            //                .onChange(of: selectedIndex) { newIndex in
            //                    withAnimation {
            //                        proxy.scrollTo(newIndex, anchor: .center)
            //                    }
            //                }
        }
    }
    
    private var spotItemListView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text("작가추천")
                    .textStyle(.captionS)
                    .foregroundStyle(.blue50)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.navy100)
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                
                Text("시청역 어쩌고저쩌고")
                    .textStyle(.subtitleS)
                    .foregroundStyle(.blue100)
                
                Text("category")
                    .foregroundStyle(.gray70)
                    .textStyle(.captionS)
                
                Spacer()
                
                SpotArchiveButton(height: 24, width: 24, isSaved: $store.archive.sending(\.bindingArchive))
            }
            .padding(.top, 16)
            
            HStack(spacing: 4) {
                Text("512 m")
                    .textStyle(.captionS)
                    .foregroundStyle(.textSub)
                
                Text("서울특별시 종로구 가나다길 441-49 두번째 계단")
                    .textStyle(.captionS)
                    .foregroundStyle(.textInfo)
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Text("#야경맛집")
                    .hashTagStyle()
                
                Text("#국회의사당뷰")
                    .hashTagStyle()
            }
        }
    }
    
    private var spotItemImageView: some View {
        let imageWidth: CGFloat = UIScreen.main.bounds.width - 30
        
        return Group {
            if store.imageCount == 1{
                Rectangle()
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity)
                    .frame(height: imageWidth * 0.5)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .padding(.horizontal, 15)
            } else if store.imageCount == 2 {
                HStack(spacing: 8) {
                    ForEach(0..<2) { _ in
                        Rectangle()
                            .foregroundStyle(.red)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: (imageWidth - 8) / 2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .padding(.horizontal, 15)
            } else {
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(0..<4) { _ in
                            Rectangle()
                                .foregroundStyle(.red)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(width: (imageWidth - 8) / 2.5)
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
}
