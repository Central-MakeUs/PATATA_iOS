//
//  SearchFeature.swift
//  Patata
//
//  Created by 김진수 on 1/18/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var searchText: String = ""
        var searchResult: Bool = true
        var viewState: ViewState = .search
    }
    
    enum ViewState {
        case loading
        case search
        case searchResult
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case switchViewState
        case delegate(Delegate)
        // bindingAction
        case bindingSearchText(String)
        
        enum Delegate {
            case tappedBackButton
            // 이때 전달시 결과값들이 있으면 같이 전달
            case successSearch
        }
    }
    
    enum ViewEvent {
        case tappedBackButton
        case searchOnSubmit
        case searchStart
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SearchFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.searchOnSubmit):
                // network후 결과에 따라서 실패시 hidden 풀고
                // 성공시 화면 변경
                // 임시로 성공시 바로 delegate 전달로
                state.viewState = .loading
                
                return .run { send in
                    try? await Task.sleep(for: .seconds(2))
                    await send(.switchViewState)
                }
                
            case .viewEvent(.searchStart):
                state.searchText = ""
                state.viewState = .search
                
            case .switchViewState:
                state.viewState = .searchResult
                
            case let .bindingSearchText(text):
                state.searchText = text
                
            default:
                break
            }
            return .none
        }
    }
}
