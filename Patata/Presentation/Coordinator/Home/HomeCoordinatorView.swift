//
//  HomeCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import TCACoordinators
import ComposableArchitecture
import PopupView

struct HomeCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<HomeCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .home(store):
                    PatataMainView(store: store)
                    
                case let .search(store):
                    SearchView(store: store)
                        .hideTabBar(true)
                    
                case let .category(store):
                    SpotCategoryView(store: store)
                        .hideTabBar(true)
                    
                case let .spotDetail(store):
                    SpotDetailView(store: store)
                        .hideTabBar(true)
                    
                case let .mySpotList(store):
                    MySpotListView(store: store)
                        .hideTabBar(true)
                }
            }
            .popup(isPresented: $store.popupIsPresent.sending(\.bindingPopupIsPresent), view: {
                HStack {
                    Spacer()
                    
                    Text("게시물이 정상적으로 삭제되었습니다.")
                        .textStyle(.subtitleXS)
                        .foregroundStyle(.blue20)
                        .padding(.vertical, 10)
                    
                    Spacer()
                }
                .background(.gray100)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .padding(.horizontal, 15)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
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
                    .backgroundColor(.black.opacity(0.5))
                    .dismissCallback {
                        store.send(.viewEvent(.dismissPopup))
                    }
            })
        }
    }
}

extension HomeScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .home:
            return ID.home
        case .search:
            return ID.search
        case .category:
            return ID.category
        case .spotDetail:
            return ID.spotDetail
        case .mySpotList:
            return ID.mySpotList
        }
    }
    
    enum ID: Identifiable {
        case home
        case search
        case category
        case spotDetail
        case mySpotList
        
        var id: ID {
            return self
        }
    }
}

