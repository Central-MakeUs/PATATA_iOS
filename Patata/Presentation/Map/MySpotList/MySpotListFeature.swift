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
        var mapSpotEntity: [MapSpotEntity] = []
        var initialSpotEntity: [MapSpotEntity] = []
        let titles = ["전체", "작가추천", "스냅스팟", "시크한 아경", "일상 속 공감", "싱그러운 자연"]
        var userCoord: Coordinate =  Coordinate(latitude: 37.5666791, longitude: 126.9784147)
        var mbrLocation: MBRCoordinates
        var selectedIndex: Int = 0
        var imageCount: Int = 4
        var archive: Bool = false
        var isSearch: Bool
        var searchText: String
        var currentPage: Int = 0
        var totalpages: Int = 0
        var listLoadTrigger: Bool = true
        var totalCount: Int = 0
        var isFirst: Bool = true
    }
    
    enum ViewState {
        case home
        case map
        case mapSearch
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
            case tappedBackButton(ViewState)
            case tappedSpot(Int)
            case tappedSearch(ViewState)
            case delete
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum NetworkType {
        case fetchSpotList(Coordinate)
        case patchArchiveState(Int)
        case fetchSpot(MBRCoordinates, Coordinate, CategoryCase, isSearch: Bool, page: Int, isScroll: Bool)
        case fetchSearchSpot(MBRCoordinates?, Coordinate, String)
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
        case todaySpotList([TodaySpotListEntity])
        case archiveState(ArchiveEntity, Int)
        case fetchSpot(MyListMapSpotEntity, isScroll: Bool)
        case fetchSearchSpot(MapSpotEntity?)
    }
    
    enum ViewEvent {
        case selectedMenu(Int)
        case tappedBackButton
        case tappedArchiveButton(Int)
        case tappedSpot(Int)
        case tappedSearch
        case nextPage
        case refresh
    }
    
    @Dependency(\.spotRepository) var spotRepository
    @Dependency(\.mapRepository) var mapRepository
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
                state.selectedIndex = 0
                state.listLoadTrigger = false
                
                return .run { send in
                    await send(.dataTransType(.fetchRealm))
                    
                    for await location in locationManager.getLocationUpdates() {
                        await send(.dataTransType(.userLocation(location)))
                    }
                }
                
            case let .viewEvent(.selectedMenu(index)):
                state.selectedIndex = index

                if state.mapSpotEntity.count > 1 {
                    state.mapSpotEntity.removeSubrange(1...)
                }
                
                state.listLoadTrigger = false
                state.totalpages = 0
                state.totalCount = 0
                
                let mbr = state.mbrLocation
                let user = state.userCoord
                let category = CategoryCase(rawValue: index) ?? .all
                
                return .run { send in
                    await send(.networkType(.fetchSpot(mbr, user, category, isSearch: true, page: 0, isScroll: false)))
                }
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton(state.viewState)))
                
            case let .viewEvent(.tappedArchiveButton(index)):
                return .run { send in
                    await send(.networkType(.patchArchiveState(index)))
                }
                
            case let .viewEvent(.tappedSpot(spotId)):
                return .send(.delegate(.tappedSpot(spotId)))
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch(state.viewState)))
                
            case .viewEvent(.nextPage):
                state.listLoadTrigger = false
                
                let mbr = state.mbrLocation
                let user = state.userCoord
                let category = CategoryCase(rawValue: state.selectedIndex) ?? .all
                let currentPage = state.currentPage + 1
                
                return .run { send in
                    await send(.networkType(.fetchSpot(mbr, user, category, isSearch: true, page: currentPage, isScroll: true)))
                }
                
            case .viewEvent(.refresh):
                let user = state.userCoord
                let category = CategoryCase(rawValue: state.selectedIndex) ?? .all
                
                if state.viewState == .home {
                    return .run { send in
                        await send(.networkType(.fetchSpotList(user)))
                    }
                } else if state.viewState == .map {
                    let mbrCoord = state.mbrLocation
                    let userLocation = state.userCoord
                    
                    return .run { send in
                        await send(.networkType(.fetchSpot(mbrCoord, userLocation, category, isSearch: false, page: 0, isScroll: false)))
                    }
                    
                } else {
                    let mbrCoord = state.isSearch ? nil : state.mbrLocation
                    let userLocation = state.userCoord
                    let searchText = state.searchText
                    
                    return .run { send in
                        await send(.networkType(.fetchSearchSpot(mbrCoord, userLocation, searchText)))
                    }
                }
                
            case .delegate(.delete):
                let user = state.userCoord
                let category = CategoryCase(rawValue: state.selectedIndex) ?? .all
                
                if state.viewState == .home {
                    return .run { send in
                        await send(.networkType(.fetchSpotList(user)))
                    }
                } else if state.viewState == .map {
                    let mbrCoord = state.mbrLocation
                    let userLocation = state.userCoord
                    
                    return .run { send in
                        await send(.networkType(.fetchSpot(mbrCoord, userLocation, category, isSearch: false, page: 0, isScroll: false)))
                    }
                    
                } else {
                    let mbrCoord = state.isSearch ? nil : state.mbrLocation
                    let userLocation = state.userCoord
                    let searchText = state.searchText
                    
                    return .run { send in
                        await send(.networkType(.fetchSearchSpot(mbrCoord, userLocation, searchText)))
                    }
                }
                
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
                
            case let .networkType(.fetchSpot(mbrLocation, userLocation, category, isSearch, page, isScroll)):
                return .run { send in
                    do {
                        let data = try await mapRepository.fetchMySpotList(mbrLocation: mbrLocation, userLocation: userLocation, categoryId: category.rawValue, isSearch: isSearch, page: page)
                        
                        await send(.dataTransType(.fetchSpot(data, isScroll: isScroll)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .networkType(.fetchSearchSpot(mbrLocation, userLocation, searchText)):
                return .run { send in
                    do {
                        let data = try await mapRepository.fetchSearchSpot(userLocation: userLocation, mbrLocation: mbrLocation, spotName: searchText)
                        
                        await send(.dataTransType(.fetchSearchSpot(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.fetchSpot(data, isScroll)):
                print("data", data)
                if state.viewState == .map {
                    if isScroll {
                        state.listLoadTrigger = true
                        state.initialSpotEntity.append(contentsOf: data.spots)
                        state.mapSpotEntity.append(contentsOf: data.spots)
                        state.currentPage = data.currentPage
                        state.totalpages = data.totalPages
                        state.totalCount = data.totalCount
                    } else {
                        state.listLoadTrigger = true
                        state.initialSpotEntity = data.spots
                        state.mapSpotEntity = data.spots
                        state.currentPage = data.currentPage
                        state.totalpages = data.totalPages
                        state.totalCount = data.totalCount
                    }
                } else {
                    print("fetch", data.spots)
                    state.listLoadTrigger = true
                    state.initialSpotEntity.append(contentsOf: data.spots)
                    state.mapSpotEntity.append(contentsOf: data.spots)
                    state.currentPage = data.currentPage
                    state.totalpages = data.totalPages
                    state.totalCount = data.totalCount
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userCoord = coord
                
                if state.viewState == .home {
                    return .run { send in
                        await send(.networkType(.fetchSpotList(coord)))
                    }
                } else if state.viewState == .map {
                    if state.isFirst {
                        state.isFirst = false
                        
                        let mbrCoord = state.mbrLocation
                        let userLocation = state.userCoord
                        
                        return .run { send in
                            await send(.networkType(.fetchSpot(mbrCoord, userLocation, .all, isSearch: false, page: 0, isScroll: false)))
                        }
                    }
                } else {
                    if state.isFirst {
                        state.isFirst = false
                        
                        let mbrCoord = state.isSearch ? nil : state.mbrLocation
                        let userLocation = state.userCoord
                        let searchText = state.searchText
                        
                        return .run { send in
                            await send(.networkType(.fetchSearchSpot(mbrCoord, userLocation, searchText)))
                        }
                    }
                }
                
            case let .dataTransType(.todaySpotList(spotList)):
                state.spotListEntity = spotList
                
            case let .dataTransType(.fetchSearchSpot(data)):
                if let data {
                    state.mapSpotEntity = [data]
                    
                    let mbrLocation = state.mbrLocation
                    let userLocation = state.userCoord
                    
                    return .run { send in
                        await send(.networkType(.fetchSpot(mbrLocation, userLocation, .all, isSearch: true, page: 0, isScroll: false)))
                    }
                }
                
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
