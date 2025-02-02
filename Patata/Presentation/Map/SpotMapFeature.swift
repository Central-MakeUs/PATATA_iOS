//
//  SpotMapFeature.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SpotMapFeature {
    @ObservableState
    struct State {
        var coord: (Double, Double) = (126.9784147, 37.5666805)
        var selectedMenuIndex: Int = 0
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
        
        // bindingState
        var isPresented: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        
        
        // bindingAction
        case bindingIsPresented(Bool)
    }
    
    enum ViewEvent {
        case tappedMenu(Int)
        case tappedMarker
        case tappedSpotAddButton
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .viewEvent(.tappedMenu(index)):
                state.selectedMenuIndex = index
                
            case .viewEvent(.tappedMarker):
                state.isPresented = true
                
            case .viewEvent(.tappedSpotAddButton):
                state.isPresented = false
                
            case let .bindingIsPresented(isPresented):
                state.isPresented = isPresented
                
            default:
                break
            }
            return .none
        }
    }
}
