//
//  ArchiveCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators
import PopupView

struct ArchiveCoordinatorView: View {
    
    @Perception.Bindable var store: StoreOf<ArchiveCoordinator>
    
    var body: some View {
        WithPerceptionTracking {
            TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
                switch screen.case {
                case let .archive(archiveStore):
                    ArchiveView(store: archiveStore)
                        .hideTabBar(store.isHideTabBar)
                    
                case let .spotDetail(detailStore):
                    SpotDetailView(store: detailStore)
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
                    
                case let .category(categoryStore):
                    SpotCategoryView(store: categoryStore)
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

extension ArchiveScreen.State: Identifiable {
    var id: ID {
        switch self {
        case .archive:
            return ID.archive
        case .spotDetail:
            return ID.spotDetail
        case .spotedit:
            return ID.spotedit
        case .addSpotMap:
            return ID.addSpotMap
        case .report:
            return ID.report
        case .category:
            return ID.category
        }
    }
    
    enum ID: Identifiable {
        case archive
        case spotDetail
        case spotedit
        case addSpotMap
        case report
        case category
        
        var id: ID {
            return self
        }
    }
}

