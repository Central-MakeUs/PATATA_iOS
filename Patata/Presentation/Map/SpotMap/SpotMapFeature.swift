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
        var mapState: MapStateEntity = MapStateEntity(coord: Coordinate(latitude: 37.5666791, longitude: 126.9784147), markers: [(Coordinate(latitude: 37.5666791, longitude: 126.9784147), SpotMarkerImage.housePin)])
        var userLocation: Coordinate = Coordinate(latitude: 37.5666791, longitude: 126.9784147)
        var cameraLocation: Coordinate = Coordinate(latitude: 0, longitude: 0)
        var mbrLocation: MBRCoordinates = MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0))
        var mapSpotEntity: [MapSpotEntity] = []
        var selectMarker: MapSpotEntity = MapSpotEntity()
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
        case delegate(Delegate)
        case dataTransType(DataTransType)
        
        // bindingAction
        case bindingIsPresented(Bool)
        case bindingArchive(Bool)
        
        enum Delegate {
            case tappedSideButton
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
        case tappedMarker(Int)
        case tappedSpotAddButton
        case tappedSideButton
        case tappedSearch
        case tappedMoveToUserLocationButton
        case bottomSheetDismiss
        case changeMapLocation
        case onCameraIdle(user: Coordinate, mbr: MBRCoordinates)
    }
    
    enum LocationAction {
        case checkLocationPermission
        case locationPermissionResponse(Bool)
        case updateLocation(Coordinate)
    }
    
    enum NetworkType {
        case fetchMapMarker(userLocation: Coordinate, mbr: MBRCoordinates, categoryId: CategoryCase)
    }
    
    enum DataTransType {
        case fetchRealm
        case userLocation(Coordinate)
        case fetchMarkers([MapSpotEntity])
    }
    
    @Dependency(\.mapRepository) var mapRepository
    @Dependency(\.locationManager) var locationManager
    @Dependency(\.errorManager) var errorManager
    
    var body: some ReducerOf<Self> {
        core()
    }
}

extension SpotMapFeature {
    private func core() -> some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .viewCycle(.onAppear):
                state.spotReloadButton = false
                state.isFirst = true
                
                return .run { send in
                        await send(.dataTransType(.fetchRealm))
                        
                        for await location in locationManager.getLocationUpdates() {
                            await send(.dataTransType(.userLocation(location)))
                        }
                    }
                
            case let .viewEvent(.tappedMenu(index)):
                state.selectedMenuIndex = index
                
            case let .viewEvent(.tappedMarker(index)):
                state.selectMarker = state.mapSpotEntity[index]
                state.isPresented = true
                return .send(.delegate(.tappedMarker))
                
            case .viewEvent(.tappedSpotAddButton):
                state.isPresented = false
                return .send(.delegate(.tappedSpotAddButton(state.cameraLocation)))
                
            case .viewEvent(.tappedSideButton):
                return .send(.delegate(.tappedSideButton))
                
            case .viewEvent(.bottomSheetDismiss):
                return .send(.delegate(.bottomSheetDismiss))
                
            case .viewEvent(.tappedSearch):
                return .send(.delegate(.tappedSearch))
                
            case .viewEvent(.changeMapLocation):
                state.spotReloadButton = true
                
            case .viewEvent(.tappedMoveToUserLocationButton):
                state.mapState.first = false
                state.mapState.coord = state.userLocation
                
            case let .viewEvent(.onCameraIdle(coord, mbr)):
                state.cameraLocation = coord
                state.mbrLocation = mbr
                
            case let .networkType(.fetchMapMarker(userLocation, mbrLocation, categoryId)):
                return .run { send in
                    do {
                        let data = try await mapRepository.fetchMap(mbrLocation: mbrLocation, userLocation: userLocation, categoryId: categoryId.rawValue, isSearch: false)
                        
                        await send(.dataTransType(.fetchMarkers(data)))
                    } catch {
                        print("error", errorManager.handleError(error) ?? "")
                    }
                }
                
            case let .dataTransType(.fetchMarkers(markers)):
                state.mapSpotEntity = markers
                state.mapState = MapStateEntity(
                    coord: state.userLocation,
                    markers: markers.map { ($0.coordinate, SpotMarkerImage.getMarkerImage(category: $0.category)) }
                )
                
            case .dataTransType(.fetchRealm):
                return .run { send in
                    let coord = await dataSourceActor.fetch()
                    await send(.dataTransType(.userLocation(coord)))
                }
                
            case let .dataTransType(.userLocation(coord)):
                state.userLocation = coord
                state.mapState.coord = coord
                
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
