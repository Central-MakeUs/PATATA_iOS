//
//  MapSpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/15/25.
//

import Foundation
        
struct MapSpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [MapSpotItemDTO]
}

struct SearchMapDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: MapSpotItemDTO
}

struct MapSpotItemDTO: DTO {
    let spotId: Int
    let spotName: String
    let spotAddress: String
    let spotAddressDetail: String
    let latitude: Double
    let longitude: Double
    let categoryId: Int
    let tags: [String]
    let representativeImageUrl: String
    let isScraped: Bool
    let distance: Double
}
