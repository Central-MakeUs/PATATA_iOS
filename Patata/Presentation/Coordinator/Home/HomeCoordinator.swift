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
    case spotedit(SpotEditorFeature)
    case addSpotMap(AddSpotMapFeature)
}

@Reducer
struct HomeCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.home(PatataMainFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<HomeScreen.State>>
        
        var popupIsPresent: Bool = false
        var isHideTabBar: Bool = false
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<HomeScreen>)
        
        case viewEvent(ViewEventType)
        case bindingPopupIsPresent(Bool)
    }
    
    enum ViewEventType {
        case dismissPopup
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
                state.isHideTabBar = true
                state.routes.push(.search(SearchFeature.State(beforeViewState: .home)))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedAddButton)))):
                state.isHideTabBar = true
                state.routes.push(.category(SpotCategoryFeature.State(selectedIndex: 0)))
                
            case let .router(.routeAction(id: .home, action: .home(.delegate(.tappedSpot(spotId))))):
                state.isHideTabBar = true
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .home, action: .home(.delegate(.tappedMoreButton)))):
                state.isHideTabBar = true
                
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .home, mbrLocation: MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0)), isSearch: false, searchText: "")))
                
            case let .router(.routeAction(id: .home, action: .home(.delegate(.tappedCategoryButton(category))))):
                state.isHideTabBar = true
                state.routes.push(.category(SpotCategoryFeature.State(selectedIndex: category.rawValue)))
                
            case .router(.routeAction(id: .search, action: .search(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case let .router(.routeAction(id: .search, action: .search(.delegate(.tappedSpotDetail(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .category, action: .category(.delegate(.tappedNavBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case let .router(.routeAction(id: .category, action: .category(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.delete)))):
                state.routes.pop()
                state.popupIsPresent = true
                
                if state.routes.count == 1{
                    state.isHideTabBar = false
                } else {
                    state.isHideTabBar = true
                }
                
                return .run { [routes = state.routes] send in
                    if let _ = routes.last(where: { $0.id == .search }) {
                        await send(.router(.routeAction(
                            id: .search,
                            action: .search(.delegate(.deletePop))
                        )))
                    }
                }
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton(archive))))):
                state.routes.pop()
                if state.routes.count == 1 {
                    state.isHideTabBar = false
                }
                
                return .run { [routes = state.routes] send in
                    if let _ = routes.last(where: { $0.id == .search }) {
                        await send(.router(.routeAction(id: .search, action: .search(.delegate(.detailBack(archive))))))
                    }
                }
                
            case let .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.editSpotDetail(spotAddress))))):
                state.routes.push(.spotedit(SpotEditorFeature.State(viewState: .edit, spotLocation: Coordinate(latitude: 37.5666791, longitude: 126.9784147), spotAddress: spotAddress)))
                
            case .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedBackButton)))):
                state.routes.pop()
                state.isHideTabBar = false
                
            case let .router(.routeAction(id: .mySpotList, action: .mySpotList(.delegate(.tappedSpot(spotId))))):
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedBackButton)))):
                state.routes.pop()
                state.isHideTabBar = true
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedXButton)))):
                state.routes.popToRoot()
                state.isHideTabBar = false
                
            case let .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.tappedLocation(coord))))):
                state.routes.push(.addSpotMap(AddSpotMapFeature.State(viewState: .edit, spotCoord: Coordinate(latitude: 0, longitude: 0))))
                
            case .router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.successSpotAdd)))):
                state.routes.pop()
                
            case let .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedAddConfirmButton(coord, spotAddress, _))))):
                state.routes.pop()
                
                return .run { send in
                    await send(.router(.routeAction(id: .spotedit, action: .spotedit(.delegate(.changeAddress(coord, spotAddress))))))
                }
                
            case .router(.routeAction(id: .addSpotMap, action: .addSpotMap(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
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
