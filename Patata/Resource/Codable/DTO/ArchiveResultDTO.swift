//
//  ArchiveResultDTO.swift
//  Patata
//
//  Created by 김진수 on 2/12/25.
//

import Foundation

struct ArchiveResultDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [ArchiveResultItemDTO]
}

struct ArchiveResultItemDTO: DTO {
    let spotId: Int
    let totalScraps: Int
    let message: String
}
