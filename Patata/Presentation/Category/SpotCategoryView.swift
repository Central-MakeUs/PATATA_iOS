//
//  SpotCategoryView.swift
//  Patata
//
//  Created by 김진수 on 1/22/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

// 일단 해당 뷰는 어떤 카테고리인지에 따라 시작하는 화면이 달라진다
// 선택된 카테고리는 하단에 라인과 약간의 padding과 함께 달라진다

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    var isSelected: Bool = false
}

struct SpotCategoryView: View {
    
    @Perception.Bindable var store: StoreOf<SpotCategoryFeature>
    
    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden(true)
                .presentBottomSheet(isPresented: $store.isPresent.sending(\.bindingIsPresent)) {
                    BottomSheetItem(title: "정렬", items: ["거리순", "추천순"]) { item in
                        store.send(.viewEvent(.tappedBottomSheetItem(item)))
                        // 여기서 필터에 맞게 통신 아마 onChange에서 통신할듯
                    }
                }
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension SpotCategoryView {
    private var contentView: some View {
        VStack(spacing: 0) {
            VStack {
                fakeNavBar
                
                scrollMenuView
                    .padding(.top, 10)
                    .padding(.horizontal, 15)
            }
            
            ScrollView(.vertical) {
                filterView
                    .padding(.top, 12)
                    .padding(.horizontal, 15)
                
                ForEach(Array(store.spotItems.enumerated()), id: \.element.spotId) { index, item in
                    CategoryRecommendView(spotItem: item) {
                        print("tap")
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 15)
                    .onAppear {
                        if store.totalPages != 1 && index >= store.spotItems.count - 6 && store.listLoadTrigger {
                            print("scroll")
                            store.send(.viewEvent(.nextPage))
                        }
                    }
                }

            }
            .background(.gray10)

        }
    }
    
    private var fakeNavBar: some View {
        ZStack {
            HStack {
                NavBackButton {
                    store.send(.viewEvent(.tappedNavBackButton))
                }
                .padding(.leading, 15)
                
                Spacer()
            }
            
            Text("카테고리")
                .textStyle(.subtitleL)
                .foregroundStyle(.textDefault)
        }
    }
    
    private var scrollMenuView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack(spacing: 0) {
                    ForEach(store.category, id: \.id) { category in
                        let menuItem = MenuItem(title: category.getCategoryCase().title, isSelected: store.selectedIndex == category.rawValue)
                        categoryMenuView(item: menuItem)
                            .fixedSize(horizontal: true, vertical: true)
                            .id(category.rawValue)
                            .asButton {
                                store.send(.viewEvent(.selectedMenu(category.rawValue)))
                                withAnimation {
                                    proxy.scrollTo(category.rawValue, anchor: .center)
                                }
                            }
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
    
    private var filterView: some View {
        HStack(spacing: 0) {
            HStack {
                Text("스팟")
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textDefault)
                
                Text("\(store.totalCount)")
                    .textStyle(.captionM)
                    .foregroundStyle(.textInfo)
                    .padding(.leading, 0)
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
                store.send(.viewEvent(.openBottomSheet))
            }
        }
    }
}

extension SpotCategoryView {
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
