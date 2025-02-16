//
//  SearchSpotEntity.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation

struct SearchSpotCountEntity: Entity {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let spots: [SearchSpotEntity]
    
    init(currentPage: Int = 0, totalPages: Int = 0, totalCount: Int = 0, spots: [SearchSpotEntity] = []) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalCount = totalCount
        self.spots = spots
    }
}

struct SearchSpotEntity: Entity {
    let spotId: Int
    let spotName: String
    let imageUrl: URL?
    let spotScraps: Int
    let isScraped: Bool
    let reviews: Int
    let distance: Double
    
    init(spotId: Int = 0, spotName: String = "", imageUrl: URL? = nil, spotScraps: Int = 0, isScraped: Bool = false, reviews: Int = 0, distance: Double = 0) {
        self.spotId = spotId
        self.spotName = spotName
        self.imageUrl = imageUrl
        self.spotScraps = spotScraps
        self.isScraped = isScraped
        self.reviews = reviews
        self.distance = distance
    }
}
