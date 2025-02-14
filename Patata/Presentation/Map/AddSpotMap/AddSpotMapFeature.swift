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
    
    @ObservableState
    struct State: Equatable {
        var mapState: MapStateEntity
        var address: String = ""
        var spotCoord: Coordinate = Coordinate(latitude: 0, longitude: 0)
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedBackButton
            case tappedAddConfirmButton(Coordinate, String)
        }
    }
    
    enum ViewEvent {
        case tappedBackButton
        case locationToAddress(lat: Double, long: Double)
        case tappedAddConfirmButton
    }
    
    enum DataTransType {
        case locationText(String, lat: Double, long: Double)
    }
    
    let addressManager = AddressManager()
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension AddSpotMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewEvent(.tappedBackButton):
                return .merge(
                    .cancel(id: "location-lookup"),
                    .send(.delegate(.tappedBackButton))
                )
                
            case let .viewEvent(.locationToAddress(lat, long)):
                return .run { send in
                    do {
                        let result = try await addressManager.getAddress(
                            for: CLLocationCoordinate2D(latitude: lat, longitude: long)
                        )
                        await send(.dataTransType(.locationText(result, lat: lat, long: long)))
                    } catch {
                        print(error)
                    }
                }
                .cancellable(id: "location-lookup")
                
            case .viewEvent(.tappedAddConfirmButton):
                return .send(.delegate(.tappedAddConfirmButton(state.spotCoord, state.address)))
                
            case let .dataTransType(.locationText(location, lat, long)):
                state.address = location
                state.spotCoord = Coordinate(latitude: lat, longitude: long)
                
            default:
                break
            }
            return .none
        }
    }
}
