//
//  SpotMapView.swift
//  Patata
//
//  Created by 김진수 on 1/23/25.
//

import SwiftUI
import ComposableArchitecture

// 지도 뷰를 그리기 전에 먼저 통신을 해서 기억하고 있는 좌표가 있는지 체크
// 없다면 그냥 지도 그리고
// 있다면 일단 해당 값 카테고리를 체크후 해당하는 마커를 만들고 좌표값을 넣어 맵 뷰에 넣는다.
// 그리고 지도를 그린다.
// 예시로 버튼을 누를때마다 카메라가 바라보는 좌표에 마커를 추가하는 걸 해보자
struct SpotMapView: View {
    
    @Perception.Bindable var store: StoreOf<SpotMapFeature>

    var body: some View {
        WithPerceptionTracking {
            contentView
                .presentBottomSheet(isPresented: $store.isPresented.sending(\.bindingIsPresented), mapBottomView: {
                    AnyView(mapBottomView)
                }, content: {
                    AnyView(spotDetailSheet)
                }, onDismiss: {
                    print("tap")
                    store.send(.viewEvent(.bottomSheetDismiss))
                })
        }
    }
}

extension SpotMapView {
    private var contentView: some View {
        VStack(spacing: 0) {
            VStack {
                fakeNavgationBar
                    .padding(.horizontal, 15)
                    .padding(.bottom, 12)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
             
            ZStack {
                UIMapView(coord: (store.coord.latitude, store.coord.longitude), markers: [((store.coord.latitude, store.coord.longitude), SpotMarkerImage.housePin)]) { lat, long in
                    store.send(.viewEvent(.tappedMarker))
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
                .asButton {
                    store.send(.viewEvent(.tappedSideButton))
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
            .padding(.vertical, 15)
            .background(.gray20)
            .clipShape(RoundedRectangle(cornerRadius: 30))
        }
    }
    
    private var mapMenuView: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(Array(store.categoryItems.enumerated()), id: \.element.id) { index, item in
                    categoryMenuView(categoryItem: item, index: index)
                        .onTapGesture {
                            store.send(.viewEvent(.tappedMenu(index)))
                        }
                }
            }
            .padding(.leading, 15)
        }
    }
    
    private var mapBottomView: some View {
        ZStack {
//            Text("장소 추가하기")
//                .hashTagStyle(backgroundColor: .blue100, textColor: .white, font: .subtitleS, verticalPadding: 10, horizontalPadding: 30, cornerRadius: 20)
//                .padding(.bottom, 16)
//                .asButton {
//                    store.send(.viewEvent(.tappedSpotAddButton))
//                }
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    
                    Circle()
                        .fill(.blue100)
                        .frame(width: 48, height: 48)
                        .overlay(alignment: .center) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                        }
                        .padding(.trailing, 15)
                        .asButton {
                            store.send(.viewEvent(.tappedSpotAddButton))
                        }
                }
                
                
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
    }
    
    private var spotDetailSheet: some View {
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
                .textStyle(store.selectedMenuIndex == index ? .subtitleXS : .captionM)
                .foregroundStyle(store.selectedMenuIndex == index ? .white : .textInfo)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(store.selectedMenuIndex == index ? .clear : .gray30, lineWidth: 2)
                .background(store.selectedMenuIndex == index ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        )
    }
}


