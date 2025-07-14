//
//  DeleteSpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/13/25.
//

import Foundation

struct DeleteSpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: DeleteSpotResult
}

struct DeleteSpotResult: DTO {
    let spotId: Int
    let message: String
}
