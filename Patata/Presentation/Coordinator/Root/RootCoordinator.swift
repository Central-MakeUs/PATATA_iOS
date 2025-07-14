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
        var beforeViewState: RootCoordinatorViewState = .start
        var isPresent: Bool = false
        var currentNetworkState: Bool = true
        var networkIsValid: Bool = false
        var isFirst: Bool = true
        
        var tabCoordinator: TabCoordinator.State = TabCoordinator.State.initialState
        var networkFeatureState: NetworkErrorFeature.State = NetworkErrorFeature.State()
    }

    enum RootCoordinatorViewState: Equatable {
        case start
        case tab
        case networkError
    }

    enum Action {
        case router(IdentifiedRouterActionOf<RootScreen>)

        case tabCoordinatorAction(TabCoordinator.Action)
        case networkFeatureAction(NetworkErrorFeature.Action)
        case tokenExpired
        case viewCycle(ViewCycle)
        case appLifecycle(AppLifecycle)
        case locationAction(LocationAction)
        case networkErrorType(NetworkErrorType)
        case networkMonitorStart
        case changeViewState(Bool)
        case checkNetworkValid(Bool)
        case checkVersion
        case openAlert
        
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
    
    enum NetworkErrorType {
        case nwMonitor
    }
    
    enum LocationAction: Equatable {
        case permissionResponse(Bool)
    }
    
    @Dependency(\.nwPathMonitorManager) var nwPathMonitorManager
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.errorManager) var errorManager
    @Dependency(\.locationManager) var locationManager

    var body: some ReducerOf<Self> {
        Scope(state: \.tabCoordinator, action: \.tabCoordinatorAction) {
            TabCoordinator()
        }
        
        Scope(state: \.networkFeatureState, action: \.networkFeatureAction) {
            NetworkErrorFeature()
        }

        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .merge(
                    .run { send in
                        let permission = await locationManager.checkLocationPermission()
                        
                        await send(.locationAction(.permissionResponse(permission)))
                        await send(.networkMonitorStart)
                        await send(.checkVersion)
                    },
                    .run { send in
                        for await error in networkManager.getNetworkError() {
                            if errorManager.checkTokenError(error) {
                                await send(.tokenExpired)
                            }
                        }
                    }
                )
                
            case .networkMonitorStart:
                return .run { send in
                    nwPathMonitorManager.start()
                    await send(.networkErrorType(.nwMonitor))
                }
                
            case .networkErrorType(.nwMonitor):
                return .run { [state = state] send in
                    
                    for await isValid in  nwPathMonitorManager.getToConnectionTrigger() {
                        print(isValid)
                        if state.currentNetworkState != isValid {
                            if !isValid {
                                await send(.changeViewState(isValid))
                                print("networkError")
                            } else {
                                print("here")
                                await send(.checkNetworkValid(isValid))
                            }
                        } else {
                            print("trururururu")
                            await send(.checkNetworkValid(isValid))
                        }
                    }
                }
                
            case .checkVersion:
                return .run { send in
                    guard let marketingVersion = await AppStoreCheckManager().latestVersion() else {
                        print("앱스토어 버전을 찾지 못했습니다.")
                        return
                    }
                    // 현재 기기의 버전
                    let currentProjectVersion = AppStoreCheckManager.appVersion ?? ""
                    
                    // 앱스토어의 버전을 .을 기준으로 나눈 것
                    let splitMarketingVersion = marketingVersion.split(separator: ".").map { $0 }
                    
                    // 현재 기기의 버전을 .을 기준으로 나눈 것
                    let splitCurrentProjectVersion = currentProjectVersion.split(separator: ".").map { $0 }
                    
                    if splitCurrentProjectVersion.count > 0 && splitMarketingVersion.count > 0 {
                        
                        // 현재 기기의 Major 버전이 앱스토어의 Major 버전보다 낮다면 알럿을 띄운다.
                        if splitCurrentProjectVersion[0] < splitMarketingVersion[0] {
                            await send(.openAlert)
                            // 현재 기기의 Minor 버전이 앱스토어의 Minor 버전보다 낮다면 알럿을 띄운다.
                        } else if splitCurrentProjectVersion[1] < splitMarketingVersion[1] {
                            await send(.openAlert)
                            // Patch의 버전이 다르거나 최신 버전이라면 아무 알럿도 띄우지 않는다.
                        } else {
                            print("현재 최신 버전입니다.")
                        }
                    }
                }
                
            case .openAlert:
                state.isPresent = true
                
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
//                state.isPresent = !hasPermission
                
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
                } else if UserDefaultsManager.refreshToken.isEmpty || UserDefaultsManager.nickname.isEmpty {
                    state.routes.push(.login(LoginFeature.State()))
                } else {
                    state.viewState = .tab
                }
                
            case .router(.routeAction(id: _, action: .onboarding(.delegate(.startButtonTapped)))):
                state.routes.push(.login(LoginFeature.State()))
                
            case .router(.routeAction(id: _, action: .login(.delegate(.loginSuccess)))):
                if UserDefaultsManager.nickname.isEmpty {
                    let newRoutes: IdentifiedArrayOf<Route<RootScreen.State>> = [
                        .root(.login(LoginFeature.State()), embedInNavigationView: true),
                        .push(.profileEdit(ProfileEditFeature.State(
                            viewState: .first,
                            profileData: MyPageEntity()
                        )))
                    ]
                    state.routes = newRoutes
                    
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
                let newRoutes: IdentifiedArrayOf<Route<RootScreen.State>> = [
                    .root(.login(LoginFeature.State()), embedInNavigationView: true)
                ]
                
                state.viewState = .start
                state.routes = newRoutes
                state.tabCoordinator = TabCoordinator.State.initialState
                
                UserDefaultsManager.accessToken = ""
                UserDefaultsManager.refreshToken = ""
                UserDefaultsManager.nickname = ""
                UserDefaultsManager.appleUser = false
                
            case .tabCoordinatorAction(.delegate(.successRevoke)):
                let newRoutes: IdentifiedArrayOf<Route<RootScreen.State>> = [
                    .root(.login(LoginFeature.State()), embedInNavigationView: true)
                ]
                
                state.viewState = .start
                state.routes = newRoutes
                state.tabCoordinator = TabCoordinator.State.initialState
                
                UserDefaultsManager.accessToken = ""
                UserDefaultsManager.refreshToken = ""
                UserDefaultsManager.nickname = ""
                UserDefaultsManager.appleUser = false
                
            case let .changeViewState(isValid):
                state.networkIsValid = isValid
                 
                if state.isFirst {
                    state.beforeViewState = state.viewState
                }
                
                state.viewState = .networkError
                state.isFirst = false
                
            case .networkFeatureAction(.delegate(.tappedButton)):
                if state.networkIsValid {
                    state.viewState = state.beforeViewState
                    state.isFirst = true
                }
                
            case let .checkNetworkValid(valid):
                state.networkIsValid = valid
                
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
