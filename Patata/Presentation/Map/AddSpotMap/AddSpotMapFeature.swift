//
//  AddSpotMapFeature.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import Foundation
import ComposableArchitecture
import CoreLocation

@Reducer
struct AddSpotMapFeature {
    
    @ObservableState
    struct State: Equatable {
        var mapState: MapStateEntity = MapStateEntity(coord: (126.9784147, 37.5666885), markers: [])
        var address: String = ""
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedBackButton
        }
    }
    
    enum ViewEvent {
        case tappedBackButton
        case locationToAddress(lat: Double, long: Double)
    }
    
    enum DataTransType {
        case locationText(String)
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
                return .send(.delegate(.tappedBackButton))
                
            case let .viewEvent(.locationToAddress(lat, long)):
                return .run { send in
                    do {
                        let result = try await addressManager.getAddress(for: CLLocationCoordinate2D(latitude: lat, longitude: long))
                        
                        await send(.dataTransType(.locationText(result)))
                    } catch {
                        print(error)
                    }
                }
                
            case let .dataTransType(.locationText(location)):
                state.address = location
                
            default:
                break
            }
            return .none
        }
    }
}
