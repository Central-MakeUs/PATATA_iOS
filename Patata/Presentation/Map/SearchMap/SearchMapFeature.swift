//
//  SearchMapFeature.swift
//  Patata
//
//  Created by 김진수 on 2/9/25.
//

import Foundation
import ComposableArchitecture

// 서치해서 받은 좌표를 mapState에서 넣어줘야된다
@Reducer
struct SearchMapFeature {
    private let dataSourceActor = DataSourceActor()
    
    @ObservableState
    struct State: Equatable {
        var searchText: String
        var mapManager: NaverMapManager = NaverMapManager.searchMapShared
        var userLocation: Coordinate = Coordinate(latitude: 37.5666791, longitude: 126.9784147)
        var cameraLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var mbrLocation: MBRCoordinates = MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0))
        var searchSpotItems: [MapSpotEntity] = []
        var selectedIndex: Int = 0
        var selectedMenuIndex: Int = 0
        var isFirst: Bool = false
        var isOtherFirst: Bool = false
        var reloadButtonIsHide: Bool = true
        var isTappedReload: Bool = false
        var errorMSG: String = ""
        
        // bindingState
        var isPresented: Bool = false
        var errorIsPresented: Bool = false
        var archive: Bool = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case networkType(NetworkType)
        case dataTransType(DataTransType)
        case mapAction(MapAction)
        case delegate(Delegate)
        
        // bindingAction
        case bindingIsPresented(Bool)
        case bindingArchive(Bool)
        case bindingErrorIsPresent(Bool)
        
        enum Delegate {
            case tappedSideButton(MBRCoordinates, searchText: String, isSearch: Bool)
            case tappedMarker
            case bottomSheetDismiss
            case tappedSpotAddButton(Coordinate)
            case tappedBackButton
            case tappedSearch
            case mySpotListSearch(String)
            case tappedSpotDetail(Int)
            case deleteSpot
            case successEdit
            case detailBack
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedMenu(Int)
        case tappedSpotAddButton
        case tappedSideButton
        case tappedBackButton
        case tappedSearch
        case bottomSheetDismiss
        case tappedMoveToUserLocationButton
        case tappedArchiveButton
        case tappedReloadButton
        case dismissPopup
        case tappedSpotDetail(Int)
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
        case searchSpotDatas(MapSpotEntity?, Bool)
        case otherSpotDatas([MapSpotEntity])
        case archiveState(ArchiveEntity)
    }
    
    enum NetworkType {
        case searchSpot(spotName: String, userLocation: Coordinate, mbrLocation: MBRCoordinates? = nil, reload: Bool = false)
        case otherSpot(mbrLocation: MBRCoordinates, userLocation: Coordinate, category: CategoryCase)
        case patchArchiveState
    }
    
    enum MapAction {
        case getMBRLocation(MBRCoordinates)
        case getMarkerIndex(Int)
        case getCameraLocation(Coordinate)
        case moveCamera
    }
    
    @Dependency(\.mapRepository) var mapRepository
    @Dependency(\.archiveRepostiory) var archiveRepository
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SearchMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .viewCycle(.onAppear):
                state.isFirst = true
                state.isOtherFirst = true
                state.reloadButtonIsHide = true
                
                state.mapManager.clearCurrentMarkers()
                
                print("onAppear")
                
                return .merge(
                    .merge(registerPublisher(state: &state)),
                    .run { send in
                        await send(.dataTransType(.fetchRealm))
                        
                        for await location in locationManager.getLocationUpdates() {
                            await send(.dataTransType(.userLocation(location)))
                        }
                    }
                )
                
            case let .viewEvent(.tappedMenu(index)):
                state.selectedMenuIndex = index
                state.isTappedReload = true
                
                if !state.searchSpotItems.isEmpty {
                    let spotName = state.searchSpotItems[state.selectedIndex].spotName
                    let userLocation = state.userLocation
                    let mbrLocation = state.mbrLocation
                    
                    state.mapManager.clearCurrentMarkers()
                    
                    return .run { send in
                        await send(.networkType(.searchSpot(spotName: spotName, userLocation: userLocation, mbrLocation: mbrLocation, reload: true)))
                    }
                }
                
            case .viewEvent(.tappedSpotAddButton):
                state.isPresented = false
                return .send(.delegate(.tappedSpotAddButton(state.cameraLocation)))
                
            case .viewEvent(.tappedSideButton):
                let mbrLocation = state.mbrLocation
                let searchText = state.searchText
                let isSearch = state.isTappedReload
                
                return .send(.delegate(.tappedSideButton(mbrLocation, searchText: searchText, isSearch: isSearch)))
                
            case .viewEvent(.tappedBackButton):
                return .send(.delegate(.tappedBackButton))
                
            case .viewEvent(.bottomSheetDismiss):
                return .send(.delegate(.bottomSheetDismiss))
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.tappedMoveToUserLocationButton):
                state.mapManager.moveCamera(coord: state.userLocation)
                
            case .viewEvent(.tappedArchiveButton):
                return .run { send in
                    await send(.networkType(.patchArchiveState))
                }
                
            case .viewEvent(.tappedReloadButton):
                state.isPresented = false
                state.selectedMenuIndex = 0
                state.isTappedReload = true
                
                let userLocation = state.userLocation
                let mbr = state.mbrLocation
                let spotName = state.searchText
                
                state.mapManager.clearCurrentMarkers()
                
                return .run { send in
                    await send(.networkType(.searchSpot(spotName: spotName, userLocation: userLocation, mbrLocation: mbr, reload: true)))
                }
                
            case .viewEvent(.dismissPopup):
                state.errorIsPresented = false
                
            case let .viewEvent(.tappedSpotDetail(spotId)):
                return .send(.delegate(.tappedSpotDetail(spotId)))
                
            case let .mapAction(.getMBRLocation(mbrLocation)):
                state.mbrLocation = mbrLocation
                
            case let .mapAction(.getCameraLocation(cameraLocation)):
                state.cameraLocation = cameraLocation
                
            case let .mapAction(.getMarkerIndex(index)):
                state.selectedIndex = index
                state.searchText = state.searchSpotItems[state.selectedIndex].spotName
                state.isPresented = true
                return .send(.delegate(.tappedMarker))
                
            case .mapAction(.moveCamera):
                state.reloadButtonIsHide = false
                
                if state.isPresented {
                    state.isPresented = false
                }
                
            case .delegate(.deleteSpot):
                state.isPresented = false
                
                state.mapManager.clearCurrentMarkers()
                
                let spotName = state.searchText
                let coord = state.userLocation
                
                return .run { send in
                    await send(.networkType(.searchSpot(spotName: spotName, userLocation: coord)))
                }
                
            case .delegate(.successEdit):
                state.isPresented = false
                
            case let .delegate(.mySpotListSearch(searchText)):
                state.searchSpotItems = []
                state.searchText = searchText
                state.mapManager.clearCurrentMarkers()
                
                let userLocation = state.userLocation
                
                return .run { send in
                    await send(.networkType(.searchSpot(spotName: searchText, userLocation: userLocation)))
                }
                
            case .delegate(.detailBack):
                state.isFirst = false
                state.isOtherFirst = false
                
            case let .networkType(.searchSpot(spotName, userLocation, mbrLocation, reload)):
                return .run { send in
                    do {
                        let data = try await mapRepository.fetchSearchSpot(userLocation: userLocation, mbrLocation: mbrLocation, spotName: spotName)
                        
                        await send(.dataTransType(.searchSpotDatas(data, reload)))
                        
                    } catch {
                        print("error", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .networkType(.otherSpot(mbrLocation, userLocation, category)):
                return .run { send in
                    do {
                        let data = try await mapRepository.fetchMap(mbrLocation: mbrLocation, userLocation: userLocation, categoryId: category.rawValue, isSearch: true)
                        
                        await send(.dataTransType(.otherSpotDatas(data)))
                    } catch {
                        if let paError = error as? PAError {
                            switch paError {
                            case .errorMessage(.search(.noData)):
                                await send(.dataTransType(.searchSpotDatas(nil, false)))
                            default:
                                print("error", errorManager.handleError(error) ?? "")
                            }
                        } else {
                            print("error", errorManager.handleError(error) ?? "")
                        }
                    }
                }
                
            case .networkType(.patchArchiveState):
                let spot = state.searchSpotItems[state.selectedIndex]
                
                return .run { send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: [spot.spotId])
                        
                        await send(.dataTransType(.archiveState(data)))
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
                state.userLocation = coord
                
                let spotName = state.searchText
                
                if !state.searchText.isEmpty {
                    return .run { send in
                        await send(.networkType(.searchSpot(spotName: spotName, userLocation: coord)))
                    }
                } else {
                    state.mapManager.moveCamera(coord: coord)
                    state.errorIsPresented = true
                }
                
            case let .dataTransType(.searchSpotDatas(data, reload)):
                if let data {
                    state.errorIsPresented = false
                    state.searchSpotItems = [data]
                    
                    let mbrLocation = state.mbrLocation
                    let userLocation = state.userLocation
                    let menuItem = state.selectedMenuIndex
                    
                    if state.isFirst {
                        state.isFirst = false
                        
                        // 검색에 대한 스팟으로 이동후 mbr로 통신을 해야됨
                        return .run { [mapManager = state.mapManager] send in
                            let mbr = await mapManager.moveCamera(coord: data.coordinate)
                            await send(
                                .networkType(
                                    .otherSpot(
                                        mbrLocation: mbr,
                                        userLocation: userLocation,
                                        category: CategoryCase(rawValue: menuItem) ?? .all
                                    )
                                )
                            )
                        }
                    }
                    
                    return .run { send in
                        await send(.networkType(.otherSpot(mbrLocation: mbrLocation, userLocation: userLocation, category: CategoryCase(rawValue: menuItem) ?? .all)))
                    }
                } else {
                    state.errorMSG = reload ? "해당 위치에는 '\(state.searchText)'관련된 결과가 없어요" : "'\(state.searchText)'에 대한 검색 결과가 없어요"
                    state.errorIsPresented = true
                    
                    if !reload {
                        state.mapManager.moveCamera(coord: state.userLocation)
                    }
                }
                
            case let .dataTransType(.otherSpotDatas(data)):
                state.searchSpotItems.append(contentsOf: data)
                state.selectedIndex = 0
                state.mapManager.updateMarkers(markers: state.searchSpotItems)
                
                if state.isOtherFirst {
                    state.isOtherFirst = false
                    
//                    state.mapManager.moveCamera(coord: state.searchSpotItems[0].coordinate)
                    state.isPresented = true
                }
                
            case let .dataTransType(.archiveState(data)):
                state.searchSpotItems[state.selectedIndex] = MapSpotEntity(
                    spotId: state.searchSpotItems[state.selectedIndex].spotId,
                    spotName: state.searchSpotItems[state.selectedIndex].spotName,
                    spotAddress: state.searchSpotItems[state.selectedIndex].spotAddress,
                    spotAddressDetail: state.searchSpotItems[state.selectedIndex].spotAddressDetail,
                    coordinate: state.searchSpotItems[state.selectedIndex].coordinate,
                    category: state.searchSpotItems[state.selectedIndex].category,
                    tags: state.searchSpotItems[state.selectedIndex].tags,
                    images: state.searchSpotItems[state.selectedIndex].images,
                    isScraped: data.isArchive,
                    distance: state.searchSpotItems[state.selectedIndex].distance
                )
                
            case let .bindingIsPresented(isPresented):
                state.isPresented = isPresented
                
            case let .bindingArchive(isArchive):
                state.archive = isArchive
                
            case let .bindingErrorIsPresent(isPresent):
                state.errorIsPresented = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}

extension SearchMapFeature {
    private func registerPublisher(state: inout State) -> [Effect<SearchMapFeature.Action>] {
        var effects : [Effect<SearchMapFeature.Action>] = .init()
        
        effects.append(Effect<SearchMapFeature.Action>
            .publisher {
                state.mapManager.mbrLocationPass
                    .map { mbrLocation in
                        Action.mapAction(.getMBRLocation(mbrLocation))
                    }
            }
        )
        
        effects.append(Effect<SearchMapFeature.Action>
            .publisher {
                state.mapManager.markerIndexPass
                    .map { index in
                        Action.mapAction(.getMarkerIndex(index))
                    }
            }
        )
        
        effects.append(Effect<SearchMapFeature.Action>
            .publisher {
                state.mapManager.cameraIdlePass
                    .map { cameraLocation in
                        Action.mapAction(.getCameraLocation(cameraLocation))
                    }
            }
        )
        
        effects.append(Effect<SearchMapFeature.Action>
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
