//
//  PatataMainFeature.swift
//  Patata
//
//  Created by 김진수 on 1/16/25.
//

import ComposableArchitecture

@Reducer
struct PatataMainFeature {
    
    @ObservableState
    struct State: Equatable {
        let categoryItems = [
            CategoryItem(
                item: "전체",
                images: "RecommendIcon"
            ),
            CategoryItem(
                item: "작가 추천",
                images: "RecommendIcon"
            ),
            CategoryItem(
                item: "스냅스팟",
                images: "RecommendIcon"
            ),
            CategoryItem(
                item: "시크한 야경",
                images: "RecommendIcon"
            ),
            CategoryItem(
                item: "싱그러운 자연",
                images: "RecommendIcon"
            )
        ]
        
        let recommendItem = RecommendSpotItem()
        var categorySelect: Bool = false
        var selectedIndex: Int = 0
        var currentIndex: Int = 0
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSearch
            case tappedAddButton
            case tappedSpot // 보낼때 데이터도 같이
        }
    }
    
    enum ViewCycle {
        
    }
    
    enum ViewEvent {
        case selectCategory(Int)
        case tappedSearch
        case tappedAddButton
        case tappedSpot // 보낼때 데이터도 같이
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension PatataMainFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .viewEvent(.selectCategory(index)):
                state.selectedIndex = index
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.tappedAddButton):
                return .send(.delegate(.tappedAddButton))
                
            case .viewEvent(.tappedSpot):
                return .send(.delegate(.tappedSpot))
                
            default:
                break
            }
            
            return .none
        }
    }
}
