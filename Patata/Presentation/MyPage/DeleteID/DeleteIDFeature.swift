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
        case delegate(Delegate)
        
        enum Delegate {
            case tappedBackButton
            case tappedDeleteID
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
                return .send(.delegate(.tappedDeleteID))
                
            case .viewEvent(.tappedCheckButton):
                state.checkIsValid.toggle()
                
            default:
                break
            }
            return .none
        }
    }
}
