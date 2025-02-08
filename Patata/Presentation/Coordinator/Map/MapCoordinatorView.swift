//
//  MapCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import SwiftUI
import TCACoordinators
import ComposableArchitecture

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
                }
            }
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
        }
    }
    
    enum ID: Identifiable {
        case spotMap
        case mySpotList
        case spotEditorView
        
        var id: ID {
            return self
        }
    }
}
