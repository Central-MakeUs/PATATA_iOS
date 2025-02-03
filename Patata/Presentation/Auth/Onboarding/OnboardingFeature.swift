//
//  OnboardingFeature.swift
//  Patata
//
//  Created by 김진수 on 2/4/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct OnboardPageFeature {
    
    struct State: Equatable {}
    
    enum Action {
        
        case startButtonTapped
        
        case delegate(Delegate)
        
        enum Delegate {
            case startButtonTapped
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .startButtonTapped:
                return .send(.delegate(.startButtonTapped))
             
            default:
                break
            }
            
            return .none
        }
    }
}
