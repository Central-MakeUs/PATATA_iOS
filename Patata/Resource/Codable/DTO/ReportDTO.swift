//
//  ReportDTO.swift
//  Patata
//
//  Created by 김진수 on 2/20/25.
//

import Foundation

struct ReportDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ReportItemDTO
}

struct ReportItemDTO: DTO {
    let message: String
}
