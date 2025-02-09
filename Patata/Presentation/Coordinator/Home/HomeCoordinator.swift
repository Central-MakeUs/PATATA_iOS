//
//  HomeCoordinator.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum HomeScreen {
    case home(PatataMainFeature)
    case search(SearchFeature)
    case category(SpotCategoryFeature)
    case spotDetail(SpotDetailFeature)
    case mySpotList(MySpotListFeature)
}

@Reducer
struct HomeCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.home(PatataMainFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<HomeScreen.State>>
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<HomeScreen>)
        case navigationAction(NavigationAction)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSearch
        }
    }
    
    enum NavigationAction {
        case pushSearch
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension HomeCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedSearch)))):
                return .concatenate(
                    .send(.delegate(.tappedSearch)),
                    .send(.navigationAction(.pushSearch))
                )
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedAddButton)))):
                state.routes.push(.category(SpotCategoryFeature.State()))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedSpot)))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true)))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedMoreButton)))):
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .home)))
                
            case .router(.routeAction(id: .search, action: .search(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .search, action: .search(.delegate(.tappedSpotDetail)))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true)))
                
            case .router(.routeAction(id: .category, action: .category(.delegate(.tappedNavBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .navigationAction(.pushSearch):
                state.routes.push(.search(SearchFeature.State(beforeViewState: .home)))
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
