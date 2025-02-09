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
        var beforeViewState: BeforeViewState
        var searchText: String = ""
        var searchResult: Bool = true
        var viewState: ViewState = .search
    }
    
    enum ViewState {
        case loading
        case search
        case searchResult
    }
    
    enum BeforeViewState {
        case home
        case map
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
            case tappedSpotDetail
        }
    }
    
    enum ViewEvent {
        case tappedBackButton
        case searchOnSubmit
        case searchStart
        case tappedSpotDetail // 나중에 탭하면서 서버에서 준 데이터도 같이 보내자
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
                if state.beforeViewState == .home {
                    state.viewState = .loading
                    
                    return .run { send in
                        try? await Task.sleep(for: .seconds(2))
                        await send(.switchViewState)
                    }
                } else {
                    return .send(.delegate(.successSearch))
                }
                
            case .viewEvent(.searchStart):
                state.searchText = ""
                state.viewState = .search
                
            case .viewEvent(.tappedSpotDetail):
                return .send(.delegate(.tappedSpotDetail))
                
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
