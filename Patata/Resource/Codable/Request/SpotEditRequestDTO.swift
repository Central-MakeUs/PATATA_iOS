//
//  SpotEditRequestDTO.swift
//  Patata
//
//  Created by 김진수 on 2/19/25.
//

import Foundation

struct SpotEditRequestDTO: Encodable {
    let spotName: String
    let spotDescription: String
    let spotAddress: String
    let spotAddressDetail: String
    let latitude: Double
    let longitude: Double
    let tags: [String]
    let categoryId: Int
}
