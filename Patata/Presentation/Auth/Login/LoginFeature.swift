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
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case startButtonTapped
            case loginSuccess
        }
        
        // bindingAction
        case bindingCurrentIndex(Int)
    }
    
    enum ViewEvent {
        case tappedAppleLogin
        case tappedGoogleLogin
        case tappedStartButton
    }
    
    enum NetworkType {
        case googleLogin(String)
        case appleLogin(String)
    }
    
    enum DataTransType {
        case loginEntity(LoginEntity)
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
                
            case .viewEvent(.tappedAppleLogin):
                return .run { send in
                    do {
                        let authorization = try await loginManager.getASAuthorization()
                        
                        let tokens = loginManager.handleAuthorization(authorization)
                        
                        if let idToken = tokens.id {
                            await send(.networkType(.appleLogin(idToken)))
                        }
                    } catch {
                        print(error)
                    }
                }
                
            case .viewEvent(.tappedGoogleLogin):
                return .run { send in
                    do {
                        let idToken = try await loginManager.googleLogin()
                        print("success", idToken)
                        await send(.networkType(.googleLogin(idToken.tokenString)))
                    } catch {
                        print(error)
                    }
                }
                
            case let .networkType(.googleLogin(token)):
                return .run { send in
                    do {
                        let data = try await loginRepository.googleLogin(idToken: token)
                        
                        await send(.dataTransType(.loginEntity(data)))
                    } catch {
                        print(error)
                    }
                }
                
            case let .networkType(.appleLogin(token)):
                return .run { send in
                    do {
                        let data = try await loginRepository.appleLogin(identityToken: token)
                        
                        await send(.dataTransType(.loginEntity(data)))
                    } catch {
                        print(error)
                    }
                }
                
            case let .dataTransType(.loginEntity(loginEntity)):
                UserDefaultsManager.nickname = loginEntity.nickName ?? ""
                return .send(.delegate(.loginSuccess))
                
            case let .bindingCurrentIndex(index):
                state.currentIndex = index
             
            default:
                break
            }
            
            return .none
        }
    }
}
