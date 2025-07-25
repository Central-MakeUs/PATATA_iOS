//
//  RootCoordinator.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import ComposableArchitecture
@preconcurrency import TCACoordinators

@Reducer
struct RootCoordinator: Reducer {
    @ObservableState
    enum State {
        case splash(SplashFeature.State = .init())
        case onboarding(OnboardingFeature.State)
        case login(LoginFeature.State)
        
        
        init() { self = .splash() }
    }
    
    @CasePathable
    enum Action {
        case _sceneChange(State)
        case splashAction(SplashFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case login(LoginFeature.Action)
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
    }
}

