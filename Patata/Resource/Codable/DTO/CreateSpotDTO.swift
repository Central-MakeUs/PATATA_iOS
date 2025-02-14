//
//  CreateSpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

struct CreateSpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: CreateSpotResultDTO
}

struct CreateSpotResultDTO: DTO {
    let spotId: Int
    let spotName: String
}

