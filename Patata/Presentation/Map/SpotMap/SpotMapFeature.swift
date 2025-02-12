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
    private let dataSourceActor = DataSourceActor()
    
    @ObservableState
    struct State: Equatable {
        var mapState: MapStateEntity = MapStateEntity(coord: Coordinate(latitude: 37.5666791, longitude: 126.9784147), markers: [(Coordinate(latitude: 37.5666791, longitude: 126.9784147), SpotMarkerImage.housePin)])
        var userLocation: Coordinate = Coordinate(latitude: 37.5666791, longitude: 126.9784147)
        var cameraLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var selectedMenuIndex: Int = 0
        var spotReloadButton: Bool = false
        
        // bindingState
        var isPresented: Bool = false
        var archive: Bool = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case locationAction(LocationAction)
        case delegate(Delegate)
        case dataTransType(DataTransType)
        
        // bindingAction
        case bindingIsPresented(Bool)
        case bindingArchive(Bool)
        
        enum Delegate {
            case tappedSideButton
            case tappedMarker
            case bottomSheetDismiss
            case tappedSpotAddButton(Coordinate)
            case tappedSearch
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedMenu(Int)
        case tappedMarker
        case tappedSpotAddButton
        case tappedSideButton
        case tappedSearch
        case tappedMoveToUserLocationButton
        case bottomSheetDismiss
        case changeMapLocation
        case onCameraIdle(Coordinate)
    }
    
    enum LocationAction {
        case checkLocationPermission
        case locationPermissionResponse(Bool)
        case updateLocation(Coordinate)
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
    }
    
    @Dependency(\.locationManager) var locationManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                state.spotReloadButton = false
                
                return .run { send in
                    await send(.dataTransType(.fetchRealm))
                    
                    for await location in locationManager.getLocationUpdates() {
                        await send(.dataTransType(.userLocation(location)))
                    }
                }
                
            case let .viewEvent(.tappedMenu(index)):
                state.selectedMenuIndex = index
                
            case .viewEvent(.tappedMarker):
                state.isPresented = true
                return .send(.delegate(.tappedMarker))
                
            case .viewEvent(.tappedSpotAddButton):
                state.isPresented = false
                return .send(.delegate(.tappedSpotAddButton(state.cameraLocation)))
                
            case .viewEvent(.tappedSideButton):
                return .send(.delegate(.tappedSideButton))
                
            case .viewEvent(.bottomSheetDismiss):
                return .send(.delegate(.bottomSheetDismiss))
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.changeMapLocation):
                state.spotReloadButton = true
                
            case .viewEvent(.tappedMoveToUserLocationButton):
                state.mapState.first = false
                state.mapState.coord = state.userLocation
                
            case let .viewEvent(.onCameraIdle(coord)):
                state.cameraLocation = coord
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                state.mapState.coord = coord
                
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
