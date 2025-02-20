//
//  AddSpotMapFeature.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import Foundation
import ComposableArchitecture
import CoreLocation

// 유저가 보고 있는 화면부터 시작
@Reducer
struct AddSpotMapFeature {
    private let dataSourceActor = DataSourceActor()
    
    @ObservableState
    struct State: Equatable {
        var viewState: ViewState
        var mapManager: NaverMapManager = NaverMapManager.addSpotShared
        var userLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var address: String = ""
        var spotCoord: Coordinate
        var addSpotEntity: [MapSpotEntity] = []
        var addValid: Bool = false
        var isPresent: Bool = false
    }
    
    enum ViewState {
        case map
        case searchMap
        case edit
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case mapAction(MapAction)
        case delegate(Delegate)
        
        case bindingIsPresent(Bool)
        
        enum Delegate {
            case tappedBackButton(ViewState)
            case tappedAddConfirmButton(Coordinate, String, ViewState)
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedBackButton
        case tappedAddConfirmButton
        case dismissPopup
    }
    
    enum NetworkType {
        case checkValidAddSpot(Coordinate)
    }
    
    enum DataTransType {
        case locationText(String, lat: Double, long: Double)
        case checkValidSpot([MapSpotEntity])
        case fetchRealm
        case userLocation(Coordinate)
    }
    
    enum MapAction {
        case getCameraLocation(Coordinate)
        case moveCamera
    }
    
    let addressManager = AddressManager()
    
    @Dependency(\.mapRepository) var mapRepository
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension AddSpotMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                
                if state.spotCoord.latitude != 0 && state.spotCoord.longitude != 0 {
                    state.mapManager.moveCamera(coord: state.spotCoord)
                }
                
                return .merge(
                    
                    .run(operation: { send in
                        await send(.dataTransType(.fetchRealm))
                    }),
                    .merge(registerPublisher(state: &state))
                )
                
            case .viewEvent(.tappedBackButton):
                return .merge(
                    .cancel(id: "location-lookup"),
                    .send(.delegate(.tappedBackButton(state.viewState)))
                )
                
            case .viewEvent(.tappedAddConfirmButton):
                let coord = state.spotCoord
                
                if !state.address.isEmpty {
                    return .run { send in
                        await send(.networkType(.checkValidAddSpot(coord)))
                    }
                }
                
            case .viewEvent(.dismissPopup):
                state.isPresent = false
                state.addSpotEntity = []
                
            case let .networkType(.checkValidAddSpot(coord)):
                return .run { send in
                    do {
                        let data = try await mapRepository.checkValidSpot(coord: coord)
                        
                        await send(.dataTransType(.checkValidSpot(data)))
                    } catch {
                        print("error", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .mapAction(.getCameraLocation(coord)):
                print("getCamera", coord)
                state.spotCoord = coord
                
                return .run { send in
                    do {
                        let result = try await addressManager.getAddress(
                            for: CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
                        )
                        
                        await send(.dataTransType(.locationText(result, lat: coord.latitude, long: coord.longitude)))
                    } catch {
                        print(error)
                    }
                }
                .cancellable(id: "location-lookup")
                
            case .mapAction(.moveCamera):
                state.mapManager.clearCurrentMarkers()
                state.addValid = true
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                if state.spotCoord.latitude == 0 && state.spotCoord.longitude == 0 {
                    state.spotCoord = coord
                    state.mapManager.moveCamera(coord: coord)
                }
                
                
            case let .dataTransType(.locationText(location, lat, long)):
                state.address = location
                state.spotCoord = Coordinate(latitude: lat, longitude: long)
                
            case let .dataTransType(.checkValidSpot(data)):
                state.addSpotEntity = data
                state.addValid = data.count >= 25 ? false : true
                
                let coord = state.spotCoord
                let address = state.address
                
                if state.addValid {
                    state.isPresent = false
                    
                    return .send(.delegate(.tappedAddConfirmButton(coord, address, state.viewState)))
                } else {
                    state.mapManager.updateMarkers(markers: state.addSpotEntity)
                    state.isPresent = true
                }
                
            case let .bindingIsPresent(isPresent):
                state.isPresent = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}

extension AddSpotMapFeature {
    private func registerPublisher(state: inout State) -> [Effect<AddSpotMapFeature.Action>] {
        var effects : [Effect<AddSpotMapFeature.Action>] = .init()
        
        effects.append(Effect<AddSpotMapFeature.Action>
            .publisher {
                state.mapManager.cameraIdlePass
                    .map { cameraLocation in
                        return Action.mapAction(.getCameraLocation(cameraLocation))
                    }
            }
        )
        
        effects.append(Effect<AddSpotMapFeature.Action>
            .publisher {
                state.mapManager.moveCameraPass
                    .map { _ in
                        Action.mapAction(.moveCamera)
                    }
            }
        )
        
        return effects
    }
}
