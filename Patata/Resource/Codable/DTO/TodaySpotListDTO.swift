//
//  TodaySpotListDTO.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

struct TodaySpotListDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [TodaySpotListItemDTO]
}

struct TodaySpotListItemDTO: DTO {
    let spotId: Int
    let spotAddress: String
    let spotAddressDetail: String
    let spotName: String
    let categoryId: Int
    let images: [String]
    let isScraped: Bool
    let distance: Double
    let tags: [String]
}
