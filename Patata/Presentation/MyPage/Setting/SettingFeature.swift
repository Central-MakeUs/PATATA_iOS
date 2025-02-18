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
        var appVersion: String = ""
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
            case tappedDeleteID
            case tappedOpenSource
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
        case tappedDeleteID
        case tappedOpenSource
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SettingFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
                
                state.appVersion = appVersion
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.tappedLogout):
                return .send(.delegate(.tappedLogout))
                
            case .viewEvent(.tappedDeleteID):
                return .send(.delegate(.tappedDeleteID))
                
            case .viewEvent(.tappedOpenSource):
                return .send(.delegate(.tappedOpenSource))
                
            default:
                break
            }
            return .none
        }
    }
}
