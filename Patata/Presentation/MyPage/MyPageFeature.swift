//
//  MyPageFeature.swift
//  Patata
//
//  Created by 김진수 on 2/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyPageFeature {
    @ObservableState
    struct State: Equatable {
        var imageCount: Int = 0
        
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        
        enum Delegate {
            case tappedSpot
        }
    }
    
    enum ViewEvent {
        case tappedSpot
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MyPageFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .viewEvent(.tappedSpot):
                return .send(.viewEvent(.tappedSpot))
                
            default:
                break
            }
            return .none
        }
    }
}
