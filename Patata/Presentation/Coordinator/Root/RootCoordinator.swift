//
//  RootCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import ComposableArchitecture

@Reducer
struct RootCoordinator: Reducer {
    @ObservableState
    enum State {
        case splash(SplashFeature.State = .init())
        case onboarding(OnboardingFeature.State)
        case login(LoginFeature.State)
        case tabBar(TabCoordinator.State)
        
        init() { self = .splash() }
    }
    
    @CasePathable
    enum Action {
        case _sceneChange(State)
        case splashAction(SplashFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case login(LoginFeature.Action)
        case tabBar(TabCoordinator.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .splashAction(.delegate(.isFirstUser(isFirst))):
                if isFirst {
                    return .send(._sceneChange(.onboarding(.init())))
                } else {
                    return .send(._sceneChange(.login(.init())))
                }
                
            case .login(.delegate(.loginSuccess)):
                return .send(._sceneChange(.tabBar(TabCoordinator.State(tabState: .home))))
                
            case let ._sceneChange(new):
                state = new
                
            default:
                break
            }
            return .none
        }
        .ifCaseLet(\.splash, action: \.splashAction) {
            SplashFeature()
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginFeature()
        }
        .ifCaseLet(\.tabBar, action: \.tabBar) {
            TabCoordinator()
        }
    }
}

