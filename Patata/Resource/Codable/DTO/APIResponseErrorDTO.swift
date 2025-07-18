//
//  APIResponseErrorDTO.swift
//  Patata
//
//  Created by 김진수 on 1/14/25.
//

import Foundation

struct APIResponseErrorDTO: ErrorDTO {
    let isSuccess: Bool
    let code: String
    let message: String
}
