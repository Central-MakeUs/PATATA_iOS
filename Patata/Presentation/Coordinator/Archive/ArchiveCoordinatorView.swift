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
        }
    }
    
    enum ID: Identifiable {
        case archive
        case spotDetail
        case spotedit
        case addSpotMap
        
        var id: ID {
            return self
        }
    }
}

