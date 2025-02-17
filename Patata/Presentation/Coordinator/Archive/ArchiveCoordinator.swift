//
//  ArchiveCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum ArchiveScreen {
    case archive(ArchiveFeature)
    case spotDetail(SpotDetailFeature)
}

@Reducer
struct ArchiveCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.archive(ArchiveFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<ArchiveScreen.State>>
        
        var isHideTabBar: Bool = false
        var popupIsPresent: Bool = false
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<ArchiveScreen>)
        
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

extension ArchiveCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .router(.routeAction(id: .archive, action: .archive(.delegate(.tappedSpot(spotId))))):
                state.isHideTabBar = true
                state.routes.push(.spotDetail(SpotDetailFeature.State(isHomeCoordinator: true, spotId: spotId)))
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.tappedNavBackButton(_))))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case .router(.routeAction(id: .spotDetail, action: .spotDetail(.delegate(.delete)))):
                state.isHideTabBar = false
                state.routes.pop()
                state.popupIsPresent = true
                
            case .viewEvent(.dismissPopup):
                state.popupIsPresent = false
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
