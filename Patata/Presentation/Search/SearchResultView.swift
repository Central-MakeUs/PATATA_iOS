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
                    BottomSheetItem(title: "정렬", items: ["거리순", "추천순"]) { item in
                        store.send(.viewEvent(.dismissFilter(item)))
                        // 여기서 필터에 맞게 통신 아마 onChange에서 통신할듯
                    }
                }
        }
    }
}

extension SearchResultView {
    private var contentView: some View {
        VStack {
            fakeNavBar
            
            ScrollViewReader { proxy in
                ScrollView {
                    filterView
                        .padding(.top, 12)
                        .padding(.horizontal, 15)
                        .id(scrollViewTopID)
                    
                    spotGridView
                }
                .background(.gray10)
                .onChange(of: store.scrollToTop) { newValue in
                    withAnimation {
                        proxy.scrollTo(scrollViewTopID)
                    }
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
            
            PASearchBar(placeHolder: store.searchText, placeHolderColor: .textDefault)
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
        .padding(16)
    }
}

extension SearchResultView {
    private func spotView(item: SearchSpotEntity, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            DownImageView(url: item.imageUrl, option: .max, fallBackImg: "ImageDefault")
                .aspectRatio(1, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(alignment: .topTrailing) {
                    SpotArchiveButton(height: 24, width: 24, isSaved: item.isScraped) {
                        store.send(.viewEvent(.tappedArchiveButton(index)))
                    }
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                }
            
            Text(item.spotName)
                .textStyle(.subtitleS)
                .foregroundStyle(.textDefault)
                .padding(.top, 12)
            
            HStack(spacing: 8) {
                Text("\(item.distance)")
                    .textStyle(.captionS)
                    .foregroundStyle(.textInfo)
                
                SaveCommentCountView(archiveCount: item.spotScraps, commentCount: item.reviews, imageSize: 12)
            }
            .padding(.top, 4)
        }
    }
}
