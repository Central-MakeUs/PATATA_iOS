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
    
    @ObservableState
    struct State: Equatable {
        var currentIndex: Int = 0
    }
    
    enum Action {
        
        case startButtonTapped
        
        case delegate(Delegate)
        
        enum Delegate {
            case startButtonTapped
        }
        
        // bindingAction
        case bindingCurrentIndex(Int)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .startButtonTapped:
                if state.currentIndex == 2 {
                    return .send(.delegate(.startButtonTapped))
                } else {
                    state.currentIndex += 1
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
