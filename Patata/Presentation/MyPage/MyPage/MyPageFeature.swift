//
//  MyPageFeature.swift
//  Patata
//
//  Created by 김진수 on 2/3/25.
//

import Foundation
import ComposableArchitecture

@Reducer
struct MyPageFeature {
    private let dataSourceActor = DataSourceActor()
    
    @ObservableState
    struct State: Equatable {
        var imageCount: Int = 0
        var spotCount: Int = 0
        var mySpots: [ArchiveListEntity] = []
        var userLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var user: MyPageEntity = MyPageEntity()
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        enum Delegate {
            case tappedSpot(Int)
            case tappedProfileEdit(MyPageEntity)
            case tappedSetting
            case tappedAddSpotButton(Coordinate)
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedSpot(Int)
        case tappedProfileEdit
        case tappedSetting
        case tappedAddSpotButton
    }
    
    enum NetworkType {
        case fetchMySpot
        case fetchUser
    }
    
    enum DataTransType {
        case fetchRealm
        case fetchMySpot(MySpotsEntity)
        case userLocation(Coordinate)
        case fetchUser(MyPageEntity)
    }
    
    @Dependency(\.myPageRepository) var myPageRepository
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MyPageFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                return .run { send in
                    await send(.dataTransType(.fetchRealm))
                    await send(.networkType(.fetchMySpot))
                    await send(.networkType(.fetchUser))
                    
                    for await location in locationManager.getLocationUpdates() {
                        await send(.dataTransType(.userLocation(location)))
                    }
                }
                
            case let .viewEvent(.tappedSpot(spotId)):
                return .send(.delegate(.tappedSpot(spotId)))
                
            case .viewEvent(.tappedProfileEdit):
                return .send(.delegate(.tappedProfileEdit(state.user)))
                
            case .viewEvent(.tappedSetting):
                return .send(.delegate(.tappedSetting))
                
            case .viewEvent(.tappedAddSpotButton):
                return .send(.delegate(.tappedAddSpotButton(state.userLocation)))
                
            case .networkType(.fetchMySpot):
                return .run { send in
                    do {
                        let data = try await myPageRepository.fetchMySpots()
                        
                        await send(.dataTransType(.fetchMySpot(data)))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.fetchUser):
                return .run { send in
                    do {
                        let data = try await myPageRepository.fetchUser()
                        
                        await send(.dataTransType(.fetchUser(data)))
                    } catch {
                        print("fail", errorManager.handleError(error) ?? "")
                    }
                }
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                
            case let .dataTransType(.fetchMySpot(data)):
                state.spotCount = data.spotCount
                state.mySpots = data.mySpots
                
            case let .dataTransType(.fetchUser(data)):
                state.user = data
                
            default:
                break
            }
            return .none
        }
    }
}
