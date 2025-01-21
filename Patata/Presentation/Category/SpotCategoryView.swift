//
//  SpotCategoryView.swift
//  Patata
//
//  Created by 김진수 on 1/22/25.
//

import SwiftUI

// 일단 해당 뷰는 어떤 카테고리인지에 따라 시작하는 화면이 달라진다
// 선택된 카테고리는 하단에 라인과 약간의 padding과 함께 달라진다

struct MenuItem: Identifiable {
    let id = UUID()
    let title: String
    var isSelected: Bool = false
}

struct SpotCategoryView: View {
    
    let titles = ["전체", "작가추천", "스냅스팟", "시크한 아경", "일상 속 공감", "싱그러운"]
    
    @State private var selectedIndex: Int = 0
    @State var isPresent: Bool = false
    @State var filter: String = "거리순"
    
    var body: some View {
        NavigationView {
            contentView
                .navigationBarBackButtonHidden(true)
                .presentBottomSheet(isPresented: $isPresent) {
                    BottomSheetItem(title: "정렬", items: ["거리순", "추천순"]) { item in
                        isPresent = false
                        filter = item
                        // 여기서 필터에 맞게 통신 아마 onChange에서 통신할듯
                    }
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
                
                CategoryRecommendView()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 15)
            }
            .background(.gray10)

        }
    }
    
    private var fakeNavBar: some View {
        ZStack {
            HStack {
                NavBackButton {
                    print("back")
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
                    ForEach(Array(titles.enumerated()), id: \.element) { index, title in
                        let menuItem = MenuItem(title: title, isSelected: selectedIndex == index)
                        categoryMenuView(item: menuItem)
                            .fixedSize(horizontal: true, vertical: true)
                            .id(index)
                            .asButton {
                                selectedIndex = index
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
    
    private var filterView: some View {
        HStack(spacing: 0) {
            HStack {
                Text("스팟")
                    .textStyle(.subtitleXS)
                    .foregroundStyle(.textDefault)
                
                Text("6")
                    .textStyle(.captionM)
                    .foregroundStyle(.textInfo)
                    .padding(.leading, 0)
            }
            
            Spacer()
            
            HStack(spacing: 1) {
                Text(filter)
                    .foregroundStyle(.textInfo)
                    .textStyle(.captionM)
                    .asButton {
                        isPresent = true
                    }
                
                Image("UnderIcon")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 18, height: 18)
            }
            .asButton {
                print("tap")
                isPresent = true
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
