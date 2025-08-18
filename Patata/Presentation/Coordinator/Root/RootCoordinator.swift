//
//  RootCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import ComposableArchitecture

@Reducer
struct RootCoordinator {
    @ObservableState
    struct State {
        var rootPath = RootPathFeature.State()
        
        var currentNetworkState: Bool = true
        var isPresent: Bool = false
        
        var networkIsValid: Bool = false
        var beforeViewState: RootPathFeature.State = .splash(SplashFeature.State())
        var networkChangeFirst: Bool = true
    }
    
    enum Action {
        case rootPath(RootPathFeature.Action)
        case viewCycle(ViewCycle)
        case locationAction(LocationAction)
        case networkErrorType(NetworkErrorType)
        case appLifecycle(AppLifecycle)
        case networkMonitorStart
        case checkVersion
        case tokenExpired
        case openAlert
        
        case changeViewState(Bool)
        case checkNetworkValid(Bool)
    }
    
    enum LocationAction: Equatable {
        case permissionResponse(Bool)
    }
    
    enum NetworkErrorType {
        case nwMonitor
    }
    
    enum AppLifecycle {
        case background
        case willEnterForeground
        case active
        case inactive
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    @Dependency(\.nwPathMonitorManager) var nwPathMonitorManager
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.errorManager) var errorManager
    @Dependency(\.locationManager) var locationManager
    
    var body: some ReducerOf<Self> {
        Scope(state: \.rootPath, action: \.rootPath) {
            RootPathFeature()
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
                        if state.currentNetworkState != isValid {
                            if !isValid {
                                await send(.changeViewState(isValid))
                            } else {
                                await send(.checkNetworkValid(isValid))
                            }
                        } else {
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
                
            case .tokenExpired:
                return .send(.rootPath(._sceneChange(.login(LoginNavigationFeature.State()))))
                
            case let .checkNetworkValid(valid):
                state.networkIsValid = valid
                
            case let .changeViewState(isValid):
                state.networkIsValid = isValid
                
                if state.networkChangeFirst {
                    state.beforeViewState = state.rootPath
                }
                
                state.networkChangeFirst = false
                
                return .send(.rootPath(._sceneChange(.networkError(NetworkErrorFeature.State()))))
                
            case .rootPath(.networkError(.delegate(.tappedButton))):
                if state.networkIsValid {
                    state.networkChangeFirst = true
                    
                    switch state.beforeViewState {
                    case let .splash(state):
                        return .send(.rootPath(._sceneChange(.splash(state))))
                    case let .onboarding(state):
                        return .send(.rootPath(._sceneChange(.onboarding(state))))
                    case let .login(state):
                        return .send(.rootPath(._sceneChange(.login(state))))
                    case let .tabBar(state):
                        return .send(.rootPath(._sceneChange(.tabBar(state))))
                    case let .networkError(state):
                        return .send(.rootPath(._sceneChange(.networkError(state))))
                    }
                }
                
            default :
                break
            }
            
            return .none
        }
    }
}

