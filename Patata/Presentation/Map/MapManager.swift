//
//  MapManager.swift
//  Patata
//
//  Created by 김진수 on 2/15/25.
//

import Foundation
import Combine
import NMapsMap
import ComposableArchitecture

final class NaverMapManager: NSObject, ObservableObject, NMFMapViewTouchDelegate, CLLocationManagerDelegate {
    
    let view = NMFNaverMapView(frame: .zero)
    let specificMarker: NMFMarker = NMFMarker()
    
    @Published var mbrLocation: MBRCoordinates = MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0))
    @Published var currentMarkers: [NMFMarker] = []
    @Published var markerImages: [String: NMFOverlayImage] = [:]
    
    let mbrLocationPass: PassthroughSubject<MBRCoordinates, Never> = .init()
    let cameraIdlePass: PassthroughSubject<Coordinate, Never> = .init()
    let moveCameraPass: PassthroughSubject<Void, Never> = .init()
    let markerIndexPass: PassthroughSubject<Int, Never> = .init()
    
    // MARK: - Initialization
    override init() {
        super.init()
        setupMapView()
    }
    
    private func setupMapView() {
        view.showZoomControls = false
        view.mapView.positionMode = .normal
        view.mapView.zoomLevel = 17
        view.mapView.addCameraDelegate(delegate: self)
    }
    
    func getNaverMapView() -> NMFNaverMapView {
        return view
    }
    
    // MARK: - Marker Management
    func updateMarkers(markers: [MapSpotEntity]) {
        Task {
            let newMarkers = markers.enumerated().map { index, marker in
                createMarker(
                    lat: marker.coordinate.latitude,
                    lng: marker.coordinate.longitude,
                    category: SpotMarkerImage.getMarkerImage(category: marker.category),
                    index: index
                )
            }
            
            await MainActor.run {
                clearCurrentMarkers()
                currentMarkers = newMarkers
                currentMarkers.forEach { $0.mapView = view.mapView }
            }
        }
    }
    
    @MainActor
    func moveCamera(coord: Coordinate) async -> MBRCoordinates {
        return await withCheckedContinuation { continuation in
            let specificLocation = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
            let cameraUpdate = NMFCameraUpdate(scrollTo: specificLocation)
            
            cameraUpdate.animation = .fly
            cameraUpdate.animationDuration = 0.5
            
            view.mapView.moveCamera(cameraUpdate) { [weak self] _ in
                guard let self else {
                    continuation.resume(returning: MBRCoordinates(northEast: Coordinate(latitude: 0, longitude: 0), southWest: Coordinate(latitude: 0, longitude: 0)))
                    return
                }
                
                let mbrCoord = MBRCoordinates(
                    northEast: Coordinate(
                        latitude: view.mapView.contentBounds.northEastLat,
                        longitude: view.mapView.contentBounds.northEastLng
                    ),
                    southWest: Coordinate(
                        latitude: view.mapView.contentBounds.southWestLat,
                        longitude: view.mapView.contentBounds.southWestLng
                    )
                )
                
                self.mbrLocation = mbrCoord
                continuation.resume(returning: mbrCoord)
            }
        }
    }
    
    func moveCamera(coord: Coordinate) {
        let specificLocation = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
        let cameraUpdate = NMFCameraUpdate(scrollTo: specificLocation)
        
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 0.5
        
        view.mapView.moveCamera(cameraUpdate) { [weak self] _ in
            guard let self else { return }
            
            let mbrCoord = MBRCoordinates(
                northEast: Coordinate(
                    latitude: view.mapView.contentBounds.northEastLat,
                    longitude: view.mapView.contentBounds.northEastLng
                ),
                southWest: Coordinate(
                    latitude: view.mapView.contentBounds.southWestLat,
                    longitude: view.mapView.contentBounds.southWestLng
                )
            )
            
            self.mbrLocation = mbrCoord
        }
    }
    
    func clearCurrentMarkers() {
        currentMarkers.forEach { $0.mapView = nil }
        currentMarkers.removeAll()
    }
    
    private func createMarker(lat: Double, lng: Double, category: String, index: Int) -> NMFMarker {
        let marker = NMFMarker()
        marker.position = NMGLatLng(lat: lat, lng: lng)
        marker.userInfo = ["index": index]
        
        marker.touchHandler = { [weak self] overlay -> Bool in
            guard let self else { return true }
            
            guard let marker = overlay as? NMFMarker,
                  let spotInfo = marker.userInfo as? [String: Any],
                  let index = spotInfo["index"] as? Int else { return true }
            
            markerIndexPass.send(index)
            return true
        }
        
        if let image = markerImages[category] {
            marker.iconImage = image
        } else {
            let image = NMFOverlayImage(name: category)
            marker.iconImage = image
            markerImages[category] = image
        }
        
        return marker
    }
    
}

// MARK: - NMFMapViewCameraDelegate
extension NaverMapManager: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
        if reason != 0 && !animated {
            moveCameraPass.send(())
        }
    }
    
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let currentCoord = Coordinate(
            latitude: mapView.latitude,
            longitude: mapView.longitude
        )
        
        let mbrCoord = MBRCoordinates(
            northEast: Coordinate(
                latitude: mapView.contentBounds.northEastLat,
                longitude: mapView.contentBounds.northEastLng
            ),
            southWest: Coordinate(
                latitude: mapView.contentBounds.southWestLat,
                longitude: mapView.contentBounds.southWestLng
            )
        )
        print(currentCoord)
        mbrLocationPass.send(mbrCoord)
        cameraIdlePass.send(currentCoord)
    }
}

extension NaverMapManager {
    static let spotMapShared = NaverMapManager()
    static let addSpotShared = NaverMapManager()
    static let searchMapShared = NaverMapManager()
}
