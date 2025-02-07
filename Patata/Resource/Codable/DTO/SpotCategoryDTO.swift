//
//  SpotCategoryDTO.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation

struct SpotCategoryDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: SpotCategoryItemDTO
}

struct SpotCategoryItemDTO: DTO {
    let currentPage: Int
    let totalPages: Int
    let totalCount: Int
    let spots: [SpotDTO]
}
