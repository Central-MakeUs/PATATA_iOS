//
//  MySpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation

struct MySpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: MySpotCountDTO
}

struct MySpotCountDTO: DTO {
    let totalSpots: Int
    let spots: [ArchiveItemDTO]
}
