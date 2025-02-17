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
        static let initialState = State(tabState: .home, homeTabState: .initialState, mapTabState: .initialState, archiveTabState: .initialState, myPageTabState: .initialState)
        var tabState: TabCase
        
        var homeTabState = HomeCoordinator.State.initialState
        var mapTabState = MapCoordinator.State.initialState
        var archiveTabState = ArchiveCoordinator.State.initialState
        var myPageTabState = MyPageCoordinator.State.initialState
    }
    
    enum Action {
        case homeTabAction(HomeCoordinator.Action)
        case mapTabAction(MapCoordinator.Action)
        case archiveTabAction(ArchiveCoordinator.Action)
        case myPageTabAction(MyPageCoordinator.Action)
        
        case delegate(Delegate)
        
        // binding
        case bindingTab(TabCase)
        
        enum Delegate {
            case tappedLogout
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.homeTabState, action: \.homeTabAction) {
            HomeCoordinator()
        }
        
        Scope(state: \.mapTabState, action: \.mapTabAction) {
            MapCoordinator()
        }
        
        Scope(state: \.archiveTabState, action: \.archiveTabAction) {
            ArchiveCoordinator()
        }
        
        Scope(state: \.myPageTabState, action: \.myPageTabAction) {
            MyPageCoordinator()
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
                
            case .myPageTabAction(.delegate(.tappedLogout)):
                return .send(.delegate(.tappedLogout))
                
            default:
                break
            }
            return .none
        }
    }
}
