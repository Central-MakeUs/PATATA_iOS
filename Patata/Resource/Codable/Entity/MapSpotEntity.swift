//
//  MapSpotEntity.swift
//  Patata
//
//  Created by 김진수 on 2/15/25.
//

import Foundation

struct MapSpotEntity: Entity {
    let spotId: Int
    let spotName: String
    let spotAddress: String
    let spotAddressDetail: String
    let coordinate: Coordinate
    let category: CategoryCase
    let tags: [String]
    let images: [URL?]
    let isScraped: Bool
    let distance: String
    
    init(spotId: Int = 0, spotName: String = "", spotAddress: String = "", spotAddressDetail: String = "", coordinate: Coordinate = Coordinate(latitude: 0, longitude: 0), category: CategoryCase = .all, tags: [String] = [], images: [URL?] = [], isScraped: Bool = false, distance: String = "") {
        self.spotId = spotId
        self.spotName = spotName
        self.spotAddress = spotAddress
        self.spotAddressDetail = spotAddressDetail
        self.coordinate = coordinate
        self.category = category
        self.tags = tags
        self.images = images
        self.isScraped = isScraped
        self.distance = distance
    }
}
