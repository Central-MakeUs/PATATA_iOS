//
//  SpotMapView.swift
//  Patata
//
//  Created by 김진수 on 1/23/25.
//

import SwiftUI

// 지도 뷰를 그리기 전에 먼저 통신을 해서 기억하고 있는 좌표가 있는지 체크
// 없다면 그냥 지도 그리고
// 있다면 일단 해당 값 카테고리를 체크후 해당하는 마커를 만들고 좌표값을 넣어 맵 뷰에 넣는다.
// 그리고 지도를 그린다.


enum SpotMarkerImage {
    static let housePin: String = "HousePin"
    static let inActivePin: String = "InActivePin"
    static let activePin: String = "ActivePin"
    static let naturePin: String = "NaturePin"
    static let myPin: String = "MyPin"
    static let nightPin: String = "NightPin"
    static let recommendPin: String = "RecommendPin"
    static let snapPin: String = "SnapPin"
    static let archivePin: String = "ArchivePin"
}

// 예시로 버튼을 누를때마다 카메라가 바라보는 좌표에 마커를 추가하는 걸 해보자
struct SpotMapView: View {
    @State var coord: (Double, Double) = (126.9784147, 37.5666805)
    @State var searchText: String = ""
    @State var isSelected: Bool = false
    @State var menuIndex: Int = 0
    @State var isPresented: Bool = false
    
    let categoryItems = [
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
    
    @State var selectedIndex: Int = 0
    var currentIndex: Int = 0
    
    var body: some View {
        contentView
            .presentBottomSheet(isPresented: $isPresented, isMap: true, mapBottomView: {
                AnyView(mapBottomView)
            }, content: {
                AnyView(spotDetailSheet)
            })
    }
}

extension SpotMapView {
    private var contentView: some View {
        VStack {
            VStack {
                fakeNavgationBar
                    .padding(.horizontal, 15)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(
                   Color.white
                       .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
               )
             
            ZStack {
                UIMapView(coord: coord, markers: [(coord, SpotMarkerImage.housePin)])
                
                UIMapView(coord: coord, markers: [(coord, SpotMarkerImage.housePin)]) { lat, long in
                    isPresented = true
                }
                
                VStack {
                    mapMenuView
                        .scrollIndicators(.hidden)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    mapBottomView
                }
            }
        }
    }
    
    private var fakeNavgationBar: some View {
        HStack(spacing: 5) {
            Image("ListActive")
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.blue100)
            
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
            .padding(.vertical, 15)
            .background(.gray20)
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
    
    private var mapMenuView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(categoryItems.enumerated()), id: \.element.id) { index, item in
                    categoryMenuView(categoryItem: item, index: index)
                        .onTapGesture {
                            selectedIndex = index
                        }
                }
            }
            .padding(.leading, 15)
        }
    }
    
    private var mapBottomView: some View {
        ZStack {
            Text("장소 추가하기")
                .hashTagStyle(backgroundColor: .blue100, textColor: .white, font: .subtitleS, verticalPadding: 10, horizontalPadding: 30, cornerRadius: 20)
                .padding(.bottom, 16)
            
            HStack {
                Spacer()
                
                Circle()
                    .fill(.white)
                    .frame(width: 48, height: 48)
                    .overlay(alignment: .center) {
                        Image("LocationActive")
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    .padding(.trailing, 15)
            }
            .padding(.bottom, 15)
        }
    }
    
    private var spotDetailSheet: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 첫 번째 행: 태그와 제목
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
                
                Image("ArchiveInactive")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            }
            
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
            
            Rectangle()
                .foregroundStyle(.red)
                .frame(maxWidth: .infinity)
                .frame(height: (UIScreen.main.bounds.width - 30) * 0.5)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        
    }
}

extension SpotMapView {
    private func categoryMenuView(categoryItem: CategoryItem, index: Int) -> some View {
        HStack {
            if categoryItem.item != "전체" {
                Image(categoryItem.images)
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            
            Text(categoryItem.item)
                .textStyle(selectedIndex == index ? .subtitleXS : .captionM)
                .foregroundStyle(selectedIndex == index ? .white : .textInfo)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(selectedIndex == index ? .clear : .gray30, lineWidth: 2)
                .background(selectedIndex == index ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        )
    }
}


