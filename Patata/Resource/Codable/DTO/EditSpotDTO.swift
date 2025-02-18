//
//  EditSpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/19/25.
//

import Foundation

struct EditSpotDTO: DTO {
    let isSuccess: Bool
    let code: String
    let message: String
    let result: EditSpotListDTO
}

// result 부분을 위한 구조체
struct EditSpotListDTO: DTO {
    let spotId: Int
    let spotName: String
    let spotDescription: String
    let spotAddress: String
    let spotAddressDetail: String
    let categoryName: String
}
