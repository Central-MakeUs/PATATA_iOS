//
//  SpotDTO.swift
//  Patata
//
//  Created by 김진수 on 2/7/25.
//

import Foundation
//{
//        "spotId": 6,
//        "spotAddress": "서울특별시 용산구 이태원로 123",
//        "spotName": "이태원 스테이크하우스",
//        "category": "스냅 스팟",
//        "imageUrl": null,  //대표이미지
//        "reviews": 0,
//        "spotScraps": 30,
//        "isScraped": false,
//        "tags": []
//      }

struct SpotDTO: DTO {
    let spotId: Int
    let spotAddress: String
    let spotName: String
    let category: String
    let imageUrl: String
    let reviews: Int
    let spotScraps: Int
    let isScraped: Bool
    let tags: [String]
}
