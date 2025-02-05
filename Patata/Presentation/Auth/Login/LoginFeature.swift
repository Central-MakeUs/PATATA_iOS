//
//  LoginFeature.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation
import ComposableArchitecture

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
        case tappedGoogleLogin
        case tappedStartButton
        case nickName
    }
    
    enum NetworkType {
        case googleLogin(String)
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
                
            case .viewEvent(.tappedGoogleLogin):
                return .run { send in
                    let idToken = try await loginManager.googleLogin()
                    await send(.networkType(.googleLogin(idToken.tokenString)))
                }
                
            case .viewEvent(.nickName):
                return .run { send in
                    await loginRepository.changeNickName()
                }
                
            case let .networkType(.googleLogin(token)):
                return .run { send in
                    let result = await loginRepository.googleLogin(idToken: token)
                    
                    UserDefaultsManager.accessToken = result!.result.accessToken
                    UserDefaultsManager.refreshToken = result!.result.refreshToken
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
