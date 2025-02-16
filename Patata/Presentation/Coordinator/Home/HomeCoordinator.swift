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
        
        var popupIsPresent: Bool = false
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<HomeScreen>)
        case navigationAction(NavigationAction)
        
        case viewEvent(ViewEventType)
        case bindingPopupIsPresent(Bool)
    }
    
    enum ViewEventType {
        case dismissPopup
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
                return .send(.navigationAction(.pushSearch))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedAddButton)))):
                state.routes.push(.category(SpotCategoryFeature.State(selectedIndex: 0)))
                
            case let .router(.routeAction(id: .home, action: .home(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedMoreButton)))):
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .home)))
                
            case let .router(.routeAction(id: .home, action: .home(.delegate(.tappedCategoryButton(category))))):
                state.routes.push(.category(SpotCategoryFeature.State(selectedIndex: category.rawValue)))
                
            case .router(.routeAction(id: .search, action: .search(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case let .router(.routeAction(id: .search, action: .search(.delegate(.tappedSpotDetail(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .category, action: .category(.delegate(.tappedNavBackButton)))):
                state.routes.pop()
                
            case let .router(.routeAction(id: .category, action: .category(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.delete)))):
                state.routes.pop()
                state.popupIsPresent = true
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case let .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .navigationAction(.pushSearch):
                state.routes.push(.search(SearchFeature.State(beforeViewState: .home)))
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            case let .bindingPopupIsPresent(isPresent):
                state.popupIsPresent = isPresent
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
