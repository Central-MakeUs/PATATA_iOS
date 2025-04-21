//
//  NetworkErrorFeature.swift
//  Patata
//
//  Created by 김진수 on 2/28/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct NetworkErrorFeature {
    
    @ObservableState
    struct State: Equatable {

    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedButton
        }
    }
    
    enum ViewEvent {
        case tappedButton
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedButton):
                return .send(.delegate(.tappedButton))
                
            default:
                break
            }
            return .none
        }
    }
}
