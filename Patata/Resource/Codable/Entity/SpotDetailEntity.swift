//
//  SpotDetailEntity.swift
//  Patata
//
//  Created by 김진수 on 2/13/25.
//

import Foundation

struct SpotDetailEntity: Entity {
    let spotId: Int
    let isAuthor: Bool
    let spotAddress: String
    let spotAddressDetail: String
    let spotName: String
    let spotDescription: String
    let categoryId: CategoryCase
    let memberName: String
    let images: [URL?]
    let reviewCount: Int
    let isScraped: Bool
    let tags: [String]
    let reviews: [SpotDetailReviewEntity]
    let spotCoord: Coordinate
    let memberId: Int?
    
    init(spotId: Int = 0, isAuthor: Bool = false, spotAddress: String = "", spotAddressDetail: String = "", spotName: String = "", spotDescription: String = "", categoryId: CategoryCase = .all, memberName: String = "", images: [URL?] = [], reviewCount: Int = 0, isScraped: Bool = false, tags: [String] = [], reviews: [SpotDetailReviewEntity] = [], spotCoord: Coordinate = Coordinate(latitude: 0, longitude: 0), memberId: Int? = nil) {
        self.spotId = spotId
        self.isAuthor = isAuthor
        self.spotAddress = spotAddress
        self.spotAddressDetail = spotAddressDetail
        self.spotName = spotName
        self.spotDescription = spotDescription
        self.categoryId = categoryId
        self.memberName = memberName
        self.images = images
        self.reviewCount = reviewCount
        self.isScraped = isScraped
        self.tags = tags
        self.reviews = reviews
        self.spotCoord = spotCoord
        self.memberId = memberId
    }
}

struct SpotDetailReviewEntity: Entity {
    let reviewId: Int
    let memberName: String
    let reviewText: String
    let reviewData: String
}
