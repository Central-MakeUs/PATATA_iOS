//
//  ArchiveCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import SwiftUI
import ComposableArchitecture
import TCACoordinators

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
                }
            }
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
        }
    }
    
    enum ID: Identifiable {
        case archive
        case spotDetail
        
        var id: ID {
            return self
        }
    }
}

