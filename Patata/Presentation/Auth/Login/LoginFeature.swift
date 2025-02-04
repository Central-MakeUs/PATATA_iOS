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
    }
    
    enum NetworkType {
        case googleLogin(String)
    }
    
    @Dependency(\.loginManager) var loginManager
    
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
                
            case let .networkType(.googleLogin(token)):
                print(token)
                
            case let .bindingCurrentIndex(index):
                state.currentIndex = index
             
            default:
                break
            }
            
            return .none
        }
    }
}
