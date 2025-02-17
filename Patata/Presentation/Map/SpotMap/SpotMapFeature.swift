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
        var mapManager: NaverMapManager = NaverMapManager.spotMapShared
        var userLocation: Coordinate = Coordinate(latitude: 37.5666791, longitude: 126.9784147)
        var cameraLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var mbrLocation: MBRCoordinates = MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0))
        var mapSpotEntity: [MapSpotEntity] = []
        var selectIndex: Int = 0
        var selectedMenuIndex: Int = 0
        var spotReloadButton: Bool = false
        var isFirst: Bool = false
        
        // bindingState
        var isPresented: Bool = false
        var archive: Bool = false
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
        
        enum Delegate {
            case tappedSideButton(MBRCoordinates)
            case tappedMarker
            case bottomSheetDismiss
            case tappedSpotAddButton(Coordinate)
            case tappedSearch
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
    }
    
    enum LocationAction {
        case checkLocationPermission
        case locationPermissionResponse(Bool)
        case updateLocation(Coordinate)
    }
    
    enum NetworkType {
        case fetchMapMarker(userLocation: Coordinate, mbr: MBRCoordinates, categoryId: CategoryCase)
        case patchArchiveState
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
        case fetchMarkers([MapSpotEntity])
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
                state.isFirst = true
                
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
                    await send(.networkType(.fetchMapMarker(userLocation: userLocation, mbr: mbrLocation, categoryId: CategoryCase(rawValue: index) ?? .all)))
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
                state.selectedMenuIndex = 0
                
                let userLocation = state.userLocation
                let mbr = state.mbrLocation
                
                return .run { send in
                    await send(.networkType(.fetchMapMarker(userLocation: userLocation, mbr: mbr, categoryId: .all)))
                }
                
            case .viewEvent(.tappedArchiveButton):
                return .run { send in
                    await send(.networkType(.patchArchiveState))
                }
                
            case let .mapAction(.getMBRLocation(mbrLocation)):
                state.mbrLocation = mbrLocation
                
            case .mapAction(.moveCamera):
                state.spotReloadButton = true
                
            case let .mapAction(.getCameraLocation(cameraLocation)):
                state.cameraLocation = cameraLocation
                
            case let .mapAction(.getMarkerIndex(index)):
                state.selectIndex = index
                state.isPresented = true
                return .send(.delegate(.tappedMarker))
                
            case let .networkType(.fetchMapMarker(userLocation, mbrLocation, categoryId)):
                return .run { send in
                    do {
                        let data = try await mapRepository.fetchMap(mbrLocation: mbrLocation, userLocation: userLocation, categoryId: categoryId.rawValue, isSearch: false)
                        
                        await send(.dataTransType(.fetchMarkers(data)))
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
                
            case let .dataTransType(.fetchMarkers(markers)):
                state.mapSpotEntity = markers
                
                state.mapManager.updateMarkers(markers: markers)
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                
                state.mapManager.moveCamera(coord: coord)
                
                if state.isFirst {
                    state.isFirst = false
                    return .run { send in
                        let initialMBR = calculateInitialMBR(userLocation: coord)
                        await send(.networkType(.fetchMapMarker(
                            userLocation: coord,
                            mbr: initialMBR,
                            categoryId: .all
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
                
            default:
                break
            }
            return .none
        }
    }
}


extension SpotMapFeature {
    private func calculateInitialMBR(userLocation: Coordinate, zoomLevel: Int = 17) -> MBRCoordinates {
        // 줌 레벨 17에서의 적절한 오프셋 계산
        // 줌 레벨이 증가할수록 표시되는 영역이 작아짐
        // 줌 레벨 17은 대략 도시 블록 수준의 상세도
        let latOffset = 0.003  // 약 300-400m (위도)
        let lngOffset = 0.004  // 약 300-400m (경도, 서울 위도 기준)
        
        let northEast = Coordinate(
            latitude: userLocation.latitude + latOffset,
            longitude: userLocation.longitude + lngOffset
        )
        
        let southWest = Coordinate(
            latitude: userLocation.latitude - latOffset,
            longitude: userLocation.longitude - lngOffset
        )
        
        return MBRCoordinates(northEast: northEast, southWest: southWest)
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
