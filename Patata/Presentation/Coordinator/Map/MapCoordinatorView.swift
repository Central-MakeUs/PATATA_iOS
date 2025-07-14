//
//  MapCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import SwiftUI
import TCACoordinators
import ComposableArchitecture
import PopupView

struct MapCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<MapCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .spotMap(spotMapStore):
                    SpotMapView(store: spotMapStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .mySpotList(mySpotListStore):
                    MySpotListView(store: mySpotListStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .spotEditorView(spotEditorStore):
                    SpotEditorView(store: spotEditorStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .search(searchStore):
                    SearchView(store: searchStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .searchMap(searchMapStore):
                    SearchMapView(store: searchMapStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .addSpotMap(addSpotMapStore):
                    AddSpotMapView(store: addSpotMapStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .successView(successStore):
                    SuccessView(store: successStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .spotDetail(detailStore):
                    SpotDetailView(store: detailStore)
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
        }
    }
}

extension MapScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .spotMap:
            return ID.spotMap
        case .mySpotList:
            return ID.mySpotList
        case .spotEditorView:
            return ID.spotEditorView
        case .search:
            return ID.search
        case .searchMap:
            return ID.searchMap
        case .addSpotMap:
            return ID.addSpotMap
        case .successView:
            return ID.successView
        case .spotDetail:
            return ID.spotDetail
        case .report:
            return ID.report
        }
    }
    
    enum ID: Identifiable {
        case spotMap
        case mySpotList
        case spotEditorView
        case search
        case searchMap
        case addSpotMap
        case successView
        case spotDetail
        case report
        
        var id: ID {
            return self
        }
    }
}
