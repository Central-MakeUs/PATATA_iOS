//
//  ReviewRequestDTO.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

struct ReviewRequestDTO: DTO, Encodable {
    let spotId: Int
    let reviewText: String
}
