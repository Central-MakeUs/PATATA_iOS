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
    case success(SuccessFeature)
}

@Reducer
struct RootCoordinator {
    @ObservableState
    struct State: Equatable, Sendable {
        static let initialState = State(routes: [.root(.splash(SplashFeature.State()), embedInNavigationView: true)])

        var routes: IdentifiedArrayOf<Route<RootScreen.State>>
        var viewState: RootCoordinatorViewState = .start
        var isPresent: Bool = false
        
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
        case appLifecycle(AppLifecycle)
        case locationAction(LocationAction)
        
        case bindingIsPresent(Bool)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum AppLifecycle {
        case background
        case willEnterForeground
        case active
        case inactive
    }
    
    enum LocationAction: Equatable {
        case permissionResponse(Bool)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.errorManager) var errorManager
    @Dependency(\.locationManager) var locationManager

    var body: some ReducerOf<Self> {
        Scope(state: \.tabCoordinator, action: \.tabCoordinatorAction) {
            TabCoordinator()
        }

        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .merge(
                    .run { send in
                        let permission = await locationManager.checkLocationPermission()
                        
                        await send(.locationAction(.permissionResponse(permission)))
                    },
                    .run { send in
                        for await error in networkManager.getNetworkError() {
                            if errorManager.checkTokenError(error) {
                                await send(.tokenExpired)
                            }
                        }
                    }
                )
                
            case .appLifecycle(.background):
                return .run { _ in
                    locationManager.stopUpdatingLocation()
                }
                
            case .appLifecycle(.active):
                return .run { send in
                    let hasPermission = await locationManager.checkLocationPermission()
                    await send(.locationAction(.permissionResponse(hasPermission)))
                }
                
            case .appLifecycle(.inactive):
                return .run { _ in
                    locationManager.stopUpdatingLocation()
                }
                
            case let .locationAction(.permissionResponse(hasPermission)):
                state.isPresent = !hasPermission
                
                return .run { _ in
                    if hasPermission {
                        locationManager.startUpdatingLocation()
                    } else {
                        locationManager.stopUpdatingLocation()
                    }
                }
                
            case let .router(.routeAction(id: _, action: .splash(.delegate(.isFirstUser(trigger))))):
                
                if trigger {
                    state.routes.push(.onboarding(OnboardPageFeature.State()))
                } else if UserDefaultsManager.refreshToken.isEmpty {
                    state.routes.push(.login(LoginFeature.State()))
                } else {
                    state.viewState = .tab
                }
                
            case .router(.routeAction(id: _, action: .onboarding(.delegate(.startButtonTapped)))):
                state.routes.push(.login(LoginFeature.State()))
                
            case .router(.routeAction(id: _, action: .login(.delegate(.loginSuccess)))):
                if UserDefaultsManager.nickname.isEmpty {
                    state.routes.push(.profileEdit(ProfileEditFeature.State(viewState: .first, nickname: UserDefaultsManager.nickname, initialNickname: UserDefaultsManager.nickname)))
                } else {
                    state.viewState = .tab
                }
                
            case .router(.routeAction(id: _, action: .profileEdit(.delegate(.successChangeNickname)))):
                state.routes.push(.success(SuccessFeature.State(viewState: .first)))
                
            case let .router(.routeAction(id: _, action: .profileEdit(.delegate(.tappedBackButton(viewState))))):
                if viewState == .first {
                    state.routes.pop()
                }
                
            case .router(.routeAction(id: _, action: .success(.delegate(.tappedConfirmButton)))):
                state.viewState = .tab
                
            case .tabCoordinatorAction(.delegate(.tappedLogout)):
                UserDefaultsManager.accessToken = ""
                UserDefaultsManager.refreshToken = ""
                UserDefaultsManager.nickname = ""
                UserDefaultsManager.email = ""
                
                state.viewState = .start
                state.routes.push(.login(LoginFeature.State()))
                
            case .tabCoordinatorAction(.delegate(.successRevoke)):
                UserDefaultsManager.accessToken = ""
                UserDefaultsManager.refreshToken = ""
                UserDefaultsManager.nickname = ""
                UserDefaultsManager.email = ""
                
                state.viewState = .start
                state.routes.push(.login(LoginFeature.State()))
                
            case .tokenExpired:
                state.routes.removeAll()
                state.viewState = .start
                state.routes.push(.login(LoginFeature.State()))
                
            case let .bindingIsPresent(isValid):
                state.isPresent = isValid
                
            default:
                break
            }

            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
