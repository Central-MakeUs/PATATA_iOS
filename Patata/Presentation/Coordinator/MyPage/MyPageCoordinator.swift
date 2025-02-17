//
//  MyPageCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum MyPageScreen {
    case myPage(MyPageFeature)
    case setting(SettingFeature)
    case deleteID(DeleteIDFeature)
}

@Reducer
struct MyPageCoordinator {
    
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.myPage(MyPageFeature.State()), embedInNavigationView: true)])
        var routes: IdentifiedArrayOf<Route<MyPageScreen.State>>
        
        var isHideTabBar: Bool = false
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<MyPageScreen>)
        
        case delegate(Delegate)
        
        enum Delegate {
            case tappedLogout
            case successRevoke
        }
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MyPageCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .router(.routeAction(id: .myPage, action: .myPage(.delegate(.tappedSetting)))):
                state.isHideTabBar = true
                state.routes.push(.setting(SettingFeature.State()))
                
            case .router(.routeAction(id: .setting, action: .setting(.delegate(.tappedBackButton)))):
                state.isHideTabBar = false
                state.routes.pop()
                
            case .router(.routeAction(id: .setting, action: .setting(.delegate(.tappedLogout)))):
                return .send(.delegate(.tappedLogout))
                
            case .router(.routeAction(id: .setting, action: .setting(.delegate(.tappedDeleteID)))):
                state.routes.push(.deleteID(DeleteIDFeature.State()))
                
            case .router(.routeAction(id: .deleteID, action: .deleteID(.delegate(.tappedBackButton)))):
                state.routes.pop()
                
            case .router(.routeAction(id: .deleteID, action: .deleteID(.delegate(.succesRevoke)))):
                return .send(.delegate(.successRevoke))
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
