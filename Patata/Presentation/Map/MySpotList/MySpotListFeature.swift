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
        var spotListEntity: [TodaySpotListEntity] = []
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
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case delegate(Delegate)
        
        // bindingAction
        case bindingArchive(Bool)
        
        enum Delegate {
            case tappedBackButton
            case tappedSpot(Int)
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum NetworkType {
        case fetchSpotList(Coordinate)
        case patchArchiveState(Int)
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
        case todaySpotList([TodaySpotListEntity])
        case archiveState(ArchiveEntity, Int)
    }
    
    enum ViewEvent {
        case selectedMenu(Int)
        case tappedBackButton
        case tappedArchiveButton(Int)
        case tappedSpot(Int)
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.archiveRepostiory) var archiveRepository
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension MySpotListFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce {
            state,
            action in
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
                
            case let .viewEvent(.tappedArchiveButton(index)):
                return .run { send in
                    await send(.networkType(.patchArchiveState(index)))
                }
                
            case let .viewEvent(.tappedSpot(spotId)):
                return .send(.delegate(.tappedSpot(spotId)))
                
            case let .networkType(.fetchSpotList(userCoord)):
                return .run { send in
                    do {
                        let data = try await spotRepository.fetchTodaySpotList(userLocation: userCoord)
                        
                        await send(.dataTransType(.todaySpotList(data)))
                    } catch {
                        print("error", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .networkType(.patchArchiveState(index)):
                let spotId = [state.spotListEntity[index].spotId]
                
                return .run { send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: spotId)
                        
                        await send(.dataTransType(.archiveState(data, index)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userCoord = coord
                
                if state.viewState == .home {
                    return .run { send in
                        await send(.networkType(.fetchSpotList(coord)))
                    }
                }
                
            case let .dataTransType(.todaySpotList(spotList)):
                state.spotListEntity = spotList
                
            case let .dataTransType(.archiveState(data, index)):
                state.spotListEntity[index] = TodaySpotListEntity(
                    spotId: state.spotListEntity[index].spotId,
                    spotAddress: state.spotListEntity[index].spotAddress,
                    spotAddressDetail: state.spotListEntity[index].spotAddressDetail,
                    spotName: state.spotListEntity[index].spotName,
                    categoryId: state.spotListEntity[index].categoryId,
                    images: state.spotListEntity[index].images,
                    isScraped: data.isArchive,
                    distance: state.spotListEntity[index].distance,
                    tags: state.spotListEntity[index].tags
                )
                
            case let .bindingArchive(archive):
                state.archive = archive
                
            default:
                break
            }
            return .none
        }
    }
}
