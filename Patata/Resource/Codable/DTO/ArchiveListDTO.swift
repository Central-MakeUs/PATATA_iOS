//
//  ArchiveListDTO.swift
//  Patata
//
//  Created by 김진수 on 2/17/25.
//

import Foundation

struct ArchiveListDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [ArchiveItemDTO]
}

struct ArchiveItemDTO: DTO {
    let spotId: Int
    let spotName: String
    let representativeImageUrl: String
}
