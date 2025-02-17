//
//  DeleteIDFeature.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DeleteIDFeature {
    @ObservableState
    struct State: Equatable {
        var checkIsValid: Bool = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedBackButton
            case tappedDeleteID
            case succesRevoke
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedBackButton
        case tappedCheckButton
        case tappedDeleteID
    }
    
    enum NetworkType {
        case appleRevoke(String)
    }
    
    enum DataTransType {
        case appleAuthToken(String)
        case revokeResult(Bool)
    }
    
    @Dependency(\.loginManager) var loginManager
    @Dependency(\.loginRepository) var loginRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension DeleteIDFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.tappedDeleteID):
                if UserDefaultsManager.appleUser {
                    return .run { send in
                        do {
                            let authorization = try await loginManager.getASAuthorization()
                            
                            let authToken = loginManager.handleAuthorization(authorization)
                            
                            if let auth = authToken.auth {
                                await send(.dataTransType(.appleAuthToken(auth)))
                            }
                        } catch {
                            print("fail", errorManager.handleError(error) ?? "")
                        }
                    }
                } else {
                    print("a")
                }
                
            case .viewEvent(.tappedCheckButton):
                state.checkIsValid.toggle()
                
            case let .networkType(.appleRevoke(authToken)):
                return .run { send in
                    do {
                        let isValid = try await loginRepository.revokeApple(authToken: authToken)
                        
                        print(isValid)
                        await send(.dataTransType(.revokeResult(isValid)))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.appleAuthToken(authToken)):
                return .run { send in
                    await send(.networkType(.appleRevoke(authToken)))
                }
                
            case let .dataTransType(.revokeResult(isValid)):
                if isValid {
                    return .send(.delegate(.succesRevoke))
                }
                
            default:
                break
            }
            return .none
        }
    }
}
