//
//  HomeCoordinatorView.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import SwiftUI
import TCACoordinators
import ComposableArchitecture

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
                }
            }
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
        }
    }
    
    enum ID: Identifiable {
        case home
        case search
        case category
        case spotDetail
        
        var id: ID {
            return self
        }
    }
}

