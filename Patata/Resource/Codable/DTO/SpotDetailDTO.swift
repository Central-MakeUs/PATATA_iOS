//
//  SpotDetailDTO.swift
//  Patata
//
//  Created by 김진수 on 2/13/25.
//

import Foundation

struct SpotDetailDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SpotDetailItemDTO
}

struct SpotDetailItemDTO: DTO {
    let spotId: Int
    let isAuthor: Bool
    let spotAddress: String
    let spotAddressDetail: String?
    let spotName: String
    let spotDescription: String
    let categoryId: Int
    let memberName: String
    let memberId: Int?
    let images: [String]
    let latitude: Double
    let longitude: Double
    let reviewCount: Int
    let isScraped: Bool
    let tags: [String]
    let reviews: [SpotDetailReviewDTO]
}

struct SpotDetailReviewDTO: DTO {
    let reviewId: Int
    let memberName: String
    let reviewText: String
    let reviewDate: String
}
