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
        var mapState: MapStateEntity = MapStateEntity(coord: (126.9784147, 37.5666885), markers: [((126.9784147, 37.5666885), SpotMarkerImage.housePin)])
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
        
        enum Delegate {
            case tappedSideButton
            case tappedMarker
            case bottomSheetDismiss
            case tappedSpotAddButton
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
        case tappedSearch
        case bottomSheetDismiss
        case changeMapLocation
    }
    
    enum LocationAction {
        case checkLocationPermission
        case locationPermissionResponse(Bool)
        case updateLocation(Coordinate)
    }
    
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
                
            case .viewEvent(.bottomSheetDismiss):
                return .send(.delegate(.bottomSheetDismiss))
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.changeMapLocation):
                state.spotReloadButton = true
                
//            case .locationAction(.checkLocationPermission):
//                return .run { send in
//                    let hasPermission = await locationClient.checkPermission()
//                    await send(.locationManager(.locationPermissionResponse(hasPermission)))
//                }
//                
//            case let .locationAction(.locationPermissionResponse(hasPermission)):
//                state.isLocationPermissionGranted = hasPermission
//                guard hasPermission else { return .none }
//                return .run { send in
//                    for await location in await locationClient.locations() {
//                        await send(.locationManager(.updateLocation(location)))
//                    }
//                }
                
//            case let .locationAction(.updateLocation(coordinate)):
//                state.currentLocation = coordinate
//                state.mapState.coord = (coordinate.longitude, coordinate.latitude)
//                return .none
                
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
