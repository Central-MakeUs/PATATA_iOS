//
//  SpotDetailFeature.swift
//  Patata
//
//  Created by 김진수 on 1/23/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SpotDetailFeature {
    @ObservableState
    struct State: Equatable {
        var isHomeCoordinator: Bool
        
        // bindingState
        var currentIndex: Int = 0
        var saveIsTapped: Bool = false
        var commentText: String = ""
        var bottomSheetIsPresent: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        // bindingAction
        case bindingCurrentIndex(Int)
        case bindingSaveIsTapped(Bool)
        case bindingCommentText(String)
        case bindingBottomSheetIsPresent(Bool)
        
        enum Delegate {
            case tappedNavBackButton
            case tappedDismissIcon
        }
    }
    
    enum ViewEvent {
        case bottomSheetOpen
        case bottomSheetClose
        case tappedNavBackButton
        case tappedDismissIcon
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotDetailFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedNavBackButton):
                return .send(.delegate(.tappedNavBackButton))
                
            case .viewEvent(.bottomSheetOpen):
                state.bottomSheetIsPresent = true
                
            case .viewEvent(.bottomSheetClose):
                state.bottomSheetIsPresent = false
                
            case .viewEvent(.tappedDismissIcon):
                return .send(.delegate(.tappedDismissIcon))
                
            case let .bindingCurrentIndex(index):
                state.currentIndex = index
                
            case let .bindingSaveIsTapped(isTapped):
                state.saveIsTapped = isTapped
                
            case let .bindingCommentText(comment):
                state.commentText = comment
                
            case let .bindingBottomSheetIsPresent(isPresent):
                state.bottomSheetIsPresent = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}
