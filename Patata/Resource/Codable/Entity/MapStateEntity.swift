//
//  MapStateEntity.swift
//  Patata
//
//  Created by 김진수 on 2/10/25.
//

import Foundation
import NMapsMap

final class MapStateEntity: @unchecked Sendable, ObservableObject, Equatable {
    let id = UUID()
    var markerImages: [String: NMFOverlayImage] = [:]
    var currentMarkers: [NMFMarker] = []
    var coord: Coordinate // 유저의 현 위치 혹은 디폴트된 좌표
    let markers: [(coordinate: Coordinate, category: String)] // 스팟들의 위치 저장 변수
    var first: Bool = false
    
    init(markerImages: [String : NMFOverlayImage] = [:], currentMarkers: [NMFMarker] = [], coord: Coordinate, markers: [(coordinate: Coordinate, category: String)]) {
        self.markerImages = markerImages
        self.currentMarkers = currentMarkers
        self.coord = coord
        self.markers = markers
    }
    
    static func == (lhs: MapStateEntity, rhs: MapStateEntity) -> Bool {
        return lhs.id == rhs.id
    }
}
