//
//  TabCoordinator.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct TabCoordinator {
    
    @ObservableState
    struct State: Equatable {
        static let initialState = State(tabState: .home, homeTabState: .initialState, mapTabState: .initialState)
        var tabState: TabCase
        
        var homeTabState = HomeCoordinator.State.initialState
        var mapTabState = MapCoordinator.State.initialState
    }
    
    enum Action {
        case homeTabAction(HomeCoordinator.Action)
        case mapTabAction(MapCoordinator.Action)
        case parentAction(ParentAction)
        
        // binding
        case bindingTab(TabCase)
        
        enum ParentAction {
            case userLocation(Coordinate)
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.homeTabState, action: \.homeTabAction) {
            HomeCoordinator()
        }
        
        Scope(state: \.mapTabState, action: \.mapTabAction) {
            MapCoordinator()
        }
        
        core()
    }
}

extension TabCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .bindingTab(tab):
                state.tabState = tab
                
            case let .parentAction(.userLocation(coord)):
                if state.tabState == .home {
                    return .send(.homeTabAction(.parentAction(.userLocation(coord))))
                }
                
                if state.tabState == .map {
                    return .send(.mapTabAction(.parentAction(.userLocation(coord))))
                }
                
            default:
                break
            }
            return .none
        }
    }
}
