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
                        .hideTabBar(true)
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
        }
    }
    
    enum ID: Identifiable {
        case spotMap
        case mySpotList
        
        var id: ID {
            return self
        }
    }
}
