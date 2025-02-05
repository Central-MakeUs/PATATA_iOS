//
//  LoginFeature.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation
import ComposableArchitecture
import AuthenticationServices

@Reducer
struct LoginFeature {

    @ObservableState
    struct State: Equatable {
        var currentIndex: Int = 0
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        
        case delegate(Delegate)
        
        enum Delegate {
            case startButtonTapped
        }
        
        // bindingAction
        case bindingCurrentIndex(Int)
    }
    
    enum ViewEvent {
        case tappedAppleLogin(Result<ASAuthorization, any Error>)
        case tappedGoogleLogin
        case tappedStartButton
    }
    
    enum NetworkType {
        case googleLogin(String)
        case appleLogin(String)
    }
    
    @Dependency(\.loginManager) var loginManager
    @Dependency(\.loginRepository) var loginRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .viewEvent(.tappedStartButton):
                if state.currentIndex == 2 {
                    return .send(.delegate(.startButtonTapped))
                } else {
                    state.currentIndex += 1
                }
                
            case let .viewEvent(.tappedAppleLogin(result)):
                return .run { send in
                    let identityToken = try await loginManager.appleLoginResult(result: result)
                    await send(.networkType(.appleLogin(identityToken)))
                }
                
            case .viewEvent(.tappedGoogleLogin):
                return .run { send in
                    let idToken = try await loginManager.googleLogin()
                    await send(.networkType(.googleLogin(idToken.tokenString)))
                }
                
            case let .networkType(.googleLogin(token)):
                return .run { send in
                    let result = await loginRepository.googleLogin(idToken: token)
                    
                    UserDefaultsManager.accessToken = result!.result.accessToken
                    UserDefaultsManager.refreshToken = result!.result.refreshToken
                }
                
            case let .networkType(.appleLogin(token)):
                return .run { send in
                    let result = await loginRepository.appleLogin(identityToken: token)
                    
//                    UserDefaultsManager.accessToken = result?.result.accessToken
//                    UserDefaultsManager.refreshToken = result?.result.refreshToken
                }
                
            case let .bindingCurrentIndex(index):
                state.currentIndex = index
             
            default:
                break
            }
            
            return .none
        }
    }
}
