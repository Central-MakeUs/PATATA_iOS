//
//  SettingFeature.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SettingFeature {
    @ObservableState
    struct State: Equatable {
        
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSpot
            case tappedProfileEdit
            case tappedBackButton
            case tappedLogout
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedSpot
        case tappedProfileEdit
        case tappedBackButton
        case tappedLogout
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SettingFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.tappedLogout):
                return .send(.delegate(.tappedLogout))
                
            default:
                break
            }
            return .none
        }
    }
}
