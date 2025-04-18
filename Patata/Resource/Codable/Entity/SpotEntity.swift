//
//  SpotEntity.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation

struct CategorySpotPageEntity: Entity {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let spots: [SpotEntity]
    
    init(currentPage: Int = 0, totalPages: Int = 0, totalCount: Int = 0, spots: [SpotEntity] = []) {
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalCount = totalCount
        self.spots = spots
    }
}

struct SpotEntity: Entity {
    let spotId: Int
    let spotAddress: String
    let spotName: String
    let category: CategoryCase
    let imageUrl: String?
    let reviews: Int
    let spotScraps: Int
    let isScraped: Bool
    let tags: [String]
    
    init(spotId: Int = 0, spotAddress: String = "", spotName: String = "", category: CategoryCase = .all, imageUrl: String? = nil, reviews: Int = 0, spotScraps: Int = 0, isScraped: Bool = false, tags: [String] = []) {
        self.spotId = spotId
        self.spotAddress = spotAddress
        self.spotName = spotName
        self.category = category
        self.imageUrl = imageUrl
        self.reviews = reviews
        self.spotScraps = spotScraps
        self.isScraped = isScraped
        self.tags = tags
    }
}
