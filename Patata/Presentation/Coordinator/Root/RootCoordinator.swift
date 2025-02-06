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
    case onboarding(OnboardPageFeature)
    case login(LoginFeature)
    case profileEdit(ProfileEditFeature)
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
        case tokenExpired
        case viewCycle(ViewCycle)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.errorManager) var errorManager

    var body: some ReducerOf<Self> {
        Scope(state: \.tabCoordinator, action: \.tabCoordinatorAction) {
            TabCoordinator()
        }

        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    for await error in networkManager.getNetworkError() {
                        if errorManager.checkTokenError(error) {
                            await send(.tokenExpired)
                        }
                    }
                }
                
            case let .router(.routeAction(id: _, action: .splash(.delegate(.isFirstUser(trigger))))):
                // 로그인을 했는데 닉네임을 설정하지 않고 그냥 앱을 껐을경우
                // 로그인을 하지않고 앱을 껐을경우
                if trigger {
                    state.routes.push(.onboarding(OnboardPageFeature.State()))
                } else if UserDefaultsManager.nickname.isEmpty {
                    state.routes.push(.login(LoginFeature.State()))
                } else {
                    state.viewState = .tab
                }
                
            case .router(.routeAction(id: _, action: .onboarding(.delegate(.startButtonTapped)))):
                state.routes.push(.login(LoginFeature.State()))
                
            case .router(.routeAction(id: _, action: .login(.delegate(.loginSuccess)))):
                if UserDefaultsManager.nickname.isEmpty {
                    state.routes.push(.profileEdit(ProfileEditFeature.State()))
                } else {
                    state.viewState = .tab
                }
                
            case .tokenExpired:
                state.routes.removeAll()
                state.routes.push(.login(LoginFeature.State()))
                
            default:
                break
            }

            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
