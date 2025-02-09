//
//  SearchMapFeature.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct SearchMapFeature {
    @ObservableState
    struct State: Equatable {
        var coord: Coordinate = Coordinate(latitude: 126.9784147, longitude: 37.5666885)
        var selectedMenuIndex: Int = 0
        var spotReloadButton: Bool = false
        
        // bindingState
        var isPresented: Bool = false
        var archive: Bool = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSideButton
            case tappedMarker
            case bottomSheetDismiss
            case tappedSpotAddButton
            case tappedBackButton
            case tappedSearch
        }
        // bindingAction
        case bindingIsPresented(Bool)
        case bindingArchive(Bool)
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedMenu(Int)
        case tappedMarker
        case tappedSpotAddButton
        case tappedSideButton
        case tappedBackButton
        case tappedSearch
        case bottomSheetDismiss
        case changeMapLocation
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SearchMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                state.spotReloadButton = false
                return .send(.viewEvent(.tappedMarker))
                
            case let .viewEvent(.tappedMenu(index)):
                state.selectedMenuIndex = index
                
            case .viewEvent(.tappedMarker):
                state.isPresented = true
                return .send(.delegate(.tappedMarker))
                
            case .viewEvent(.tappedSpotAddButton):
                state.isPresented = false
                return .send(.delegate(.tappedSpotAddButton))
                
            case .viewEvent(.tappedSideButton):
                return .send(.delegate(.tappedSideButton))
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.bottomSheetDismiss):
                return .send(.delegate(.bottomSheetDismiss))
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.changeMapLocation):
                state.spotReloadButton = true
                
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
