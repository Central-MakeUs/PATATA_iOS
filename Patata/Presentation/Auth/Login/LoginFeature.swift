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
        var errorMSG: String = ""
        var isPresent: Bool = false
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
        case bindingIsPresent(Bool)
    }
    
    enum ViewEvent {
        case tappedAppleLogin
        case tappedGoogleLogin
        case tappedStartButton
        case dismiss
    }
    
    enum NetworkType {
        case googleLogin(String)
        case appleLogin(String)
    }
    
    enum DataTransType {
        case loginEntity(LoginEntity)
        case error(Error)
    }
    
    @Dependency(\.loginManager) var loginManager
    @Dependency(\.loginRepository) var loginRepository
    @Dependency(\.errorManager) var errorManager
    
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
                        await send(.dataTransType(.error(error)))
                    }
                }
                
            case .viewEvent(.tappedGoogleLogin):
                return .run { send in
                    do {
                        let idToken = try await loginManager.googleLogin()
                        print("success", idToken)
                        await send(.networkType(.googleLogin(idToken.tokenString)))
                    } catch {
                        await send(.dataTransType(.error(error)))
                    }
                }
                
            case .viewEvent(.dismiss):
                state.isPresent = false
                
            case let .networkType(.googleLogin(token)):
                return .run { send in
                    do {
                        let data = try await loginRepository.googleLogin(idToken: token)
                        
                        await send(.dataTransType(.loginEntity(data)))
                    } catch {
                        await send(.dataTransType(.error(error)))
                    }
                }
                
            case let .networkType(.appleLogin(token)):
                return .run { send in
                    do {
                        let data = try await loginRepository.appleLogin(identityToken: token)
                        
                        await send(.dataTransType(.loginEntity(data)))
                    } catch {
                        await send(.dataTransType(.error(error)))
                    }
                }
                
            case let .dataTransType(.loginEntity(loginEntity)):
                UserDefaultsManager.nickname = loginEntity.nickName ?? ""
                return .send(.delegate(.loginSuccess))
                
            case let .dataTransType(.error(error)):
                if let error = error as? PAError {
                    switch error {
                    case .errorMessage(.member(.usedNickname)):
                        state.errorMSG = "이미 다른 소셜로 회원가입한 회원입니다.\n다른 계정으로 로그인해주세요."
                        state.isPresent = true
                    case .errorMessage(.member(.deleteMember)):
                        state.errorMSG = "탈퇴한 회원입니다.\n30일 내에 가입이 불가능합니다."
                        state.isPresent = true
                    default:
                        print("fail", error, errorManager.handleError(error) ?? "")
                    }
                } else {
                    print("fail", error, errorManager.handleError(error) ?? "")
                }
                
            case let .bindingCurrentIndex(index):
                state.currentIndex = index
             
            case let .bindingIsPresent(isPresent):
                state.isPresent = isPresent
                
            default:
                break
            }
            
            return .none
        }
    }
}
