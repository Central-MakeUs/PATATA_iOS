//
//  RootPathFeature.swift
//  Patata
//
//  Created by 김진수 on 7/29/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct RootPathFeature {
    @ObservableState
    enum State {
        case splash(SplashFeature.State = .init())
        case onboarding(OnboardingFeature.State)
        case login(LoginNavigationFeature.State)
        case tabBar(TabCoordinator.State)
        case networkError(NetworkErrorFeature.State)
        
        init() { self = .splash() }
    }
    
    @CasePathable
    enum Action {
        case _sceneChange(State)
        
        case splash(SplashFeature.Action)
        case onboarding(OnboardingFeature.Action)
        case login(LoginNavigationFeature.Action)
        case tabBar(TabCoordinator.Action)
        case networkError(NetworkErrorFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
          switch action {
          case .tabBar:
            guard case .tabBar = state else { return .none }
          case .splash:
            guard case .splash = state else { return .none }
          case .onboarding:
            guard case .onboarding = state else { return .none }
          case .login:
            guard case .login = state else { return .none }
          case .networkError:
            guard case .networkError = state else { return .none }
          default:
            break
          }
          
            switch action {
            case let .splash(.delegate(.isFirstUser(isFirst))):
                if isFirst {
                    return .send(._sceneChange(.onboarding(.init())))
                } else if UserDefaultsManager.refreshToken.isEmpty || UserDefaultsManager.nickname.isEmpty {
                    return .send(._sceneChange(.login(LoginNavigationFeature.State())))
                } else {
                    return .send(._sceneChange(.tabBar(TabCoordinator.State())))
                }
                
            case .onboarding(.delegate(.startButtonTapped)):
                return .send(._sceneChange(.login(LoginNavigationFeature.State())))
                
            case .login(.delegate(.loginCompleted)):
                return .send(._sceneChange(.tabBar(TabCoordinator.State())))
                
            case .login(.delegate(.successChangeNickname)):
                return .send(._sceneChange(.tabBar(TabCoordinator.State())))
                
            case let ._sceneChange(new):
                state = new
                
            default:
                break
            }
            return .none
        }
        .ifCaseLet(\.splash, action: \.splash) {
            SplashFeature()
        }
        .ifCaseLet(\.onboarding, action: \.onboarding) {
            OnboardingFeature()
        }
        .ifCaseLet(\.login, action: \.login) {
            LoginNavigationFeature()
        }
        .ifCaseLet(\.tabBar, action: \.tabBar) {
            TabCoordinator()
        }
        .ifCaseLet(\.networkError, action: \.networkError) {
            NetworkErrorFeature()
        }
    }
}

