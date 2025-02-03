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
        var profileImage: String = "MyPageActive"
        var nickname: String = "가나다라마바사"
        var email: String = "adsafas@gmail.com"
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        
        enum Delegate {
            case tappedSpot
            case tappedProfileEdit
        }
    }
    
    enum ViewEvent {
        case tappedSpot
        case tappedProfileEdit
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MyPageFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedSpot):
                return .send(.viewEvent(.tappedSpot))
                
            case .viewEvent(.tappedProfileEdit):
                return .send(.viewEvent(.tappedProfileEdit))
                
            default:
                break
            }
            return .none
        }
    }
}
