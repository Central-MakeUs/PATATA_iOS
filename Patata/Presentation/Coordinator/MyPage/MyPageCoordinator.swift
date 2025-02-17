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
    }
    
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MyPageCoordinator {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            default:
                break
            }
            
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
