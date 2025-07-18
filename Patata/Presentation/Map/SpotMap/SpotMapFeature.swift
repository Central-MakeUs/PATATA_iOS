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
        var mapManager: MapManager = MapManager.spotMapShared
        var userLocation: Coordinate = Coordinate(latitude: 37.5666791, longitude: 126.9784147)
        var cameraLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var mbrLocation: MBRCoordinates = MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0))
        var mapSpotEntity: [MapSpotEntity] = []
        var selectIndex: Int = 0
        var selectedMenuIndex: Int = 0
        var spotReloadButton: Bool = false
        var isFirst: Bool = true
        var errorMSG: String = ""
        
        // bindingState
        var isPresented: Bool = false
        var archive: Bool = false
        var alertPresent: Bool = false
    }
    
    enum Action {
        case viewCycle(ViewCycle)
        case viewEvent(ViewEvent)
        case locationAction(LocationAction)
        case networkType(NetworkType)
        case mapAction(MapAction)
        case delegate(Delegate)
        case dataTransType(DataTransType)
        
        // bindingAction
        case bindingIsPresented(Bool)
        case bindingArchive(Bool)
        case bindingAlertPresent(Bool)
        
        enum Delegate {
            case tappedSideButton(MBRCoordinates)
            case tappedMarker
            case bottomSheetDismiss
            case tappedSpotAddButton(Coordinate)
            case tappedSearch
            case tappedSpotDetail(Int)
            case deleteSpot
            case succesReport
            case successEdit
            case detailBack
            case moveCamera
            case successAddSpot
            case noSpotData(String)
        }
    }
    
    enum ViewCycle {
        case onAppear
    }
    
    enum ViewEvent {
        case tappedMenu(Int)
        case tappedSpotAddButton
        case tappedSideButton
        case tappedSearch
        case tappedMoveToUserLocationButton
        case bottomSheetDismiss
        case tappedReloadButton
        case tappedArchiveButton
        case tappedSpotDetail(Int)
        case dismiss
    }
    
    enum LocationAction {
        case checkLocationPermission
        case locationPermissionResponse(Bool)
        case updateLocation(Coordinate)
    }
    
    enum NetworkType {
        case fetchMapMarker(userLocation: Coordinate, mbr: MBRCoordinates, categoryId: CategoryCase, Bool)
        case patchArchiveState
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
        case fetchMarkers([MapSpotEntity], Bool)
        case archiveState(ArchiveEntity)
    }
    
    enum MapAction {
        case getUserAndMBRLocation(Coordinate, MBRCoordinates)
        case getMBRLocation(MBRCoordinates)
        case getCameraLocation(Coordinate)
        case getMarkerIndex(Int)
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

extension SpotMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce {
            state,
            action in
            switch action {
            case .viewCycle(.onAppear):
                state.spotReloadButton = false
                
                return .merge(
                    .run { send in
                        await send(.dataTransType(.fetchRealm))
                        
                        for await location in locationManager.getLocationUpdates() {
                            await send(.dataTransType(.userLocation(location)))
                        }
                    },
                    .merge(registerPublisher(state: &state))
                )
                
            case let .viewEvent(.tappedMenu(index)):
                state.selectedMenuIndex = index
                
                let userLocation = state.userLocation
                let mbrLocation = state.mbrLocation
                
                return .run { send in
                    await send(.networkType(.fetchMapMarker(userLocation: userLocation, mbr: mbrLocation, categoryId: CategoryCase(rawValue: index) ?? .all, true)))
                }
                
            case .viewEvent(.tappedSpotAddButton):
                state.isPresented = false
                return .send(.delegate(.tappedSpotAddButton(state.cameraLocation)))
                
            case .viewEvent(.tappedSideButton):
                let mbrLocation = state.mbrLocation
                return .send(.delegate(.tappedSideButton(mbrLocation)))
                
            case .viewEvent(.bottomSheetDismiss):
                return .send(.delegate(.bottomSheetDismiss))
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.tappedMoveToUserLocationButton):
                state.mapManager.moveCamera(coord: state.userLocation)
                
            case .viewEvent(.tappedReloadButton):
                state.isPresented = false
                state.selectedMenuIndex = 0
                
                let userLocation = state.userLocation
                let mbr = state.mbrLocation
                
                return .run { send in
                    await send(.networkType(.fetchMapMarker(userLocation: userLocation, mbr: mbr, categoryId: .all, true)))
                }
                
            case .viewEvent(.tappedArchiveButton):
                return .run { send in
                    await send(.networkType(.patchArchiveState))
                }
                
            case let .viewEvent(.tappedSpotDetail(spotId)):
                return .send(.delegate(.tappedSpotDetail(spotId)))
                
            case .viewEvent(.dismiss):
                state.alertPresent = false
                
            case let .delegate(.noSpotData(msg)):
                state.errorMSG = msg
                state.alertPresent = true
                state.isPresented = false
                
                let user = state.userLocation
                let mbr = state.mbrLocation
                let category = CategoryCase(rawValue: state.selectedMenuIndex) ?? .all
                
                return .run { send in
                    await send(.networkType(.fetchMapMarker(userLocation: user, mbr: mbr, categoryId: category, false)))
                    await send(.viewEvent(.bottomSheetDismiss))
                }
                
            case let .mapAction(.getMBRLocation(mbrLocation)):
                state.mbrLocation = mbrLocation
                
            case .mapAction(.moveCamera):
                state.spotReloadButton = true
                
                if state.isPresented {
                    state.isPresented = false
                    return .send(.delegate(.moveCamera))
                }
                
            case let .mapAction(.getCameraLocation(cameraLocation)):
                state.cameraLocation = cameraLocation
                
            case let .mapAction(.getMarkerIndex(index)):
                state.selectIndex = index
                state.isPresented = true
                return .send(.delegate(.tappedMarker))
                
            case .delegate(.deleteSpot):
                state.isPresented = false
                
                let userLocation = state.userLocation
                let mbr = state.mbrLocation
                let category = CategoryCase(rawValue: state.selectedMenuIndex) ?? .all
                
                return .run { send in
                    await send(.networkType(.fetchMapMarker(userLocation: userLocation, mbr: mbr, categoryId: category, false)))
                }
                
            case .delegate(.succesReport):
                state.isPresented = false
                
            case .delegate(.successEdit):
                state.isPresented = false
                
            case .delegate(.detailBack):
                state.isFirst = false
                
            case .delegate(.successAddSpot):
                state.isFirst = false
                
                let userLocation = state.userLocation
                let mbr = state.mbrLocation
                
                return .run { send in
                    await send(.networkType(.fetchMapMarker(userLocation: userLocation, mbr: mbr, categoryId: .all, false)))
                }
                
            case let .networkType(.fetchMapMarker(userLocation, mbrLocation, categoryId, isReload)):
                return .run { send in
                    do {
                        let data = try await mapRepository.fetchMap(mbrLocation: mbrLocation, userLocation: userLocation, categoryId: categoryId.rawValue, isSearch: false)
                        
                        await send(.dataTransType(.fetchMarkers(data, isReload)))
                    } catch {
                        print("error", errorManager.handleError(error) ?? "")
                    }
                }
                
            case .networkType(.patchArchiveState):
                let spot = state.mapSpotEntity[state.selectIndex]
                
                return .run { send in
                    do {
                        let data = try await archiveRepository.toggleArchive(spotId: [spot.spotId])
                        
                        await send(.dataTransType(.archiveState(data)))
                    } catch {
                        print(errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.fetchMarkers(markers, isReload)):
                state.mapSpotEntity = markers
                
                state.mapManager.updateMarkers(markers: markers)
                
                if isReload && markers.isEmpty {
                    state.errorMSG = "해당 지역에 아직 스팟이 등록되어있지 않아요"
                    state.alertPresent = true
                }
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                
                if state.isFirst {
                    state.isFirst = false
                    
                    return .run { [mapManager = state.mapManager] send in
                        let mbr = await mapManager.moveCamera(coord: coord)
                        await send(.networkType(.fetchMapMarker(
                            userLocation: coord,
                            mbr: mbr,
                            categoryId: .all, false
                        )))
                    }
                }
                
            case let .dataTransType(.archiveState(data)):
                state.mapSpotEntity[state.selectIndex] = MapSpotEntity(
                    spotId: state.mapSpotEntity[state.selectIndex].spotId,
                    spotName: state.mapSpotEntity[state.selectIndex].spotName,
                    spotAddress: state.mapSpotEntity[state.selectIndex].spotAddress,
                    spotAddressDetail: state.mapSpotEntity[state.selectIndex].spotAddressDetail,
                    coordinate: state.mapSpotEntity[state.selectIndex].coordinate,
                    category: state.mapSpotEntity[state.selectIndex].category,
                    tags: state.mapSpotEntity[state.selectIndex].tags,
                    images: state.mapSpotEntity[state.selectIndex].images,
                    isScraped: data.isArchive,
                    distance: state.mapSpotEntity[state.selectIndex].distance
                )
                
            case let .bindingIsPresented(isPresented):
                state.isPresented = isPresented
                
            case let .bindingArchive(isArchive):
                state.archive = isArchive
                
            case let .bindingAlertPresent(isPresent):
                state.alertPresent = isPresent
                
            default:
                break
            }
            return .none
        }
    }
}

extension SpotMapFeature {
    private func registerPublisher(state: inout State) -> [Effect<SpotMapFeature.Action>] {
        var effects : [Effect<SpotMapFeature.Action>] = .init()
        
        effects.append(Effect<SpotMapFeature.Action>
            .publisher {
                state.mapManager.cameraIdlePass
                    .map { cameraLocation in
                        Action.mapAction(.getCameraLocation(cameraLocation))
                    }
            }
        )
        
        effects.append(Effect<SpotMapFeature.Action>
            .publisher {
                state.mapManager.mbrLocationPass
                    .map { mbrLocation in
                        Action.mapAction(.getMBRLocation(mbrLocation))
                    }
            }
        )
        
        effects.append(Effect<SpotMapFeature.Action>
            .publisher {
                state.mapManager.moveCameraPass
                    .map { _ in
                        Action.mapAction(.moveCamera)
                    }
            }
        )
        
        effects.append(Effect<SpotMapFeature.Action>
            .publisher {
                state.mapManager.markerIndexPass
                    .map { index in
                        Action.mapAction(.getMarkerIndex(index))
                    }
            }
        )
        
        return effects
    }
}
