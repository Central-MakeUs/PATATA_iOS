//
//  SpotMapFeature.swift
//  Patata
//
//  Created by 김진수 on 2/2/25.
//

import Foundation
import ComposableArchitecture

struct Coordinate: Equatable {
    var latitude: Double
    var longitude: Double
}

@Reducer
struct SpotMapFeature {
    @ObservableState
    struct State: Equatable {
        var coord: Coordinate = Coordinate(latitude: 126.9784147, longitude: 37.5666885)
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
        var archive: Bool = false
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSideButton
        }
        // bindingAction
        case bindingIsPresented(Bool)
        case bindingArchive(Bool)
    }
    
    enum ViewEvent {
        case tappedMenu(Int)
        case tappedMarker
        case tappedSpotAddButton
        case tappedSideButton
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
                
            case .viewEvent(.tappedSideButton):
                return .send(.delegate(.tappedSideButton))
                
            case let .bindingIsPresented(isPresented):
                state.isPresented = isPresented
                
            case let .bindingArchive(isArchive):
                state.archive = isArchive
                
            default:
                break
            }
            return .none
        }
    }
}
