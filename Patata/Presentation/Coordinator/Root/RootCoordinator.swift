//
//  RootCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer(state: .equatable)
enum RootScreen {
    case splash(SplashFeature)
    case onboardPage(OnboardPageFeature)
}

@Reducer
struct RootCoordinator {
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.splash(SplashFeature.State()), embedInNavigationView: true)])

        var routes: IdentifiedArrayOf<Route<RootScreen.State>>
        var viewState: RootCoordinatorViewState = .start

        var tabCoordinator: TabCoordinator.State = TabCoordinator.State.initialState
    }

    enum RootCoordinatorViewState: Equatable {
        case start
        case tab
    }

    enum Action {
        case router(IdentifiedRouterActionOf<RootScreen>)

        case tabCoordinatorAction(TabCoordinator.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.tabCoordinator, action: \.tabCoordinatorAction) {
            TabCoordinator()
        }

        Reduce { state, action in
            switch action {
            default:
                break
            }

            return .none
        }
    }
}
