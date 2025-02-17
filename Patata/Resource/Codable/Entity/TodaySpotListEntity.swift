//
//  TodaySpotListEntity.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

struct TodaySpotListEntity: Entity, Identifiable {
    let id: UUID
    let spotId: Int
    let spotAddress: String
    let spotAddressDetail: String
    let spotName: String
    let categoryId: CategoryCase
    let images: [URL?]
    let isScraped: Bool
    let distance: String
    let tags: [String]
    
    init(spotId: Int = 0, spotAddress: String = "", spotAddressDetail: String = "", spotName: String = "", categoryId: CategoryCase = .all, images: [URL?] = [], isScraped: Bool = false, distance: String = "", tags: [String] = []) {
        self.id = UUID()
        self.spotId = spotId
        self.spotAddress = spotAddress
        self.spotAddressDetail = spotAddressDetail
        self.spotName = spotName
        self.categoryId = categoryId
        self.images = images
        self.isScraped = isScraped
        self.distance = distance
        self.tags = tags
    }
}
