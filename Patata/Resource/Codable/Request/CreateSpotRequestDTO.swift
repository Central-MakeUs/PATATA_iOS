//
//  CreateSpotRequestDTO.swift
//  Patata
//
//  Created by 김진수 on 2/14/25.
//

import Foundation

struct CreateSpotRequestDTO: DTO, Encodable {
    let spotName: String
    let spotAddress: String
    let spotAddressDetail: String
    let latitude: Double
    let longitude: Double
    let spotDescription: String
    let categoryId: Int
    let tags: [String]
    let images: [RequestSpotImageDTO]
}

struct RequestSpotImageDTO: DTO, Encodable {
   let file: Data
   let isRepresentative: Bool
   let sequence: Int
}
