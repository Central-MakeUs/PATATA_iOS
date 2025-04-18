//
//  SearchResultView.swift
//  Patata
//
//  Created by 김진수 on 1/19/25.
//

import SwiftUI
import ComposableArchitecture

// 컨텐츠 내부 높이 맞춰서 높이가 조정되어야함
// 클릭을 하면 시트가 내려가면서 해당 텍스트를 필터 텍스트에 반영해야함
// 외부 뷰는 흐르게 보여야함
// 외부 뷰를 눌렀을때 dismiss되어야함
// 뷰 상단에 핸들이 있어야함

struct SearchResultView: View {
    
    @Perception.Bindable var store: StoreOf<SearchFeature>
    @State var isPresent: Bool = false
    @State var selectedIndex: Int = 0
    var isSaved: Bool = false
    private let scrollViewTopID = "ScrollTop"
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible())
    ]
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarHidden(true)
                .presentBottomSheet(isPresented: $store.filterIsvalid.sending(\.bindingFilterIsValid)) {
                    BottomSheetItem(title: "정렬", items: ["거리순", "추천순"], selectedIndex: $selectedIndex) { item in
                        store.send(.viewEvent(.dismissFilter(item)))
                    }
                }
        }
    }
}

extension SearchResultView {
    private var contentView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    filterView
                        .padding(.top, 12)
                        .padding(.horizontal, 15)
                        .id(scrollViewTopID)
                    
                    spotGridView
                }
                .background(.gray10)
                .redacted(reason: store.searchSpotItems.isEmpty ? .placeholder : [])
                .onChange(of: store.scrollToTop) { newValue in
                    withAnimation {
                        proxy.scrollTo(scrollViewTopID)
                    }
                }
                .refreshable {
                    store.send(.viewEvent(.refresh))
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
                            BlurView(style: .systemMaterial)
                                .opacity(0.85)
                                .ignoresSafeArea(.all)
                        )
                }
            }
        }
    }
    
    private var fakeNavBar: some View {
        VStack {
            ZStack {
                HStack {
                    NavBackButton {
                        store.send(.viewEvent(.tappedBackButton))
                    }
                    .padding(.leading, 15)
                    
                    Spacer()
                }
                
                Text("검색 내용")
                    .textStyle(.subtitleL)
                    .foregroundStyle(.textDefault)
            }
            
            PASearchBar(placeHolder: store.searchText, placeHolderColor: .textDefault, backgroundColor: .gray10)
                .padding(.horizontal, 15)
                .onTapGesture {
                    store.send(.viewEvent(.searchStart))
                }
            
            Spacer()
                .frame(height: 12)
        }
    }
    
    private var filterView: some View {
        HStack(spacing: 1) {
            HStack {
                Text("스팟")
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textDefault)
                
                Text("\(store.itemTotalCount)")
                    .textStyle(.captionM)
                    .foregroundStyle(.textInfo)
            }
            
            Spacer()
            
            HStack(spacing: 1) {
                Text(store.filterText)
                    .foregroundStyle(.textInfo)
                    .textStyle(.captionM)
                
                Image("UnderIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
            .asButton {
                store.send(.viewEvent(.openFilter))
            }
        }
    }
    
    private var spotGridView: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            if store.searchSpotItems.isEmpty {
                ForEach(0..<10, id: \.self) { index in
                    spotView(item: SearchSpotEntity(), index: index)
                }
            } else {
                ForEach(Array(store.searchSpotItems.enumerated()), id: \.element.id) { index, item in
                    spotView(item: item, index: index)
                        .asButton {
                            store.send(.viewEvent(.tappedSpotDetail(store.searchSpotItems[index].spotId, index: index)))
                        }
                        .onAppear {
                            if store.pageTotalCount != store.currentPage && index >= store.searchSpotItems.count - 6 && store.listLoadTrigger {
                                store.send(.viewEvent(.nextPage))
                            }
                        }
                }
            }
        }
        .padding(16)
    }
}

extension SearchResultView {
    private func spotView(item: SearchSpotEntity, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            if !item.spotName.isEmpty {
                DownImageView(url: item.imageUrl, option: .max, fallBackImg: "ImageDefault")
                    .aspectRatio(1, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .clipped()
                    .overlay(alignment: .topTrailing) {
                        SpotArchiveButton(height: 40, width: 40, viewState: .category, isSaved: item.isScraped) {
                            store.send(.viewEvent(.tappedArchiveButton(index)))
                        }
                        .padding(.trailing, 4)
                        .padding(.top, 4)
                    }
            } else {
                Rectangle()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .foregroundStyle(.gray30)
            }
            
            Text(item.spotName.isEmpty ? "spotName" : item.spotName)
                .textStyle(.subtitleS)
                .foregroundStyle(.textDefault)
                .padding(.top, 12)
            
            HStack(spacing: 8) {
                Text(item.spotName.isEmpty ? "Distance" : "\(item.distance)")
                    .textStyle(.captionS)
                    .foregroundStyle(.textInfo)
                
                SaveCommentCountView(archiveCount: item.spotScraps, commentCount: item.reviews, imageSize: 10)
            }
            .padding(.top, 4)
        }
    }
}
