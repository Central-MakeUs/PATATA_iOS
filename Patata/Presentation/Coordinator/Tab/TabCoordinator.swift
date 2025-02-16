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
        static let initialState = State(tabState: .home, homeTabState: .initialState, mapTabState: .initialState, archiveTabState: .init())
        var tabState: TabCase
        
        var homeTabState = HomeCoordinator.State.initialState
        var mapTabState = MapCoordinator.State.initialState
        var archiveTabState = ArchiveFeature.State()
    }
    
    enum Action {
        case homeTabAction(HomeCoordinator.Action)
        case mapTabAction(MapCoordinator.Action)
        case archiveTabAction(ArchiveFeature.Action)
        
        // binding
        case bindingTab(TabCase)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.homeTabState, action: \.homeTabAction) {
            HomeCoordinator()
        }
        
        Scope(state: \.mapTabState, action: \.mapTabAction) {
            MapCoordinator()
        }
        
        Scope(state: \.archiveTabState, action: \.archiveTabAction) {
            ArchiveFeature()
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
                
            default:
                break
            }
            return .none
        }
    }
}
