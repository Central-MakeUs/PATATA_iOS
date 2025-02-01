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
    
    private final class MapState {
        var markerImages: [String: NMFOverlayImage] = [:]
        var currentMarkers: [NMFMarker] = []
    }

    let coord: (Double, Double) // 유저의 현 위치 혹은 디폴트된 좌표
    let markers: [(coordinate: (long: Double, lat: Double), category: String)] // 스팟들의 위치 저장 변수
    let onMarkerTap: ((Double, Double) -> Void)?
    private let mapState = MapState()
    
    init(
        coord: (Double, Double),
        markers: [(coordinate: (long: Double, lat: Double), category: String)],
        onMarkerTap: ((Double, Double) -> Void)? = nil
    ) {
        self.coord = coord
        self.markers = markers
        self.onMarkerTap = onMarkerTap
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIView(context: Context) -> NMFNaverMapView {
        let view = NMFNaverMapView()
        
        view.showZoomControls = false
        view.mapView.positionMode = .direction
        view.mapView.zoomLevel = 17
        view.mapView.addCameraDelegate(delegate: context.coordinator)
      
        return view
    }
    
    // 여기서에서 마커 추가하는 로직 (좌표와 카테고리 이미지를 받으면서 마커 찍기)
    func updateUIView(_ uiView: NMFNaverMapView, context: Context) {
        let coord = NMGLatLng(lat: coord.1, lng: coord.0)
        let cameraUpdate = NMFCameraUpdate(scrollTo: coord) // 유저 초기화면
        
        Task {
            let newMarkers = markers.map { marker in
                addMarker(
                    lat: marker.coordinate.lat,
                    long: marker.coordinate.long,
                    mapView: uiView.mapView,
                    category: marker.category
                )
            }
            
            await MainActor.run {
                mapState.currentMarkers = newMarkers
                newMarkers.forEach { $0.mapView = uiView.mapView }
            }
        }
        
        cameraUpdate.animation = .fly
        cameraUpdate.animationDuration = 1
        uiView.mapView.moveCamera(cameraUpdate)
    }
    
    private func addMarker(lat: Double, long: Double, mapView: NMFMapView, category: String) -> NMFMarker {
        let marker = NMFMarker()
        
        marker.position = NMGLatLng(lat: lat, lng: long)
        marker.touchHandler = { (overlay) -> Bool in
            onMarkerTap?(lat, long)
            return true
        }
        
        // 여기서 해당하는 사진 객체를 생성하면서 없으면 생성 아니면 바로 그걸로 적용
        if let image = mapState.markerImages[category] {
            marker.iconImage = image
        } else {
            let image = NMFOverlayImage(name: category)
            
            marker.iconImage = image
            mapState.markerImages[category] = image
        }
        
        return marker
    }
    
    class Coordinator: NSObject, NMFMapViewCameraDelegate {
        func mapViewCameraIdle(_ mapView: NMFMapView) {
            print("mapViewCameraIdle 카메라 좌표", mapView.cameraPosition.target)
        }
    }
}
