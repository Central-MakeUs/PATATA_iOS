//
//  LoginNavigationFeature.swift
//  Patata
//
//  Created by 김진수 on 7/29/25.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum LoginPath {
    case login(LoginFeature)
    case profileEdit(ProfileEditFeature)
    case success(SuccessFeature)
}

@Reducer
struct LoginNavigationFeature {
    
    @ObservableState
    struct State: Equatable {
        var routes: StackState<LoginPath.State> = .init()
        var root = LoginFeature.State()
    }

    enum Action {
        case routes(StackActionOf<LoginPath>)
        case root(LoginFeature.Action)
        case delegate(Delegate)

        enum Delegate {
            case loginCompleted
            case tappedBackButton
            case successChangeNickname
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.root, action: \.root) {
            LoginFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .root(.delegate(.loginSuccess)):
                if UserDefaultsManager.nickname.isEmpty {
                    state.routes.append(.profileEdit(ProfileEditFeature.State(viewState: .first, profileData: .init())))
                } else {
                    return .send(.delegate(.loginCompleted))
                }

            case .routes(.element(id: _, action: .profileEdit(.delegate(.successChangeNickname)))):
                state.routes.append(.success(SuccessFeature.State(viewState: .first)))
                
            case .routes(.element(id: _, action: .profileEdit(.delegate(.tappedBackButton(_))))):
                _ = state.routes.popLast()
                
            case .routes(.element(id: _, action: .success(.delegate(.tappedConfirmButton)))):
                return .send(.delegate(.successChangeNickname))

            default:
                break
            }
            return .none
        }
        .forEach(\.routes, action: \.routes)
    }
}
