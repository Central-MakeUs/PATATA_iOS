//
//  ReportRequestDTO.swift
//  Patata
//
//  Created by 김진수 on 2/20/25.
//

import Foundation

struct ReportRequestDTO: DTO, Encodable {
    let reason: String
    let description: String
}
