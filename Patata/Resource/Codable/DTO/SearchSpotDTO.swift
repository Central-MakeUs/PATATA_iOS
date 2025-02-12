//
//  SearchSpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation

struct SearchSpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SearchSpotCountDTO
}

struct SearchSpotCountDTO: DTO {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let spots: [SearchSpotItemDTO]
}

struct SearchSpotItemDTO: DTO {
    let spotId: Int
    let spotName: String
    let imageUrl: String?
    let spotScraps: Int
    let isScraped: Bool
    let reviews: Int
    let distance: Double
}
