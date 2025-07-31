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
        @Shared(.inMemory("isHidden")) var isHidden: Bool = false
        
        var tabState: TabCase
        
        var home = HomeCoordinator.State()
        var map = MapCoordinator.State()
        var archive = ArchiveCoordinator.State()
        var myPage = MyPageCoordinator.State()
        
        init() {
            tabState = .home
        }
    }
    
    enum Action {
        case home(HomeCoordinator.Action)
        case map(MapCoordinator.Action)
        case archive(ArchiveCoordinator.Action)
        case myPage(MyPageCoordinator.Action)
        
        case delegate(Delegate)
        
        // binding
        case bindingTab(TabCase)
        
        enum Delegate {
            case tappedLogout
            case successRevoke
        }
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.home, action: \.home) {
            HomeCoordinator()
        }
        
        Scope(state: \.map, action: \.map) {
            MapCoordinator()
        }
        
        Scope(state: \.archive, action: \.archive) {
            ArchiveCoordinator()
        }
        
        Scope(state: \.myPage, action: \.myPage) {
            MyPageCoordinator()
        }
        
        Reduce { state, action in
            switch action {
            case let .bindingTab(tab):
                state.tabState = tab
                
            case .myPage(.delegate(.tappedLogout)):
                return .send(.delegate(.tappedLogout))
                
            case .myPage(.delegate(.successRevoke)):
                return .send(.delegate(.successRevoke))
                
            default:
                break
            }
            return .none
        }
    }
}
