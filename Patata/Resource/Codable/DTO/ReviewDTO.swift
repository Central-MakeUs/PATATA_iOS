//
//  ReviewDTO.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

struct ReviewDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: ReviewResultDTO
}

struct ReviewResultDTO: DTO {
    let reviewId: Int
    let reviewText: String
    let reviewDate: String
}
