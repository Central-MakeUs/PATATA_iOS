//
//  MySpotListFeature.swift
//  Patata
//
//  Created by 김진수 on 2/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MySpotListFeature {
    @ObservableState
    struct State: Equatable {
        let viewState: ViewState
        let titles = ["전체", "작가추천", "스냅스팟", "시크한 아경", "일상 속 공감", "싱그러운"]
        var userCoord: Coordinate =  Coordinate(latitude: 37.5666791, longitude: 126.9784147)
        var selectedIndex: Int = 0
        var imageCount: Int = 4
        var archive: Bool = false
    }
    
    enum ViewState {
        case home
        case map
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case delegate(Delegate)
        case parentAction(ParentAction)
        
        // bindingAction
        case bindingArchive(Bool)
        
        enum Delegate {
            case tappedBackButton
        }
        
        enum ParentAction {
            case userLocation(Coordinate)
        }
    }
    
    enum ViewEvent {
        case selectedMenu(Int)
        case tappedBackButton
    }
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MySpotListFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .viewEvent(.selectedMenu(index)):
                state.selectedIndex = index
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case let .parentAction(.userLocation(coord)):
                state.userCoord = coord
                
            case let .bindingArchive(archive):
                state.archive = archive
                
            default:
                break
            }
            return .none
        }
    }
}
