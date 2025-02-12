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
    }
    
    enum Action {
        case viewEvent(ViewEvent)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedBackButton
            case tappedAddConfirmButton
        }
    }
    
    enum ViewEvent {
        case tappedBackButton
        case locationToAddress(lat: Double, long: Double)
        case tappedAddConfirmButton
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
                        await send(.dataTransType(.locationText(result)))
                    } catch {
                        print(error)
                    }
                }
                .cancellable(id: "location-lookup")
                
            case .viewEvent(.tappedAddConfirmButton):
                return .send(.delegate(.tappedAddConfirmButton))
                
            case let .dataTransType(.locationText(location)):
                state.address = location
                
            default:
                break
            }
            return .none
        }
    }
}
