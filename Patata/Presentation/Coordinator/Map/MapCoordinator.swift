//
//  MapCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum MapScreen {
    case spotMap(SpotMapFeature)
    case mySpotList(MySpotListFeature)
    case spotEditorView(SpotEditorFeature)
}

@Reducer
struct MapCoordinator {
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.spotMap(SpotMapFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<MapScreen.State>>
        
        var isHideTabBar: Bool = false
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<MapScreen>)
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MapCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .router(.routeAction(id: _, action: .spotMap(.delegate(.tappedSideButton)))):
                state.isHideTabBar = true
                state.routes.push(.mySpotList(MySpotListFeature.State(viewState: .map)))
                
            case .router(.routeAction(id: _, action: .spotMap(.delegate(.tappedSpotAddButton)))):
                state.isHideTabBar = true
                state.routes.push(.spotEditorView(SpotEditorFeature.State(viewState: .add)))
                
            case .router(.routeAction(id: _, action: .spotMap(.delegate(.tappedMarker)))):
                state.isHideTabBar = true
                
            case .router(.routeAction(id: _, action: .spotMap(.delegate(.bottomSheetDismiss)))):
                state.isHideTabBar = false
                
            case .router(.routeAction(id: _, action: .mySpotList(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case .router(.routeAction(id: _, action: .spotEditorView(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            default:
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
