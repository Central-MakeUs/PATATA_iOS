//
//  TodaySpotEntity.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation

struct TodaySpotEntity: Entity {
    let spotId: Int
    let spotAddress: String
    let spotName: String
    let category: CategoryCase
    let imageUrl: String?
    let isScraped: Bool
    let tags: [String]
    
    init(spotId: Int = 0, spotAddress: String = "", spotName: String = "", category: CategoryCase = .all, imageUrl: String? = nil, isScraped: Bool = false, tags: [String] = []) {
        self.spotId = spotId
        self.spotAddress = spotAddress
        self.spotName = spotName
        self.category = category
        self.imageUrl = imageUrl
        self.isScraped = isScraped
        self.tags = tags
    }
}
