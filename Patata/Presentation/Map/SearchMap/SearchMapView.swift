//
//  SearchMapView.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct SearchMapView: View {
    
    @Perception.Bindable var store: StoreOf<SearchMapFeature>

    var body: some View {
        WithPerceptionTracking {
            contentView
                .navigationBarBackButtonHidden()
                .presentBottomSheet(isPresented: $store.isPresented.sending(\.bindingIsPresented), isMap: true, mapBottomView: {
                    AnyView(mapBottomView)
                }, content: {
                    AnyView(
                        WithPerceptionTracking {
                            spotDetailSheet(spot: store.searchSpotItems[safe: store.selectedIndex] ?? MapSpotEntity())
                                .asButton {
                                    store.send(.viewEvent(.tappedSpotDetail(store.searchSpotItems[safe: store.selectedIndex]?.spotId ?? 0)))
                                }
                        }
                    )
                }, onDismiss: {
                    store.send(.viewEvent(.bottomSheetDismiss))
                })
                .popup(isPresented: $store.errorIsPresented.sending(\.bindingErrorIsPresent), view: {
                    HStack {
                        Spacer()
                        
                        Text(store.errorMSG)
                            .textStyle(.subtitleXS)
                            .foregroundStyle(.blue20)
                            .padding(.vertical, 14)
                        
                        Image("NoAddIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 12, height: 12)
                        
                        Spacer()
                    }
                    .background(.gray100)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .padding(.horizontal, 15)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            store.send(.viewEvent(.dismissPopup))
                        }
                    }
                }, customize: {
                    $0
                        .type(.floater())
                        .position(.bottom)
                        .animation(.spring())
                        .closeOnTap(true)
                        .closeOnTapOutside(true)
                        .backgroundColor(.gray.opacity(0.2))
                        .dismissCallback {
                            store.send(.viewEvent(.dismissPopup))
                        }
                    
                })
                .onAppear {
                    store.send(.viewCycle(.onAppear))
                }
        }
    }
}

extension SearchMapView {
    private var contentView: some View {
        
        VStack(spacing: 0) {
            VStack {
                fakeNavgationBar
                    .padding(.horizontal, 15)
                    .padding(.bottom, 12)
                
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            
            ZStack(alignment: .top) {
                UIMapView(mapManager: store.mapManager)
                    .ignoresSafeArea(edges: .bottom)
                
                Color.black
                    .opacity(0.1)
                    .frame(height: 4)
                    .blur(radius: 3)
                
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
                Text(store.searchText)
                    .textStyle(.subtitleS)
                    .foregroundColor(.textSub)
                
                Spacer()
                
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.gray70)
                    .asButton {
                        print("imageOnSubmit")
                    }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .padding(.vertical, 15)
            .background(.gray20)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .onTapGesture {
                store.send(.viewEvent(.tappedSearch))
            }
            
            Image("XActive")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .asButton {
                    store.send(.viewEvent(.tappedBackButton))
                }
            
        }
    }
    
    private var mapMenuView: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal) {
                HStack {
                    ForEach(CategoryCase.allCases, id: \.id) { item in
                        categoryMenuView(categoryItem: item)
                            .id(item.rawValue)
                            .asButton {
                                store.send(.viewEvent(.tappedMenu(item.rawValue)))
                            }
                            .onChange(of: store.selectedMenuIndex) { newValue in
                                withAnimation {
                                    proxy.scrollTo(store.selectedMenuIndex, anchor: .center)
                                }
                            }
                    }
                }
                .padding(.horizontal, 15)
            }
        }
    }
    
    private var mapBottomView: some View {
        ZStack(alignment: .bottom) {
            
            if !store.reloadButtonIsHide {
                VStack {
                    HStack(spacing: 4) {
                        Image("ReloadIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 14, height: 14)
                        
                        Text("이 지역에서 탐색")
                            .textStyle(.subtitleS)
                        
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 20)
                    .foregroundStyle(.navy100)
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .shadowColor, radius: 5)
                    .asButton {
                        store.send(.viewEvent(.tappedReloadButton))
                    }
                }
                .padding(.bottom, 12)
            }
            
            
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    
                    Circle()
                        .fill(.blue100)
                        .frame(width: 48, height: 48)
                        .shadow(color: .shadowColor, radius: 2)
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
                        .shadow(color: .shadowColor, radius: 2)
                        .overlay(alignment: .center) {
                            Image("LocationActive")
                                .resizable()
                                .frame(width: 24, height: 24)
                        }
                        .padding(.trailing, 15)
                        .asButton {
                            store.send(.viewEvent(.tappedMoveToUserLocationButton))
                        }
                }
                .padding(.bottom, 15)
                
            }
        }
    }
}

extension SearchMapView {
    private func categoryMenuView(categoryItem: CategoryCase) -> some View {
        HStack {
            if let image = categoryItem.getCategoryCase().image {
                Image(image)
                    .resizable()
                    .frame(width: 18, height: 18)
            }
            
            Text(categoryItem.getCategoryCase().title)
                .textStyle(store.selectedMenuIndex == categoryItem.rawValue ? .subtitleXS : .captionM)
                .foregroundStyle(store.selectedMenuIndex == categoryItem.rawValue ? .white : .textInfo)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(store.selectedMenuIndex == categoryItem.rawValue ? .clear : .gray30, lineWidth: 1)
                .background(store.selectedMenuIndex == categoryItem.rawValue ? .black : .white)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        )
    }
    
    private func spotDetailSheet(spot: MapSpotEntity) -> some View {
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
                
                SpotArchiveButton(height: 24, width: 24, isSaved: ((store.searchSpotItems.isEmpty ? false : store.searchSpotItems[safe: store.selectedIndex]?.isScraped) != nil)) {
                    store.send(.viewEvent(.tappedArchiveButton))
                }
            }
            
            HStack(spacing: 4) {
                Text(spot.distance)
                    .textStyle(.captionS)
                    .foregroundStyle(.textSub)
                
                Text(spot.spotAddress + spot.spotAddressDetail)
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
            
            DownImageView(url: spot.images[safe: 0] ?? nil, option: .max, fallBackImg: "ImageDefault")
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: (UIScreen.main.bounds.width - 30) * 0.5)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
    }
}
