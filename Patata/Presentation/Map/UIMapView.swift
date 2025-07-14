//
//  UIMapView.swift
//  Patata
//
//  Created by 김진수 on 1/29/25.
//

import SwiftUI
import NMapsMap

// 초기값으로 스팟에 대한 위도, 경도를 받고
// 카테고리에 맞는 이미지를 생성해서 스팟에 넣는다
// 이때 이미 이미지가 있는지 체크를 하고 없다면 생성을 한다.
// 생성을 하고 그걸 저장을 해야지 또 생성하지않고 재사용을 하는 것이다.

// 마커를 return하기전에 마커에 대한 이미지를 체크를 하는 함수를 거쳐라

// 초기값으로는 좌표값과 카테고리가 있어야지

struct UIMapView: UIViewRepresentable {
    let mapManager: MapManager
    
    func makeCoordinator() -> MapManager {
        mapManager
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        return context.coordinator.getNaverMapView()
    }
    
    // 여기서에서 마커 추가하는 로직 (좌표와 카테고리 이미지를 받으면서 마커 찍기)
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
//        moveToCamera(coord: mapState.coord, uiView: uiView)
//        
//        Task {
//            let newMarkers = mapState.markers.enumerated().map { index, marker in
//                addMarker(
//                    lat: marker.coordinate.latitude,
//                    long: marker.coordinate.longitude,
//                    mapView: uiView.mapView,
//                    category: marker.category,
//                    index: index
//                )
//            }
//            
//            await MainActor.run {
//                clearMarkers(mapState: mapState)
//                mapState.currentMarkers = newMarkers
//                mapState.currentMarkers.forEach { $0.mapView = uiView.mapView }
//            }
//        }
    }
    
//    class Coordinator: NSObject, NMFMapViewCameraDelegate {
//        let onLocationChange: (() -> Void)?
//        let locationToAddress: ((Double, Double) -> Void)?
//        let onCameraIdle: ((Coordinate, MBRCoordinates) -> Void)?
//        
//        static let shared = Coordinator(
//               onLocationChange: nil,
//               locationToAddress: nil,
//               onCameraIdle: nil
//           )
//        
//        init(onLocationChange: (() -> Void)?, locationToAddress: ((Double, Double) -> Void)?, onCameraIdle: ((Coordinate, MBRCoordinates) -> Void)?) {
//            self.onLocationChange = onLocationChange
//            self.locationToAddress = locationToAddress
//            self.onCameraIdle = onCameraIdle
//            super.init()
//        }
//        
//        func mapView(_ mapView: NMFMapView, cameraWillChangeByReason reason: Int, animated: Bool) {
//            if reason != 0 && !animated {
//                onLocationChange?()
//            }
//        }
//        
//        func mapViewCameraIdle(_ mapView: NMFMapView) {
//            let currentCoord = Coordinate(
//                latitude: mapView.latitude,
//                longitude: mapView.longitude
//            )
//            
//            let mbrCoord = MBRCoordinates(
//                northEast: Coordinate(latitude: mapView.contentBounds.northEastLat, longitude: mapView.contentBounds.northEastLng),
//                southWest: Coordinate(latitude: mapView.contentBounds.southWestLat, longitude: mapView.contentBounds.southWestLng)
//            )
//            
//            onCameraIdle?(currentCoord, mbrCoord)
//            locationToAddress?(mapView.latitude, mapView.longitude)
//        }
//    }
}

//extension UIMapView {
//    private func addMarker(lat: Double, long: Double, mapView: NMFMapView, category: String, index: Int) -> NMFMarker {
//        let marker = NMFMarker()
//        marker.position = NMGLatLng(lat: lat, lng: long)
//        marker.userInfo = ["index": index]
//        marker.touchHandler = { (overlay) -> Bool in
//            guard let marker = overlay as? NMFMarker,
//                  let spotInfo = marker.userInfo as? [String: Any],
//                  let index = spotInfo["index"] as? Int else { return true }
//            
//            onMarkerTap?(index)
//            return true
//        }
//        
//        // 여기서 해당하는 사진 객체를 생성하면서 없으면 생성 아니면 바로 그걸로 적용
//        if let image = mapState.markerImages[category] {
//            marker.iconImage = image
//        } else {
//            let image = NMFOverlayImage(name: category)
//            
//            marker.iconImage = image
//            mapState.markerImages[category] = image
//        }
//        
//        return marker
//    }
//    
//    private func clearMarkers(mapState: MapStateEntity) {
//        mapState.currentMarkers.forEach {
//            $0.mapView = nil
//        }
//        mapState.currentMarkers.removeAll()
//    }
//    
//    private func moveToCamera(coord: Coordinate, uiView: NMFNaverMapView) {
//        let coord = NMGLatLng(lat: coord.latitude, lng: coord.longitude)
//        let cameraUpdate = NMFCameraUpdate(scrollTo: coord) // 유저 초기화면
//        
//        cameraUpdate.animation = .fly
//        cameraUpdate.animationDuration = 1
//        
//        if !mapState.first {
//            uiView.mapView.moveCamera(cameraUpdate)
//        }
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            mapState.first = true
//        }
//    }
//}
