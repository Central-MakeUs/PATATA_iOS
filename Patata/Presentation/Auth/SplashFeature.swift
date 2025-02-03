//
//  SplashFeature.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SplashFeature {
    
    @ObservableState
    struct State: Equatable {
        
        let isFirstUser = /*UserDefaultsManager.isFirst*/ false
    }
    
    enum Action {
        case onAppear
        case delegate(Delegate)
        enum Delegate {
            case isFirstUser(Bool)
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                UserDefaultsManager.isFirst = false
                
                return .run { [state = state] send in
                    try await Task.sleep(for: .seconds(2))
                    await send(.delegate(.isFirstUser(state.isFirstUser)))
                }
            default:
                break
            }
            return .none
        }
    }
}
