//
//  TodaySpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation

struct TodaySpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [TodaySpotItemDTO]
}

struct TodaySpotItemDTO: DTO {
    let spotId: Int
    let spotAddress: String
    let spotName: String
    let categoryId: Int
    let imageUrl: String?
    let isScraped: Bool
    let tags: [String]
}
