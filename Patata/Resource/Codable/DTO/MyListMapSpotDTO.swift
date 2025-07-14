//
//  MyListMapSpotDTO.swift
//  Patata
//
//  Created by 김진수 on 3/2/25.
//

import Foundation

struct MyListMapSpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: MyListMapSpotCountDTO
}

struct MyListMapSpotCountDTO: DTO {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let spots: [MapSpotItemDTO]
}
