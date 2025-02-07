//
//  SpotCategoryFeature.swift
//  Patata
//
//  Created by 김진수 on 1/22/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SpotCategoryFeature {
    @ObservableState
    struct State: Equatable {
        let titles = ["전체", "작가추천", "스냅스팟", "시크한 아경", "일상 속 공감", "싱그러운"]
        
        var selectedIndex: Int = 0
        var isPresent: Bool = false
        var filterText: String = "거리순"
        var spotDetailState = SpotDetailFeature.State(isHomeCoordinator: false)
        var spotItems: SpotEntity = SpotEntity()
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case spotDetailAction(SpotDetailFeature.Action)
        
        case delegate(Delegate)
        
        // bindingAction
        case bindingIsPresent(Bool)
        
        enum Delegate {
            case tappedNavBackButton
        }
    }
    
    enum ViewEvent {
        case selectedMenu(Int)
        case openBottomSheet
        case tappedBottomSheetItem(String)
        case tappedNavBackButton
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.spotDetailState, action: \.spotDetailAction) {
            SpotDetailFeature()
        }
        
        core()
    }
}

extension SpotCategoryFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .viewEvent(.selectedMenu(index)):
                state.selectedIndex = index
                
            case .viewEvent(.openBottomSheet):
                state.isPresent = true
                
            case let .viewEvent(.tappedBottomSheetItem(filter)):
                state.filterText = filter
                state.isPresent = false
                
            case .viewEvent(.tappedNavBackButton):
                return .send(.delegate(.tappedNavBackButton))
             
            case .spotDetailAction(.delegate(.tappedDismissIcon)):
                state.isPresent = false
                
            case let .bindingIsPresent(isPresent):
                state.isPresent = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}
