//
//  SuccessFeature.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SuccessFeature {
    @ObservableState
    struct State: Equatable {
        var viewState: ViewState
    }
    
    enum ViewState {
        case first
        case spot
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedConfirmButton
        }
    }
    
    enum ViewEvent {
        case tappedConfirmButton
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedConfirmButton):
                return .send(.delegate(.tappedConfirmButton))

            default:
                break
            }
            return .none
        }
    }
}
