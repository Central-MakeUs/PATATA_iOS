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
                        .hideTabBar(false)
                    
                case let .search(store):
                    SearchView(store: store)
                        .hideTabBar(true)
                    
                case let .category(store):
                    SpotCategoryView(store: store)
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
        }
    }
    
    enum ID: Identifiable {
        case home
        case search
        case category
        
        var id: ID {
            return self
        }
    }
}

