//
//  AddSpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/16/25.
//

import Foundation

struct AddSpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: String
}

struct AddFailDTO: DTO, Error {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: [AddSpotItemDTO]
}

struct AddSpotItemDTO: DTO, Error {
    let spotId: Int
    let spotName: String
    let latitude: Double
    let longitude: Double
}
