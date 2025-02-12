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
    private let dataSourceActor = DataSourceActor()
    
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
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        // bindingAction
        case bindingArchive(Bool)
        
        enum Delegate {
            case tappedBackButton
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
    }
    
    enum ViewEvent {
        case selectedMenu(Int)
        case tappedBackButton
    }
    
    @Dependency(\.locationManager) var locationManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MySpotListFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.dataTransType(.fetchRealm))
                    
                    for await location in locationManager.getLocationUpdates() {
                        await send(.dataTransType(.userLocation(location)))
                    }
                }
                
            case let .viewEvent(.selectedMenu(index)):
                state.selectedIndex = index
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
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
