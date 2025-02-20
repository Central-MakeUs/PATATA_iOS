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
                case let .home(homeStore):
                    PatataMainView(store: homeStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .search(searchStore):
                    SearchView(store: searchStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .category(categoryStore):
                    SpotCategoryView(store: categoryStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .spotDetail(detailStore):
                    SpotDetailView(store: detailStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .mySpotList(listStore):
                    MySpotListView(store: listStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .spotedit(spotEditStore):
                    SpotEditorView(store: spotEditStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .addSpotMap(addSpotMapStore):
                    AddSpotMapView(store: addSpotMapStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .report(reportStore):
                    ReportView(store: reportStore)
                        .hideTabBar(store.isHideTabBar)
                }
            }
            .customAlert(
                isPresented: $store.alertIsPresent.sending(\.bindingAlertIsPrenset),
                title: "신고가 접수되었습니다",
                message: "24시간 이내에 검토 후 처리될 예정이며,\n신고된 사용자의 댓글 및 스팟 업로드 등의 활동이\n일시적으로 제한되었습니다.",
                onConfirm: {
                    store.send(.viewEvent(.dismissAlert))
                }
            )
            .popup(isPresented: $store.popupIsPresent.sending(\.bindingPopupIsPresent), view: {
                HStack {
                    Spacer()
                    
                    Text(store.errorMSG)
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
        case .spotedit:
            return ID.spotedit
        case .addSpotMap:
            return ID.addSpotMap
        case .report:
            return ID.report
        }
    }
    
    enum ID: Identifiable {
        case home
        case search
        case category
        case spotDetail
        case mySpotList
        case spotedit
        case addSpotMap
        case report
        
        var id: ID {
            return self
        }
    }
}

